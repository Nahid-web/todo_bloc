# Todo BLoC - Flutter Clean Architecture

A comprehensive Flutter todo application built with BLoC pattern and Clean Architecture principles. This project demonstrates best practices for state management, dependency injection, and testing in Flutter applications.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a feature-based folder structure:

```
lib/
├── core/                    # Core functionality
│   ├── di/                 # Dependency injection
│   ├── error/              # Error handling
│   ├── usecases/           # Base use case classes
│   └── utils/              # Utility functions
├── features/
│   └── todo/               # Todo feature
│       ├── data/           # Data layer
│       │   ├── datasources/    # Local data sources
│       │   ├── models/         # Data models
│       │   └── repositories/   # Repository implementations
│       ├── domain/         # Domain layer
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/   # Presentation layer
│           ├── bloc/           # BLoC state management
│           ├── pages/          # UI screens
│           └── widgets/        # Reusable widgets
└── shared/                 # Shared components
    ├── utils/              # Shared utilities
    └── widgets/            # Shared widgets
```

## 🚀 Features

### Core Functionality

- ✅ **Create** new todos with title and description
- ✅ **Read** and display todos in a list
- ✅ **Update** todo details and completion status
- ✅ **Delete** todos with confirmation dialog
- ✅ **Search** todos by title and description
- ✅ **Toggle** completion status
- ✅ **Undo** delete operations

### UI/UX Features

- 🎨 **Material Design 3** components
- 📱 **Responsive design** for different screen sizes
- 🔍 **Search functionality** with real-time filtering
- ⚡ **Loading states** and error handling
- 🔄 **Pull-to-refresh** support
- 📝 **Form validation** with user feedback
- 🗑️ **Confirmation dialogs** for destructive actions

### Technical Features

- 🏛️ **Clean Architecture** implementation
- 🔄 **BLoC pattern** for state management
- 💉 **Dependency injection** with GetIt
- 💾 **Local storage** with SharedPreferences
- 🧪 **Unit and widget tests**
- 📊 **Error handling** with Either pattern
- 🔧 **Form validation** with flutter_form_builder

## 📦 Dependencies

### Core Dependencies

- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `shared_preferences` - Local storage
- `equatable` - Value equality
- `dartz` - Functional programming (Either pattern)
- `uuid` - Unique ID generation

### UI Dependencies

- `flutter_form_builder` - Form building and validation
- `form_builder_validators` - Form validation rules
- `intl` - Internationalization and date formatting

### Development Dependencies

- `bloc_test` - BLoC testing utilities
- `mocktail` - Mocking for tests
- `flutter_test` - Testing framework

## 🛠️ Setup and Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd todo_bloc
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**

   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

## 🧪 Testing

The project includes comprehensive tests:

- **Unit Tests**: Domain entities, use cases, and data models
- **Widget Tests**: UI components and user interactions
- **BLoC Tests**: State management logic

Run tests with:

```bash
flutter test
```

## 📱 Screens

### 1. Todo List Screen

- Displays all todos in a scrollable list
- Search functionality in the app bar
- Pull-to-refresh support
- Floating action button to add new todos
- Delete confirmation with undo functionality

### 2. Add/Edit Todo Screen

- Form with title and description fields
- Real-time validation
- Save/Update functionality
- Material Design 3 components

### 3. Todo Detail Screen

- Detailed view of individual todo
- Toggle completion status
- Edit and delete options
- Formatted creation and update dates

## 🔧 State Management

The app uses **BLoC pattern** with three main BLoCs:

### TodoListBloc

- Manages the list of todos
- Handles search functionality
- Manages delete and restore operations
- Handles completion status toggling

### TodoFormBloc

- Manages add/edit todo forms
- Handles form validation
- Manages form submission

### TodoDetailBloc

- Manages individual todo details
- Handles todo updates and deletion
- Manages loading states

## 💾 Data Persistence

Data is persisted locally using **SharedPreferences** with JSON serialization:

- Todos are stored as JSON strings
- Automatic serialization/deserialization
- CRUD operations with error handling

## 🎯 Key Design Patterns

1. **Repository Pattern**: Abstracts data sources
2. **Use Case Pattern**: Encapsulates business logic
3. **BLoC Pattern**: Manages application state
4. **Dependency Injection**: Manages object dependencies
5. **Either Pattern**: Handles success/failure scenarios

## 🚀 Getting Started

1. Launch the app
2. Tap the **+** button to create your first todo
3. Fill in the title (required) and description (optional)
4. Tap **Save** to add the todo
5. Use the search icon to filter todos
6. Tap on any todo to view details
7. Use the checkbox to mark todos as complete
8. Swipe or use the delete button to remove todos
9. Use **Undo** to restore accidentally deleted todos

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   t o d o _ b l o c 
 
 
