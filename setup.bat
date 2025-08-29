@echo off
echo ====================================
echo Mind Map AI - Quick Setup Script
echo ====================================
echo.

echo [1/4] Checking Flutter installation...
flutter --version
if %ERRORLEVEL% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter SDK from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo.
echo [2/4] Installing Flutter dependencies...
cd flutter_sample
flutter pub get
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to install Flutter dependencies
    pause
    exit /b 1
)

echo.
echo [3/4] Installing Excalidraw dependencies...
cd ..\self_host_draw\excalidraw
call yarn install
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to install Excalidraw dependencies
    echo Make sure Node.js and Yarn are installed
    pause
    exit /b 1
)

echo.
echo [4/4] Setup complete!
echo.
echo ====================================
echo         SETUP SUCCESSFUL!
echo ====================================
echo.
echo To run the application:
echo.
echo 1. Start Excalidraw server:
echo    cd self_host_draw\excalidraw
echo    yarn start
echo.
echo 2. In a new terminal, start Flutter app:
echo    cd flutter_sample
echo    flutter run -d chrome --web-port 8087
echo.
echo The app will be available at: http://localhost:8087
echo Excalidraw server will run at: http://localhost:3000
echo.
pause
