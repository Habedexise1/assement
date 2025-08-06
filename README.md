# TaskMaster AI - Flutter Task Management App

A modern, AI-powered task management application built with Flutter that helps users organize their projects and tasks efficiently with intelligent features and role-based access control.

## 🚀 Features

### Core Features
- **Authentication System**: Email & password login/registration with session management
- **Role-Based Access Control**: Three user roles (User, Manager, Admin) with different dashboards
- **Project Management**: Create, edit, and delete projects with color themes
- **Task Management**: Full CRUD operations for tasks with priorities and due dates
- **Offline Support**: Complete offline functionality with Hive local storage
- **Mock API Integration**: Simulated backend with loading states and error handling

### Role-Based Dashboards
- **User Dashboard**: Basic task management with AI assistant features
- **Manager Dashboard**: Team analytics, project oversight, and team management
- **Admin Dashboard**: System administration, user management, and system overview

### AI Integration
- **AI Task Assistant**: Generate tasks from natural language prompts
- **Smart Task Rescheduler**: AI-powered suggestions for overdue tasks
- **Task Insights**: AI-generated productivity insights and recommendations

### Bonus Features
- **Push Notifications**: Local notifications for task reminders and due dates
- **Dark Mode Support**: Complete theme switching functionality
- **Smooth Animations**: Micro-interactions and animated UI elements
- **Comprehensive Testing**: Unit and widget tests for core functionality

## 📱 Screenshots

*Screenshots will be added here*

## 🏗️ Architecture

The app follows a clean, layered architecture:

```
lib/
├── models/          # Data models (User, Project, Task)
├── providers/       # State management (AuthProvider, TaskProvider)
├── screens/         # UI screens and navigation
│   ├── auth/        # Authentication screens with role selection
│   └── dashboard/   # Role-based dashboard screens
│       └── tabs/    # Role-specific tab components
├── services/        # Business logic and API services
├── utils/           # Constants, themes, and utilities
└── widgets/         # Reusable UI components
```

### State Management
- **Provider Pattern**: Used for state management across the app
- **ChangeNotifier**: For reactive UI updates
- **Hive**: Local data persistence with offline support

### Data Layer
- **Hive Database**: Local storage for projects and tasks
- **SharedPreferences**: Session management and user preferences
- **Mock Services**: Simulated API calls with realistic delays

## 🛠️ Setup Instructions

### Prerequisites
- Flutter 3.x or higher
- Dart 3.x or higher
- Android Studio / VS Code
- iOS Simulator (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/taskmaster-ai.git
   cd taskmaster-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Create environment file**
   ```bash
   cp .env.example .env
   ```
   Add your API keys to the `.env` file:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: 21
- Target SDK: 33
- No additional setup required

#### iOS
- Minimum iOS version: 12.0
- Add notification permissions to `Info.plist`:
  ```xml
  <key>NSUserNotificationUsageDescription</key>
  <string>We need to send you task reminders and due date notifications.</string>
  ```

## 👥 Role-Based Access Control

### User Roles

#### 1. **User** (Default Role)
- **Dashboard**: Home, Projects, AI Assistant, Profile
- **Features**: 
  - Basic task management
  - AI-powered task generation
  - Personal project organization
  - Task completion tracking

#### 2. **Manager**
- **Dashboard**: Analytics, Projects, Team, Profile
- **Features**:
  - Team performance analytics
  - Project oversight
  - Team member management
  - Task assignment capabilities
  - Team communication tools

#### 3. **Admin**
- **Dashboard**: Admin Dashboard, Projects, Users, Profile
- **Features**:
  - System administration
  - User management (add, edit, delete users)
  - System overview and statistics
  - Full access to all features
  - System settings and configuration

### Role Selection During Signup
Users can select their role during the registration process:
- Beautiful role selection cards with descriptions
- Visual indicators for each role
- Role-specific feature previews
- Easy role switching during signup

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_provider_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Coverage

The app includes comprehensive testing:

- **Unit Tests**: 
  - `test/unit/auth_provider_test.dart` - Authentication and role-based logic
  - `test/unit/task_provider_test.dart` - Task and project management

- **Widget Tests**:
  - `test/widget/login_screen_test.dart` - Login screen interactions
  - `test/widget/projects_tab_test.dart` - Project management UI
  - `test/widget_test.dart` - Basic app functionality

### Test Features
- Authentication flow testing
- Role-based functionality testing
- CRUD operations for projects and tasks
- UI interaction testing
- Form validation testing
- Error handling scenarios

## 🎯 AI Prompt Examples

### Task Generation Prompts
```
"Plan my week with 3 work tasks and 2 wellness tasks"
"Create a study schedule for my Flutter course"
"Generate tasks for my home renovation project"
"Plan my daily routine with productivity tasks"
"Create tasks for my fitness goals this month"
```

### Smart Rescheduling
- Tap "Suggest New Time" on overdue tasks
- AI analyzes your schedule and suggests optimal times
- Considers task priority and current workload

## 📦 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `provider`: State management
- `hive`: Local database
- `shared_preferences`: Session storage
- `http`: API communication

### UI Dependencies
- `flutter_slidable`: Swipeable list items
- `flutter_local_notifications`: Push notifications
- `intl`: Date formatting
- `timezone`: Timezone handling

### Development Dependencies
- `flutter_test`: Testing framework
- `hive_generator`: Code generation
- `build_runner`: Build tools
- `flutter_lints`: Code quality

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```
OPENAI_API_KEY=your_openai_api_key
GEMINI_API_KEY=your_gemini_api_key
```

### Notification Settings
- Task reminders: 1 hour before due date
- Due date notifications: On the due date
- Overdue alerts: Daily reminders for overdue tasks

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for the excellent local database solution
- Provider team for state management
- OpenAI and Google for AI APIs

## 📞 Support

For support, email support@taskmaster-ai.com or create an issue in the repository.

---

**Built with ❤️ using Flutter**
