# Mind Map AI - Flutter Web with Excalidraw Integration

A professional Flutter web application that integrates with a self-hosted Excalidraw server for creating interactive mind maps with AI assistance. Features include conditional iframe management, persistent storage, and a beautiful professional toolbar interface.

## 🚀 Features

- **Interactive Mind Mapping**: Self-hosted Excalidraw integration for creating diagrams
- **AI Assistant**: Smart insights and assistance for your mind maps
- **Professional Toolbar**: Advanced grid-based interface with gradient designs
- **Smart UI Management**: Conditional iframe replacement during SnackBar interactions
- **Persistent Storage**: Local storage and backend synchronization
- **Real-time Communication**: PostMessage API for Flutter-Excalidraw communication
- **Professional Design**: Modern gradient UI with Material 3 design principles

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
- **Node.js** (16.0 or higher)
- **Yarn** package manager
- **Chrome browser** (for web development)
- **Git** (for cloning repositories)

## 🛠️ Installation & Setup

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
cd new_project
```

### Step 2: Set Up Flutter Application

Navigate to the Flutter project directory:

```bash
cd flutter_sample
```

Install Flutter dependencies:

```bash
flutter pub get
```

### Step 3: Set Up Self-Hosted Excalidraw Server

Navigate to the Excalidraw directory:

```bash
cd ../self_host_draw/excalidraw
```

Install Node.js dependencies:

```bash
yarn install
```

## 🎯 Running the Application

### Step 1: Start the Excalidraw Server

Open a terminal and navigate to the Excalidraw directory:

```bash
cd self_host_draw/excalidraw
yarn start
```

**Expected Output:**
```
✓ Ready in 2212ms
VITE v5.0.12 ready in 2212 ms
➜ Local: http://localhost:3000/
```

The Excalidraw server will run on `http://localhost:3000`

### Step 2: Start the Flutter Web Application

Open a **new terminal** and navigate to the Flutter directory:

```bash
cd flutter_sample
flutter run -d chrome --web-port 8087
```

**Expected Output:**
```
Launching lib\main.dart on Chrome in debug mode...
This app is linked to the debug service: ws://127.0.0.1:xxxxx/xxx=/ws
Flutter run key commands.
R Hot restart.
```

The Flutter app will run on `http://localhost:8087`

## 🖥️ How to Use

### Main Interface

1. **Embedded Excalidraw**: The main screen shows an embedded Excalidraw editor
2. **Professional Toolbar**: Click the **Dashboard** button (📊) in the top toolbar
3. **SnackBar Management**: When notifications appear, the iframe is temporarily replaced with a placeholder

### Professional Toolbar Features

The toolbar provides a 2x2 grid of professional tools:

- **💾 Save Map**: Store your current mind map locally
- **📁 Saved Maps**: Browse and manage your saved mind maps  
- **🤖 AI Assistant**: Access AI-powered insights and assistance
- **🔧 Test Tools**: Development and testing functionality

### Key Interactions

1. **Creating Mind Maps**: Use the Excalidraw interface to draw and create diagrams
2. **Auto-Save**: Maps are automatically saved when you interact with Excalidraw
3. **AI Integration**: Navigate to AI Assistant to get insights about your mind maps
4. **Storage Management**: View and organize saved maps through the Saved Maps interface

## 🔧 Configuration

### Port Configuration

- **Excalidraw Server**: `localhost:3000`
- **Flutter Web App**: `localhost:8087`

If these ports are in use, you can change them:

**For Flutter:**
```bash
flutter run -d chrome --web-port 8088
```

**For Excalidraw:** Edit the configuration in `vite.config.js`

### File Structure

```
new_project/
├── flutter_sample/          # Flutter web application
│   ├── lib/
│   │   ├── main.dart           # Main application entry
│   │   ├── toolbar_screen.dart # Professional toolbar interface
│   │   ├── ai_assisstant_screen.dart # AI assistant
│   │   └── mind_map_model.dart # Data models
│   └── pubspec.yaml         # Flutter dependencies
└── self_host_draw/
    └── excalidraw/          # Self-hosted Excalidraw server
        ├── package.json     # Node.js dependencies
        └── src/             # Excalidraw source code
```

## 🎨 Customization

### Professional Toolbar

The toolbar can be customized in `toolbar_screen.dart`:

- **Colors**: Modify gradient colors in the `_buildToolButton` method
- **Layout**: Adjust the 2x2 grid layout in the main Column/Row structure
- **Buttons**: Add new tools by creating additional `_buildToolButton` calls

### UI Themes

The app supports both light and dark modes through Material 3 theming:

```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF667eea),
    brightness: Brightness.light,
  ),
)
```

## 🐛 Troubleshooting

### Common Issues

**1. "localhost refused to connect"**
- Ensure both Excalidraw server (port 3000) and Flutter app (port 8087) are running
- Check if ports are already in use: `netstat -ano | findstr :3000`

**2. "Failed to bind web development server"**
- Port 8087 is in use, try a different port: `--web-port 8088`

**3. Excalidraw not loading**
- Verify Excalidraw server is running on `http://localhost:3000`
- Check browser console for CORS or network errors

**4. SnackBar not replacing iframe**
- Ensure `_isSnackBarVisible` state is properly managed
- Check that the conditional rendering logic is intact in `main.dart`

### Debug Commands

**Check Flutter status:**
```bash
flutter doctor
```

**Hot reload Flutter app:**
Press `R` in the Flutter terminal

**Restart Excalidraw server:**
Press `Ctrl+C` then `yarn start`

## 🔍 Advanced Features

### PostMessage Communication

The app uses PostMessage API for Flutter-Excalidraw communication:

```javascript
// From Excalidraw to Flutter
window.parent.postMessage({
  type: 'excalidraw-data',
  payload: data,
  from: 'home'
}, '*');
```

### Local Storage Integration

Mind maps are stored in browser localStorage:

```dart
html.window.localStorage['excalidraw-data-$timestamp'] = mapData.toString();
```

### Conditional UI Management

The iframe is conditionally replaced during SnackBar interactions:

```dart
child: _isSnackBarVisible
  ? Container(/* Placeholder */)
  : const HtmlElementView(viewType: 'excalidraw-iframe')
```

## 📚 Dependencies

### Flutter Dependencies
- `flutter/material.dart` - Material Design components
- `dart:html` - Web APIs and DOM manipulation
- `dart:ui_web` - Platform view registry for iframe embedding
- `get: ^4.6.6` - State management (optional, used in integrated version)

### Node.js Dependencies
- `@excalidraw/excalidraw` - Core Excalidraw functionality
- `vite` - Development server and build tool
- `react` - UI framework for Excalidraw

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly with both servers running
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter issues:

1. Check this README for common solutions
2. Ensure all prerequisites are installed
3. Verify both servers are running on correct ports
4. Check browser console for error messages
5. Create an issue with detailed error logs

---

**Happy Mind Mapping! 🧠✨**
