const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');  // ✅ Import logger for debugging
const functions = require('firebase-functions');  // ✅ Import Firebase Functions (for v1)

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// ✅ V2 Syntax for better performance
exports.notifyDoctorNewAppointment = onDocumentCreated(
  {
    document: 'appointments/{appointmentId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    logger.info("🕒 New appointment created at:", new Date().toISOString());

    const appointment = event.data.data();
    const doctorId = appointment.doctorId;

    // Fetch doctor's FCM token
    const doctorDoc = await db.collection('users').doc(doctorId).get();
    if (!doctorDoc.exists) {
      logger.error("❌ Doctor not found!");
      return;
    }

    const doctorToken = doctorDoc.data().fcmToken;
    logger.info("📲 Doctor's FCM Token:", doctorToken);

    // Send notification
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

// ✅ V2 Syntax for sending notifications
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

      // Clean up after sending
      await snapshot.ref.delete();
      logger.info("🗑️ Notification document deleted after sending.");
    } catch (error) {
      logger.error("❌ Error sending push notification:", error);
    }
  }
);
