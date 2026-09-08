# Keep Google services
-keep class com.google.firebase.** { *; }
-keep class com.alexa.artclasses.** { *; }

# Flutter engine
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase ML / Analytics
-keepattributes *Annotation*
-keepattributes Signature