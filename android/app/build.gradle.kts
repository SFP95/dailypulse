plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dailypulse"
    compileSdk = 35 // Cambia esto a un valor fijo (34 es la última versión)
    ndkVersion = "27.0.12077973" // Versión fija en lugar de flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.dailypulse"
        minSdk = 23 // Cambia esto directamente a 23 (no uses flutter.minSdkVersion)
        targetSdk = 34 // Versión fija
        versionCode = 1 // Puedes usar valores fijos o variables
        versionName = "1.0.0"
    }


    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
