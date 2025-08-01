# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep Google Pay classes
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Keep Google Play Services (minimal for maps)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Google Maps - Basic functionality with markers
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Google Maps model classes (for markers)
-keep class com.google.android.gms.maps.model.** { *; }

# Google Play Core (FIX FOR YOUR ERROR)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**

# Flutter Play Store Split Application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep native methods (required for maps rendering)
-keepclasseswithmembers class * {
    native <methods>;
}

# Flutter related classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Keep Flutter Google Maps plugin
-keep class io.flutter.plugins.googlemaps.** { *; }