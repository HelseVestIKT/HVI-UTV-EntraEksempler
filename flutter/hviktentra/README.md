# hviktentra

## Demo Entra/AD-pålogging

Not functional without replacing values in:
- environment.dart
- android/app/build.gradle
- ios/Runner/Info.plist

Packages:
- [flutter_appauth](https://pub.dev/packages/flutter_appauth) for authentication
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for storing tokens
- [get](https://pub.dev/packages/get) (Not required) For state management/DI
- [dio](https://pub.dev/packages/dio)(Not required) Used for intercepting HTTP requests and adding an auth header

Note: Some setup is required for flutter_appauth, described on it's [pub.dev page](https://pub.dev/packages/flutter_appauth)