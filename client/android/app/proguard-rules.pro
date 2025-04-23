# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Basic Flutter rules (optional, for safety)
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**