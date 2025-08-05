# Notifoo 📱

A modern productivity companion app that helps you manage notifications, track habits, focus with Pomodoro timers, and organize tasks efficiently. Built with Flutter and Material 3 design.

## ✨ Features

### 🔔 **Smart Notification Management**
- **Alert Manager**: Capture and organize notifications from all apps
- **Batch Reading**: Read notifications at your convenience
- **App Integration**: Direct app launching from notifications
- **Modern UI**: Beautiful Material 3 design with responsive layout
- **App Icons**: Proper app icons for 50+ popular applications
- **Smart Categorization**: Automatic app detection and categorization
- **Real-time Updates**: Live notification capture and processing

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

### 🎨 **Onboarding Experience**
- **Beautiful Splash Screen**: Animated logo with gradient design
- **Interactive Onboarding**: 5-page guided tour of app features
- **Smooth Transitions**: Elegant page transitions and animations
- **Skip Functionality**: Option to skip onboarding for experienced users

## 🎨 **Design Features**

### **Modern UI/UX**
- **Material 3 Design**: Latest Material Design principles
- **Responsive Layout**: Adapts to all mobile screen sizes
- **Color Schemes**: Dynamic theming with primary colors
- **Smooth Animations**: Hero animations and transitions
- **Card-Based Design**: Clean, organized information display
- **Gradient Icons**: Beautiful app icons with gradient backgrounds

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

### **Getting Started**
1. **Splash Screen**: Beautiful animated welcome screen
2. **Onboarding**: Complete the 5-page guided tour (or skip)
3. **Main App**: Access all features through bottom navigation

### **Alert Manager**
1. Tap "Start Listening" to capture notifications
2. Browse notifications by app category with proper app icons
3. Tap "Open App" to launch the original app
4. View detailed notification history
5. Enjoy smooth, non-flickering notification list

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
- **Cloud Storage**: Firebase Firestore with offline-first architecture
- **Data Sync**: Real-time synchronization between local and cloud

### **Key Components**
- **DatabaseHelper**: SQLite operations for tasks and habits
- **FirebaseService**: Cloud synchronization and authentication
- **ResponsiveHelper**: Dynamic sizing for different screens
- **Navigation**: Custom bottom bar and drawer
- **Authentication**: Google Sign-in integration
- **NotificationHelper**: Smart notification processing and categorization

## 📦 **Dependencies**

### **Core Dependencies**
```yaml
flutter_notification_listener: ^1.0.7
device_apps: ^2.2.0
url_launcher: ^6.1.14
hive: ^2.2.3
firebase_core: ^2.8.0
firebase_auth: ^4.2.6
cloud_firestore: ^4.8.4
google_sign_in: ^5.2.4
provider: ^6.0.2
shared_preferences: ^2.2.2
```

### **UI & Design**
```yaml
google_fonts: ^4.0.3
font_awesome_flutter: ^10.4.0
flutter_native_splash: ^2.1.0
```

### **Database & Storage**
```yaml
sqflite: ^2.0.2
path: ^1.8.0
hive_flutter: ^1.1.0
```

## 🎯 **Key Features Implemented**

### **✅ Completed Features**
- [x] Modern Material 3 UI design
- [x] Beautiful splash screen with animations
- [x] Interactive onboarding experience
- [x] Responsive bottom navigation
- [x] Comprehensive sidebar navigation
- [x] Alert Manager with notification capture
- [x] Smart app icon detection (50+ apps)
- [x] Fixed notification list flickering
- [x] Habit tracking with progress visualization
- [x] Pomodoro timer with animations
- [x] Task management with filtering
- [x] Insights page with heatmap
- [x] User profile with statistics
- [x] Google Sign-in integration
- [x] Settings page with preferences
- [x] SQLite database integration
- [x] Firebase Firestore integration
- [x] Offline-first architecture
- [x] Real-time data synchronization
- [x] Responsive design for all screen sizes

### **🔄 In Progress**
- [ ] Push notifications
- [ ] Advanced analytics dashboard
- [ ] Export/import functionality

### **📋 Planned Features**
- [ ] Cloud backup and sync
- [ ] Advanced habit analytics
- [ ] Social features and sharing
- [ ] Custom themes and personalization
- [ ] Widget support
- [ ] Wear OS integration

## 🐛 **Recent Fixes**

### **✅ Fixed Issues**
- [x] **Notification List Flickering**: Added proper ValueKey and optimized rebuilds
- [x] **App Icons Not Showing**: Implemented comprehensive app icon mapping
- [x] **Unknown App Issue**: Enhanced app detection with 50+ app mappings
- [x] **Excessive Logging**: Reduced debug output for better performance
- [x] **Splash Screen**: Added beautiful animated splash screen
- [x] **Onboarding Flow**: Created 5-page interactive onboarding
- [x] **Performance Issues**: Optimized async operations and state management

### **🔧 Technical Improvements**
- [x] **Better Error Handling**: Improved error states and user feedback
- [x] **Memory Management**: Proper disposal of controllers and timers
- [x] **Code Organization**: Cleaner, more maintainable code structure
- [x] **Performance Optimization**: Reduced unnecessary rebuilds and logging

## 🚀 **Backend Status**

### **✅ Fully Functional**
- **Firebase Cloud Firestore**: Complete integration with offline-first
- **Local SQLite Database**: Robust local data persistence
- **Real-time Sync**: Automatic data synchronization
- **Authentication**: Google Sign-in with Firebase Auth
- **Conflict Resolution**: Smart data conflict handling

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
- Test on multiple screen sizes
- Follow Flutter best practices

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

*Version 2.0.0 - Modern Productivity Companion with Enhanced UX*
