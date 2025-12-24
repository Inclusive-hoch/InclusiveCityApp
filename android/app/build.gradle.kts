import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Leer la API Key de Google Maps desde local.properties
val keystorePropertiesFile = rootProject.file("local.properties")
val localProperties = Properties()
if (keystorePropertiesFile.exists()) {
    localProperties.load(keystorePropertiesFile.inputStream())
}

// Intentar leer desde .env si no está en local.properties
if (localProperties.getProperty("GOOGLE_MAPS_API_KEY") == null) {
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        envFile.forEachLine { line ->
            if (line.trim().startsWith("GOOGLE_MAPS_API_KEY=")) {
                val key = line.substringAfter("=").trim()
                if (key.isNotEmpty()) {
                    localProperties.setProperty("GOOGLE_MAPS_API_KEY", key)
                }
            }
        }
    }
}

android {
    namespace = "com.inclusiveCity.inclusivecity_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.inclusiveCity.inclusivecity_frontend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Pasar la API Key de Google Maps al AndroidManifest
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
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
