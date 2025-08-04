# Notifoo 📱

A modern notification management app that helps you batch and read notifications later, improving focus and productivity.

## Features ✨

- **Smart Notification Capture**: Automatically captures notifications from all your apps
- **Batch Reading**: Read all your notifications at once instead of being interrupted
- **App Integration**: Tap to open the original app directly from notifications
- **Modern UI**: Beautiful Material 3 design with dark theme
- **Habit Tracking**: Built-in habit tracking to improve productivity
- **Pomodoro Timer**: Focus timer to enhance productivity
- **Task Management**: Organize and manage your tasks efficiently

## Screenshots 📸

*Screenshots will be added here*

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=2.12.0)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/notifoo.git
cd notifoo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage 📖

1. **Start Listening**: Tap the play button to start capturing notifications
2. **View Notifications**: Browse captured notifications by app
3. **Open Apps**: Tap "Open App" to launch the original app
4. **View Details**: Tap "View Details" to see all notifications from an app

## Permissions 🔐

The app requires the following permissions:
- **Notification Access**: To capture and read notifications
- **Internet**: For Google Sign-in and Firebase features

## Architecture 🏗️

- **Frontend**: Flutter with Material 3 design
- **State Management**: Provider pattern
- **Database**: SQLite with Hive for local storage
- **Authentication**: Google Sign-in with Firebase
- **Notifications**: flutter_notification_listener plugin

## Dependencies 📦

- `flutter_notification_listener`: Notification capture
- `device_apps`: App information and launching
- `url_launcher`: Opening apps and URLs
- `hive`: Local data storage
- `firebase_core`: Firebase integration
- `google_sign_in`: Authentication
- `provider`: State management

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

If you have any questions or need help, please open an issue on GitHub.

---

Made with ❤️ using Flutter
