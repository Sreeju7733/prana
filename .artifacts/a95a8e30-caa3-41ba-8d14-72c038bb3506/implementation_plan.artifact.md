# Implementation Plan - Fix Gradle Build Not Found Error

The user is encountering a "Directory does not contain a Gradle build" error during sync in a Flutter project. This occurs because the IDE is configured to look for Gradle files in the project root instead of the `android/` directory.

## User Review Required

> [!IMPORTANT]
> This project is a Flutter project. The Gradle build is located in the `android/` directory. The fix involves reconfiguring the IDE to recognize `android/` as the Gradle root.
>
> There is also a secondary issue with NDK installation that might persist after fixing the project structure. I will attempt to resolve this as well.

## Proposed Changes

### IDE Configuration

#### [MODIFY] [.idea/gradle.xml](file:///home/sreeju/AndroidStudioProjects/prana/.idea/gradle.xml)
- Update `externalProjectPath` to point to `$PROJECT_DIR$/android` instead of `$PROJECT_DIR$`. (Already applied)

### Android Build Configuration

#### [MODIFY] [android/app/build.gradle.kts](file:///home/sreeju/AndroidStudioProjects/prana/android/app/build.gradle.kts)
- If the NDK installation continues to fail, I will try to explicitly set the `ndkVersion` to a version already present on disk to avoid the auto-installation attempt.

## Verification Plan

### Automated Tests
- Run `gradle_sync` to verify that the "Gradle build not found" error is resolved.
- Run a simple Gradle task like `:app:help` to ensure the project structure is correctly recognized.

### Manual Verification
- Verify that the Android modules appear in the Project view in Android Studio.
