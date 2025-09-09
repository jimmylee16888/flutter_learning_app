plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ★ 新增：讀取 key.properties
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.popcard.app"
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
        applicationId = "com.popcard.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ★ 新增：release 簽章（用你自己的 keystore）
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] ?: "upload-keystore.jks")
            storePassword = (keystoreProperties["storePassword"] as String?)
            keyAlias = (keystoreProperties["keyAlias"] as String?)
            keyPassword = (keystoreProperties["keyPassword"] as String?)
        }
    }

    buildTypes {
        release {
            // ★ 變更：由 debug → release 簽章
            signingConfig = signingConfigs.getByName("release")

            // 可開啟以縮小包體（若遇到混淆問題可先關閉）
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // 預設即可
        }
    }
}

flutter {
    source = "../.."
}
