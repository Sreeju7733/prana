# Fix Flutter Build Error: CardTheme mismatch

The build is failing because `ThemeData.cardTheme` in `lib/theme/theme.dart` is being assigned a `CardTheme` object, but newer versions of Flutter (3.x) expect `CardThemeData`.

## Proposed Changes

### [Component Name] Theme Configuration

#### [MODIFY] [theme.dart](file:///home/sreeju/AndroidStudioProjects/prana/lib/theme/theme.dart)
- Replace `CardTheme` constructor call with `CardThemeData`.

## Verification Plan

### Automated Tests
- Run `/home/sreeju/.local/share/flutter/bin/flutter build bundle` to ensure Dart compilation succeeds.
- Run `cd android && ./gradlew :app:compileFlutterBuildDebug` to verify the Gradle task passes.

### Manual Verification
- None required as this is a build-time fix.
