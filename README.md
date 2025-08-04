# Notifoo 📱

A modern productivity companion app that helps you manage notifications, track habits, focus with Pomodoro timers, and organize tasks efficiently. Built with Flutter and Material 3 design.

## ✨ Features

### 🔔 **Smart Notification Management**
- **Alert Manager**: Capture and organize notifications from all apps
- **Batch Reading**: Read notifications at your convenience
- **App Integration**: Direct app launching from notifications
- **Modern UI**: Beautiful Material 3 design with responsive layout

### 🎯 **Habit Tracking**
- **Progress Visualization**: Track daily habit completion rates
- **Interactive Cards**: Mark habits complete/incomplete with visual feedback
- **Statistics Dashboard**: View completion rates and streaks
- **Empty State**: Guided experience for new users

### ⏱️ **Pomodoro Timer**
- **Focus Sessions**: 25-minute focus timer with break periods
- **Visual Progress**: Large radial progress bar with animations
- **Glowing Effects**: Breathing and glowing animations for engagement
- **Session Tracking**: Monitor focus time and completed sessions

### 📋 **Task Management**
- **Smart Organization**: Categorize tasks by type and priority
- **Progress Tracking**: Visual completion rates and statistics
- **Filter System**: View all, pending, or completed tasks
- **Color Coding**: Different colors for different task types

### 📊 **Insights & Analytics**
- **Progress Heatmap**: Weekly activity visualization
- **Completion Rates**: Task and habit completion statistics
- **Focus Metrics**: Pomodoro session tracking
- **Achievement System**: Badges and streaks

### 👤 **User Profile**
- **Comprehensive Dashboard**: User statistics and achievements
- **Activity Timeline**: Recent actions and progress
- **Achievement Badges**: Recognition for milestones
- **Account Settings**: Profile management and preferences

### 🔐 **Authentication**
- **Google Sign-In**: Secure authentication with Firebase
- **Guest Mode**: Use app without account
- **Profile Sync**: User data synchronization

## 🎨 **Design Features**

### **Modern UI/UX**
- **Material 3 Design**: Latest Material Design principles
- **Responsive Layout**: Adapts to all mobile screen sizes
- **Color Schemes**: Dynamic theming with primary colors
- **Smooth Animations**: Hero animations and transitions
- **Card-Based Design**: Clean, organized information display

### **Navigation**
- **Bottom Navigation**: Quick access to main features
- **Sidebar Navigation**: Comprehensive menu with sections
- **Responsive Design**: Optimized for all device resolutions
- **Hero Tags**: Proper animation handling

## 📱 **Screenshots**

*Screenshots will be added here*

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android device or emulator (API 21+)
- Google Services (for authentication)

### **Installation**

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/notifoo.git
cd notifoo
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase (Optional):**
   - Add your `google-services.json` to `android/app/`
   - Update Firebase configuration in `lib/main.dart`

4. **Run the app:**
```bash
flutter run
```

## 📖 **Usage Guide**

### **Alert Manager**
1. Tap "Start Listening" to capture notifications
2. Browse notifications by app category
3. Tap "Open App" to launch the original app
4. View detailed notification history

### **Habit Tracker**
1. Add new habits with custom categories
2. Mark habits complete daily
3. Track progress with visual indicators
4. View completion statistics

### **Pomodoro Timer**
1. Start a 25-minute focus session
2. Take 5-minute breaks between sessions
3. Track your focus time
4. Monitor session completion rates

### **Task Management**
1. Create tasks with categories and priorities
2. Set repetition counts
3. Filter tasks by status
4. Track completion progress

### **Profile & Insights**
1. View your productivity statistics
2. Check achievement badges
3. Review recent activity
4. Manage account settings

## 🔐 **Permissions**

The app requires the following permissions:
- **Notification Access**: Capture and read notifications
- **Internet**: Google Sign-in and Firebase features
- **Storage**: Local data persistence

## 🏗️ **Architecture**

### **Frontend**
- **Framework**: Flutter 3.x
- **Design**: Material 3 with custom theming
- **State Management**: Provider pattern
- **Navigation**: Custom bottom navigation and drawer

### **Backend & Storage**
- **Local Database**: SQLite with Hive for caching
- **Authentication**: Firebase Auth with Google Sign-in
- **Cloud Storage**: Firebase (planned for future)

### **Key Components**
- **DatabaseHelper**: SQLite operations for tasks and habits
- **ResponsiveHelper**: Dynamic sizing for different screens
- **Navigation**: Custom bottom bar and drawer
- **Authentication**: Google Sign-in integration

## 📦 **Dependencies**

### **Core Dependencies**
```yaml
flutter_notification_listener: ^1.0.0
device_apps: ^2.2.0
url_launcher: ^6.1.0
hive: ^2.2.3
firebase_core: ^2.15.0
google_sign_in: ^6.1.0
provider: ^6.0.5
```

### **UI & Design**
```yaml
google_fonts: ^5.1.0
font_awesome_flutter: ^10.5.0
```

### **Database & Storage**
```yaml
sqflite: ^2.2.8+4
path: ^1.8.3
```

## 🎯 **Key Features Implemented**

### **✅ Completed Features**
- [x] Modern Material 3 UI design
- [x] Responsive bottom navigation
- [x] Comprehensive sidebar navigation
- [x] Alert Manager with notification capture
- [x] Habit tracking with progress visualization
- [x] Pomodoro timer with animations
- [x] Task management with filtering
- [x] Insights page with heatmap
- [x] User profile with statistics
- [x] Google Sign-in integration
- [x] Settings page with preferences
- [x] SQLite database integration
- [x] Responsive design for all screen sizes

### **🔄 In Progress**
- [ ] Firebase Cloud Firestore integration
- [ ] Real-time data synchronization
- [ ] Push notifications
- [ ] Advanced analytics

### **📋 Planned Features**
- [ ] Cloud backup and sync
- [ ] Advanced habit analytics
- [ ] Social features and sharing
- [ ] Custom themes and personalization
- [ ] Export/import functionality

## 🐛 **Known Issues**

- Firebase initialization shows sandbox mode warnings (expected in development)
- Some frame drops during IME animations (Android system issue)
- Hero animation warnings resolved with unique tags

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Material 3 design principles
- Use responsive design patterns
- Implement proper error handling
- Add loading states for async operations
- Maintain consistent color schemes

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 **Support**

- **Issues**: Report bugs and feature requests on GitHub
- **Discussions**: Join community discussions
- **Documentation**: Check the wiki for detailed guides

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Firebase team for backend services
- Open source community for dependencies

---

**Made with ❤️ using Flutter**

*Version 1.0.0 - Modern Productivity Companion*
