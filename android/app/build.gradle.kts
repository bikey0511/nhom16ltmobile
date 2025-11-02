plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // 🔥 BẮT BUỘC: Plugin Google Services để Firebase hoạt động
    id("com.google.gms.google-services")
    // Plugin Flutter
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vd5_tanphat"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.vd5_tanphat"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dùng để hỗ trợ một số hàm Java 8 cho Android cũ
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
