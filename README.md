# 📱 Todo BLoC - Advanced Flutter Todo Application

A comprehensive, production-ready Flutter todo application built with Clean Architecture, BLoC pattern, and Firebase integration. This project demonstrates modern Flutter development practices with robust state management, offline support, and comprehensive user management features.

## ✨ Features

### 🎯 Core Todo Management
- ✅ **Complete CRUD Operations** - Create, read, update, delete todos with soft delete support
- 🏷️ **Enhanced Todo Properties** - Title, description, due dates, priority levels, categories, and tags
- 📊 **Priority System** - Low, Medium, High, and Urgent priority levels with visual indicators
- 🗂️ **Category Organization** - Personal, Work, Shopping, Health, Education, and Other categories
- 🔍 **Advanced Search & Filtering** - Search by text, filter by category, priority, due date, and completion status
- 📅 **Due Date Management** - Visual indicators for overdue and due-soon items
- 🗑️ **Soft Delete & Restore** - Safely delete and restore todos with deletion tracking

### 👤 User Management & Authentication
- 🔐 **Firebase Authentication** - Email/password registration and login
- 👻 **Guest Access** - Anonymous authentication for quick access
- 👤 **User Profiles** - Complete profile management with display names, bio, and profile pictures
- 🖼️ **Profile Pictures** - Upload, update, and delete profile pictures with Firebase Storage
- 🔒 **Account Security** - Password updates, email verification, and account deletion
- 💾 **Session Persistence** - Secure user session management

### 🎨 User Experience
- 🌙 **Dark/Light Theme** - Complete theme switching with system preference support
- 📱 **Material Design 3** - Modern UI following Google's latest design guidelines
- 🧭 **Bottom Navigation** - Intuitive navigation between Dashboard, Todos, and Settings
- 📊 **Dashboard** - Statistics and quick actions (structure ready for implementation)
- 🔄 **Offline Support** - Local caching with SharedPreferences for offline functionality
- 📱 **Responsive Design** - Optimized for various screen sizes

### 🏗️ Technical Architecture
- 🧱 **Clean Architecture** - Strict separation of data, domain, and presentation layers
- 🎯 **BLoC Pattern** - flutter_bloc for comprehensive state management
- 🔥 **Firebase Integration** - Firestore, Authentication, and Storage
- 💉 **Dependency Injection** - GetIt with proper DI container setup
- ⚠️ **Error Handling** - Comprehensive Failure classes with Either pattern
- 📝 **Comprehensive Logging** - Structured logging with categories and levels
- 🌐 **Network Connectivity** - Internet connection checking and handling

## 🏗️ Architecture Overview

This application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality and shared utilities
│   ├── auth/               # Authentication service
│   ├── constants/          # App constants and configurations
│   ├── di/                 # Dependency injection container
│   ├── error/              # Error handling (Failures, Exceptions)
│   ├── logging/            # Centralized logging system
│   ├── network/            # Network connectivity checking
│   ├── theme/              # App theming and Material Design 3
│   └── usecases/           # Base use case classes
├── features/               # Feature-based organization
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data sources, repositories, models
│   │   ├── domain/         # Entities, repositories, use cases
│   │   └── presentation/   # BLoC, pages, widgets
│   ├── profile/            # User profile management
│   ├── todo/               # Todo management
│   ├── settings/           # App settings
│   ├── dashboard/          # Dashboard and statistics
│   └── navigation/         # Bottom navigation
└── shared/                 # Shared widgets and utilities
```

### 🎯 BLoC Pattern Implementation
- **AuthBloc** - Authentication state management
- **ProfileBloc** - User profile operations
- **TodoListBloc** - Todo list management
- **TodoDetailBloc** - Individual todo operations
- **TodoFormBloc** - Todo creation and editing
- **ThemeBloc** - Theme switching and persistence

### 🔥 Firebase Integration
- **Firestore** - Real-time database for todos and user profiles
- **Authentication** - User registration, login, and session management
- **Storage** - Profile picture uploads and management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project with Firestore, Authentication, and Storage enabled
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/todo_bloc.git
   cd todo_bloc
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firestore Database, Authentication (Email/Password and Anonymous), and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Configure Firebase**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage Guide

### 🔐 Authentication
1. **Sign Up** - Create a new account with email and password
2. **Sign In** - Login with existing credentials
3. **Guest Access** - Use anonymous authentication for quick access
4. **Profile Setup** - Complete your profile with display name, bio, and profile picture

### 📝 Todo Management
1. **Create Todos** - Add new todos with title, description, due date, priority, and category
2. **Organize** - Use categories and tags to organize your todos
3. **Prioritize** - Set priority levels with visual indicators
4. **Search & Filter** - Find todos quickly with advanced search and filtering
5. **Track Progress** - Monitor overdue and due-soon items

### ⚙️ Settings & Customization
1. **Theme** - Switch between light and dark themes
2. **Profile** - Update your profile information and picture
3. **Account** - Manage account settings and security

## 🛠️ Technologies Used

### Frontend
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **Material Design 3** - Google's latest design system

### State Management
- **flutter_bloc** - Business Logic Component pattern
- **equatable** - Value equality for Dart classes

### Backend & Database
- **Firebase Firestore** - NoSQL cloud database
- **Firebase Authentication** - User authentication service
- **Firebase Storage** - File storage service

### Architecture & Patterns
- **Clean Architecture** - Separation of concerns
- **Repository Pattern** - Data access abstraction
- **Either Pattern** - Functional error handling
- **Dependency Injection** - GetIt for DI container

### Additional Packages
- **dartz** - Functional programming utilities
- **shared_preferences** - Local data persistence
- **image_picker** - Image selection from gallery/camera
- **intl** - Internationalization and date formatting
- **flutter_form_builder** - Advanced form building
- **internet_connection_checker** - Network connectivity checking

## 📊 Project Structure

### Data Layer
- **Models** - Data transfer objects with JSON serialization
- **Data Sources** - Local (SharedPreferences) and Remote (Firebase) data sources
- **Repositories** - Implementation of domain repository contracts

### Domain Layer
- **Entities** - Core business objects
- **Repositories** - Abstract repository contracts
- **Use Cases** - Business logic operations

### Presentation Layer
- **BLoC** - State management and business logic
- **Pages** - Screen implementations
- **Widgets** - Reusable UI components

## 🐛 Known Issues & Limitations

### Current Issues
- Some deprecated Flutter APIs need updating (withOpacity → withValues)
- Email verification feature is not fully implemented
- Dashboard statistics need implementation
- Some logging calls need signature updates

### Planned Improvements
- Push notifications for due dates
- Data export/import functionality
- Advanced todo templates
- Collaboration features
- Widget for home screen

## 🗺️ Future Roadmap

### Phase 1 - Core Improvements
- [ ] Complete dashboard implementation with statistics
- [ ] Implement push notifications
- [ ] Add data export/import features
- [ ] Complete email verification system

### Phase 2 - Advanced Features
- [ ] Todo templates and recurring tasks
- [ ] Collaboration and sharing
- [ ] Advanced analytics and insights
- [ ] Widget for home screen

### Phase 3 - Platform Expansion
- [ ] Web support optimization
- [ ] Desktop support (Windows, macOS, Linux)
- [ ] API for third-party integrations

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Clean Architecture principles
- Write comprehensive tests for new features
- Update documentation for significant changes
- Follow Flutter and Dart style guidelines
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- Material Design team for the design system
- Open source community for the excellent packages

---

**Built with ❤️ using Flutter and Firebase**

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/yourusername/todo_bloc).
