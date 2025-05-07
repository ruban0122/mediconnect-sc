# Stripe keep rules to prevent R8 from removing required classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Optional: keep Stripe's push provisioning classes (if somehow used)
-keep class com.stripe.android.pushProvisioning.** { *; }
