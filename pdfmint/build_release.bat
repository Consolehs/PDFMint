@echo off
chcp 65001 > nul
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║          PDFMint - Release Build Scripti                 ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Flutter kontrolü
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Flutter bulunamadı!
    pause
    exit /b 1
)

echo [1/3] Bağımlılıklar güncelleniyor...
flutter pub get

echo.
echo [2/3] Release build oluşturuluyor...
flutter build windows --release

if %errorlevel% neq 0 (
    echo [HATA] Build başarısız!
    pause
    exit /b 1
)

echo.
echo [3/3] Build tamamlandı!
echo.
echo ════════════════════════════════════════════════════════════
echo Çalıştırılabilir dosya konumu:
echo build\windows\x64\runner\Release\pdfmint.exe
echo ════════════════════════════════════════════════════════════
echo.

:: Klasörü aç
start "" "build\windows\x64\runner\Release"

pause
