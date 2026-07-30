# Implementation Plan - Prana Medical App Onboarding & Auth Flow

Implement a modern Android application for "Prana" using Jetpack Compose, focusing on the splash screen, onboarding flow, and authentication (Phone/OTP).

## User Review Required

> [!IMPORTANT]
> The current project is a plain Java project (`src/Main.java`). I will propose converting it to a standard Android Gradle project structure.

> [!NOTE]
> I will use Jetpack Compose for the UI as it is the modern standard for Android development, ensuring the app is responsive and matches the dark theme requirements.

## Proposed Changes

### 1. Project Infrastructure
- Convert the project to an Android module.
- Add necessary dependencies: `Compose`, `Navigation-Compose`, `ViewModel-Compose`, `Hilt` (optional but recommended), `Retrofit/Ktor`.

### 2. Theming & Resources
- **Colors**: Define the Prana color palette (Midnight Navy background, Teal/Cyan accents).
- **Typography**: Define accessible fonts for high readability.
- **Icons**: Use Material Icons or specific medical emojis as placeholders for 🛡️, 📱, 🔒.

### 3. Navigation & Flow
- **Splash Screen**: Logo display using the `SplashScreen` API.
- **Onboarding (Pager)**: 3-step introduction with "Continue" and "Start Setup" buttons.
- **Auth Flow**:
    - `LoginScreen`: Phone number entry.
    - `OtpScreen`: 6-digit OTP entry + verification logic.
    - `ProfileSetupScreen`: (Only for `is_new_user: true`) Name, Blood Group, Weight, Height.
- **Dashboard**: Target screen after successful auth.

### 4. Component Details

#### [NEW] [Theme.kt](file:///home/sreeju/AndroidStudioProjects/prana/app/src/main/java/com/prana/ui/theme/Theme.kt)
Define the `PranaTheme` with the specified dark mode colors.

#### [NEW] [OnboardingScreen.kt](file:///home/sreeju/AndroidStudioProjects/prana/app/src/main/java/com/prana/ui/onboarding/OnboardingScreen.kt)
Implement a `HorizontalPager` with the 3 onboarding slides.

#### [NEW] [AuthViewModel.kt](file:///home/sreeju/AndroidStudioProjects/prana/app/src/main/java/com/prana/ui/auth/AuthViewModel.kt)
Handle phone number submission, OTP verification, and navigation logic based on the `is_new_user` flag.

## Verification Plan

### Automated Tests
- Unit tests for `AuthViewModel` to verify navigation state based on API response.
- Compose tests for `OnboardingScreen` to ensure pager swipe and button clicks work.

### Manual Verification
- Deploy to emulator/device.
- Verify color contrast and readability in dark mode.
- Walk through the full onboarding and login flow.
