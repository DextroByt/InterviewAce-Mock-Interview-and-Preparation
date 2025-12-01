plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Google Services plugin
}

android {
    namespace = "com.example.interviewace" // Replace with your actual package name
    compileSdk = 35 // Or your desired compile SDK version

    defaultConfig {
        applicationId = "com.example.interviewace" // Replace with your actual application ID
        minSdk = 26
        targetSdk = 34 // Or your desired target SDK version
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for release builds.
            // Signing with the debug keys for now, so `flutter run --release`.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true // This enables R8 for code shrinking
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        // Updated to Java 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        // Updated to Java 17
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // Use the latest stable version
    // Add the dependency for the Firebase Authentication library
    implementation("com.google.firebase:firebase-auth")
    // Add the dependency for the Cloud Firestore library
    implementation("com.google.firebase:firebase-firestore")
}
