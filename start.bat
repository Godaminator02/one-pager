@echo off
echo ====================================
echo Mind Map AI - Quick Start
echo ====================================
echo.

echo Starting Excalidraw server...
echo Please wait for the server to start, then open a new terminal for Flutter app.
echo.

cd self_host_draw\excalidraw
start cmd /k "echo Excalidraw Server Starting... && yarn start"

timeout /t 3 /nobreak >nul

echo.
echo Starting Flutter application...
cd ..\..\flutter_sample
start cmd /k "echo Flutter App Starting... && flutter run -d chrome --web-port 8087"

echo.
echo ====================================
echo Both servers are starting up!
echo ====================================
echo.
echo Excalidraw: http://localhost:3000
echo Flutter App: http://localhost:8087
echo.
echo Wait for both terminals to show "ready" status.
echo Your browser should automatically open the Flutter app.
echo.
pause
