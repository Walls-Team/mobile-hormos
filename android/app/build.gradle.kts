plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Cargar propiedades del keystore ANTES de android block
val keystoreFile = rootProject.file("../android/key.properties")
val keystoreProperties = mutableMapOf<String, String>()

if (keystoreFile.exists()) {
    keystoreFile.readLines().forEach { line ->
        if (line.isNotEmpty() && !line.startsWith("#")) {
            val parts = line.split("=", limit = 2)
            if (parts.size == 2) {
                val key = parts[0].trim()
                val value = parts[1].trim()
                keystoreProperties[key] = value
                println("Loaded keystore property: $key = ${if (key.contains("Password")) "***" else value}")
            }
        }
    }
} else {
    println("WARNING: android/key.properties not found at ${keystoreFile.absolutePath}")
}

android {
    namespace = "com.wallsdev.genius_hormo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]
            val storePass = keystoreProperties["storePassword"]
            val keyAlias = keystoreProperties["keyAlias"]
            val keyPass = keystoreProperties["keyPassword"]
            
            if (storeFilePath != null && storePass != null && keyAlias != null && keyPass != null) {
                val storeFileObj = file(storeFilePath)
                if (storeFileObj.exists()) {
                    this.storeFile = storeFileObj
                    this.storePassword = storePass
                    this.keyAlias = keyAlias
                    this.keyPassword = keyPass
                    println("✓ Signing config configured successfully")
                    println("  Store file: ${storeFileObj.absolutePath}")
                    println("  Key alias: $keyAlias")
                } else {
                    println("✗ ERROR: Keystore file not found at $storeFilePath")
                    println("  Absolute path: ${storeFileObj.absolutePath}")
                }
            } else {
                println("✗ ERROR: Missing keystore properties")
                println("  storeFile: $storeFilePath")
                println("  storePassword: ${if (storePass != null) "***" else "NULL"}")
                println("  keyAlias: $keyAlias")
                println("  keyPassword: ${if (keyPass != null) "***" else "NULL"}")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wallsdev.genius_hormo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
