plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // any other plugins you already had
}

android {
    namespace = "com.example.myapp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    // add your Firebase dependencies later, e.g. Firebase Auth, Firestore, etc.
}

// 🔥 Enable Firebase services
apply(plugin = "com.google.gms.google-services")
