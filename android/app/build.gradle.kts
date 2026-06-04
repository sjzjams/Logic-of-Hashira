plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hashira.logic.fitness_log_app"
    compileSdk = flutter.compileSdkVersion
    // Sprint 2.2-C：锁定本机已安装的 NDK 28.2.13676358。
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hashira.logic.fitness_log_app"
        // Sprint 2.2-B 决策沿用：锁定 minSdk ≥ 24 防止 Flutter 默认值变化影响
        // NDK 28 / ncnn 预编译库的 ABI 兼容。Phase D 切到本地 ncnn 后仍保留。
        minSdk = 24
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Sprint 2.2-C：只打 arm64-v8a，与本机预编译 ncnn 一致。
        // abiFilters 是 MutableSet<String>，必须先 clear 再 addAll，避免叠加默认 ABI。
        ndk {
            abiFilters.clear()
            abiFilters.addAll(listOf("arm64-v8a"))
        }

        // Sprint 2.2-C：把 CMake 暴露给 externalNativeBuild。
        externalNativeBuild {
            cmake {
                // abiFilters 控制 *externalNativeBuild 编译哪些 ABI*。
                // 不加这条,Gradle 会按所有 ABI 各跑一遍 C++ 编译,armeabi-v7a
                // 没有对应的 ncnn 预编译库(只有 arm64-v8a),find_package 会报
                // "Could not find a configuration file for package ncnn that is compatible"。
                abiFilters += listOf("arm64-v8a")
                arguments += listOf(
                    "-DANDROID_STL=c++_static",
                    "-DANDROID_PLATFORM=android-24",
                )
                cppFlags += listOf("-std=c++17", "-fexceptions", "-frtti")
            }
        }
    }

    // Sprint 2.2-C：把 src/main/cpp/CMakeLists.txt 接进 Gradle。
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
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

dependencies {
    // Sprint 2.2-C Phase D:ML Kit Subject Segmentation 已被本地 YOLOv8-seg + ncnn 取代,
    // 不再依赖 play-services-mlkit-subject-segmentation。
}
