@echo off
chcp 65001 > nul
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║          PDFMint - Kurulum ve Çalıştırma Scripti         ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Flutter kontrolü
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Flutter bulunamadı!
    echo Flutter'ı https://docs.flutter.dev/get-started/install/windows adresinden indirin.
    echo PATH'e ekleyin: C:\flutter\bin
    pause
    exit /b 1
)

echo [OK] Flutter bulundu
flutter --version

echo.
echo [1/3] Bağımlılıklar indiriliyor...
flutter pub get
if %errorlevel% neq 0 (
    echo [HATA] Bağımlılıklar indirilemedi!
    pause
    exit /b 1
)

echo.
echo [2/3] Windows desktop desteği etkinleştiriliyor...
flutter config --enable-windows-desktop

echo.
echo [3/3] Uygulama başlatılıyor...
echo.
echo PDFMint açılıyor... Lütfen bekleyin.
echo.
flutter run -d windows

pause
