# Walkthrough - Prana Flutter Implementation

I have successfully transitioned the project to a Flutter codebase and implemented the core onboarding and authentication flow.

## Changes Made

### 1. Project Infrastructure
- **[NEW] [pubspec.yaml](file:///home/sreeju/AndroidStudioProjects/prana/pubspec.yaml)**: Configured with `http`, `flutter_secure_storage`, and `google_fonts`.
- **[NEW] [main.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/main.dart)**: Entry point with `PranaTheme` applied.

### 2. Theming & Design
- **[NEW] [colors.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/theme/colors.dart)**: Defined the Midnight Navy, Prana Teal, and Emergency Cyan palette.
- **[NEW] [theme.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/theme/theme.dart)**: Dark-mode-first theme configuration.

### 3. Authentication & Services
- **[NEW] [api_service.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/services/api_service.dart)**: Handles `login` (Phone) and `verifyOtp` calls.
- **[NEW] [storage_service.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/services/storage_service.dart)**: Manages JWT token persistence securely.

### 4. UI Screens
- **[NEW] [splash_screen.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/screens/splash_screen.dart)**: Branded entry screen.
- **[NEW] [onboarding_screen.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/screens/onboarding_screen.dart)**: Interactive 3-slide pager with "Medical Identity," "Phone-Independent," and "Access Control" themes.
- **[NEW] [otp_screen.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/screens/otp_screen.dart)**: Logic to route based on `is_new_user` status.
- **[NEW] [profile_screen.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/screens/profile_screen.dart)**: Collects health details for first-time users.

## Next Steps

> [!IMPORTANT]
> Since this environment does not have the Flutter SDK installed, you must run the following command in your terminal to generate the necessary platform folders:
> ```bash
> flutter create .
> ```

> [!TIP]
> After running `flutter create`, you can start the app on your emulator or device. The API calls currently point to a placeholder URL; make sure to update the base URL in `lib/services/api_service.dart` to your backend's IP.
