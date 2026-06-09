@echo off
REM ============================================
REM  Deploy Debug APK with Shader Support Fix
REM  Usage: deploy-debug.bat
REM ============================================

echo [1/3] Uninstalling old version...
adb uninstall com.hashira.logic.fitness_log_app

echo.
echo [2/3] Building debug APK with clean assets...
call flutter clean
call flutter pub get
call flutter build apk --debug --enable-impeller

echo.
echo [3/3] Installing to device...
adb install -r build\app\outputs\flutter-apk\app-debug.apk

echo.
echo ============================================
echo  DONE! Launch app and check Logcat:
echo  adb logcat -s flutter ^| findstr "Shader"
echo ============================================
pause
