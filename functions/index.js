const { initializeApp } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const { onSchedule } = require('firebase-functions/v2/scheduler');


initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// ✅ 1. Create Stripe Checkout Session (HTTP Function)
exports.createPaymentIntent = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { amount, email } = req.body;

      // Create a PaymentIntent on the server side
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount, // Amount in cents
        currency: 'myr',
        receipt_email: email, // Email for receipt
      });

      // Return the client secret to the client
      res.status(200).json({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
      console.error("❌ Stripe error:", error);
      res.status(500).send({ error: error.message });
    }
  });
});


// ✅ Notification: New Appointment
exports.notifyDoctorNewAppointment = onDocumentCreated(
  {
    document: 'appointments/{appointmentId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    logger.info("🕒 New appointment created at:", new Date().toISOString());

    const appointment = event.data.data();
    const doctorId = appointment.doctorId;

    const doctorDoc = await db.collection('users').doc(doctorId).get();
    if (!doctorDoc.exists) {
      logger.error("❌ Doctor not found!");
      return;
    }

    const doctorToken = doctorDoc.data().fcmToken;
    logger.info("📲 Doctor's FCM Token:", doctorToken);

    try {
      await messaging.send({
        token: doctorToken,
        notification: {
          title: 'New Appointment',
          body: 'A patient has booked an appointment with you.',
        },
        data: {
          type: 'appointment',
          appointmentId: event.params.appointmentId,
        }
      });

      logger.info("✅ Notification sent successfully at:", new Date().toISOString());
    } catch (error) {
      logger.error("❌ Error sending notification:", error);
    }
  }
);

exports.sendAppointmentReminders = onSchedule(
  {
    schedule: 'every 1 minutes',
    region: 'asia-southeast1',
    timeZone: 'Asia/Kuala_Lumpur',
  },
  async (event) => {
    logger.info("🔄 Checking for appointment reminders with precise timing...");

    // Get current time in KL timezone (UTC+8)
    const now = new Date();
    const nowUTC8 = new Date(now.getTime() + (8 * 60 * 60 * 1000));
    const thirtyOneMinsLaterUTC8 = new Date(nowUTC8.getTime() + (31 * 60 * 1000));

    // Convert to Firestore Timestamps (UTC)
    const nowUTC = new Date(nowUTC8.getTime() - (8 * 60 * 60 * 1000));
    const thirtyOneMinsLaterUTC = new Date(thirtyOneMinsLaterUTC8.getTime() - (8 * 60 * 60 * 1000));

    const nowTimestamp = Timestamp.fromDate(nowUTC);
    const thirtyOneMinsLaterTimestamp = Timestamp.fromDate(thirtyOneMinsLaterUTC);

    logger.info(`⌛ Checking window: ${nowUTC8.toISOString()} to ${thirtyOneMinsLaterUTC8.toISOString()} (KL Time)`);

    const appointmentsRef = db.collection('appointments');
    const snapshot = await appointmentsRef
      .where('status', '==', 'confirmed')
      .where('dateTime', '>=', nowTimestamp)
      .where('dateTime', '<=', thirtyOneMinsLaterTimestamp)
      .get();

    if (snapshot.empty) {
      logger.info("📭 No upcoming appointments in the next 31 minutes.");
      return;
    }

    logger.info(`📅 Found ${snapshot.size} appointments needing reminders`);

    for (const doc of snapshot.docs) {
      try {
        const appointment = doc.data();
        const appointmentId = doc.id;
        
        // Convert Firestore Timestamp (UTC) to KL time (UTC+8)
        const appointmentTimeUTC = appointment.dateTime.toDate();
        const appointmentTimeUTC8 = new Date(appointmentTimeUTC.getTime() + (8 * 60 * 60 * 1000));

        const diffMins = Math.round((appointmentTimeUTC8 - nowUTC8) / (60 * 1000));
        const diffSeconds = Math.round((appointmentTimeUTC8 - nowUTC8) / 1000);

        logger.info(`⏳ Appointment ${appointmentId} at ${appointmentTimeUTC8.toISOString()} (in ${diffMins} minutes ${diffSeconds % 60} seconds)`);

        // PRECISE TIMING CHECKS
        let message = null;
        let notificationType = null;
        
        // Check if we're exactly at a reminder threshold
        if (diffMins === 30 && !appointment.reminders?.thirtyMinSent) {
          message = 'Your appointment starts in 30 minutes.';
          notificationType = '30m_reminder';
        } 
        else if (diffMins === 15 && !appointment.reminders?.fifteenMinSent) {
          message = 'Your appointment starts in 15 minutes.';
          notificationType = '15m_reminder';
        }
        // Modified join now check with 1-minute buffer
        else if (diffSeconds >= -60 && diffSeconds <= 60 && !appointment.reminders?.joinNowSent) {
          message = 'Your appointment can now be joined.';
          notificationType = 'join_now';
        }

        // Skip if no notification needed
        if (!message) {
          logger.info(`⏭️ No new reminders needed for appointment ${appointmentId}`);
          continue;
        }

        logger.info(`⏰ Sending ${notificationType} for appointment ${appointmentId}`);

        // Get user data in parallel
        const [patientDoc, doctorDoc] = await Promise.all([
          db.collection('users').doc(appointment.patientId).get(),
          db.collection('users').doc(appointment.doctorId).get()
        ]);

        const notify = async (userDoc, role) => {
          if (!userDoc.exists) {
            logger.warn(`⚠️ ${role} document not found`);
            return;
          }

          const token = userDoc.data().fcmToken;
          if (!token) {
            logger.warn(`⚠️ No FCM token for ${role}`);
            return;
          }

          try {
            await messaging.send({
              token: token,
              notification: {
                title: role === 'doctor' 
                  ? `Appointment with ${patientDoc.data().name || 'Patient'}`
                  : `Appointment with Dr. ${doctorDoc.data().lastName || ''}`,
                body: message,
              },
              data: {
                type: 'appointment_reminder',
                subType: notificationType,
                appointmentId: appointmentId,
                role: role,
                timestamp: now.toISOString()
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'appointment_alerts',
                  sound: 'notification'
                }
              }
            });
            logger.info(`✅ ${notificationType} sent to ${role}`);
          } catch (error) {
            logger.error(`❌ Failed to send to ${role}:`, error);
          }
        };

        // Send notifications
        await Promise.all([
          notify(patientDoc, 'patient'),
          notify(doctorDoc, 'doctor')
        ]);

        // Update reminders tracking
        await doc.ref.update({
          reminders: {
            ...(appointment.reminders || {}),
            [`${notificationType}Sent`]: true
          }
        });
        logger.info(`📝 Marked ${notificationType} as sent for appointment ${appointmentId}`);

      } catch (error) {
        logger.error(`🔥 Error processing appointment ${doc.id}:`, error);
      }
    }
  }
);


// ✅ Notification: General push
exports.sendPushNotification = onDocumentCreated(
  {
    document: 'notifications/{notificationId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error("❌ No snapshot data available!");
      return;
    }

    const notification = snapshot.data();
    logger.info("📩 Sending notification:", notification);

    try {
      await messaging.send({
        token: notification.to,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data,
      });

      await snapshot.ref.delete();
      logger.info("🗑️ Notification document deleted after sending.");
    } catch (error) {
      logger.error("❌ Error sending push notification:", error);
    }
  }
);

// ✅ Agora Token Generator (v1 HTTPS Function)
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const AGORA_APP_ID = 'a49de82128904c6db10e48851bba1b55';
const AGORA_CERTIFICATE = '1c43ce5759fc428e88d4ad9a4f89282e';

exports.generateAgoraToken = functions.https.onRequest((req, res) => {
  const channelName = req.query.channelName;
  if (!channelName) {
    return res.status(400).json({ error: "channelName is required" });
  }

  const uid = req.query.uid ? parseInt(req.query.uid) : 0;
  const role = req.query.role === "subscriber" ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;
  const expireTime = req.query.expireTime ? parseInt(req.query.expireTime) : 3600;

  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = currentTime + expireTime;

  const token = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID, AGORA_CERTIFICATE, channelName, uid, role, privilegeExpireTime
  );

  return res.json({ token });
});