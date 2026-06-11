# PDFMint - Windows Build Rehberi

## Gereksinimler

### 1. Flutter SDK
- **Flutter 3.24+** gereklidir
- İndirme: https://docs.flutter.dev/get-started/install/windows
- PATH'e ekle: `C:\flutter\bin`

### 2. Visual Studio 2022
- **Desktop development with C++** iş yükü seçilmeli
- İndirme: https://visualstudio.microsoft.com/downloads/

### 3. Git
- İndirme: https://git-scm.com/download/win

### 4. İsteğe Bağlı (Özellikler İçin)
- **LibreOffice** (Word/Excel/PPT dönüştürme için)
  - İndirme: https://www.libreoffice.org/download/
- **Tesseract OCR** (OCR özelliği için)
  - İndirme: https://github.com/UB-Mannheim/tesseract/wiki
  - Türkçe dil paketi: `tessdata/tur.traineddata`

---

## Kurulum Adımları

### 1. Flutter Ortamını Hazırla
```powershell
# Flutter kurulumunu doğrula
flutter doctor

# Windows desktop desteğini etkinleştir
flutter config --enable-windows-desktop
```

### 2. Projeyi Klonla / Kopyala
```powershell
# Proje klasörüne git
cd C:\Projects\pdfmint

# Bağımlılıkları indir
flutter pub get
```

### 3. Geliştirme Modunda Çalıştır
```powershell
flutter run -d windows
```

### 4. Release Build Oluştur
```powershell
# Windows için release build
flutter build windows --release

# Çıktı klasörü:
# build\windows\x64\runner\Release\pdfmint.exe
```

---

## Proje Yapısı

```
pdfmint/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # Renk paleti (Tiffany Blue)
│   │   │   └── app_theme.dart       # Aydınlık/Karanlık tema
│   │   └── providers/
│   │       └── app_provider.dart    # Durum yönetimi
│   ├── models/
│   │   └── pdf_tool.dart            # Araç modelleri (24 araç)
│   ├── features/
│   │   ├── home/
│   │   │   └── home_screen.dart     # Ana sayfa + araç kartları
│   │   ├── tools/
│   │   │   └── tool_screen.dart     # Araç işlem ekranı
│   │   ├── history/
│   │   │   └── history_screen.dart  # İşlem geçmişi
│   │   └── settings/
│   │       └── settings_screen.dart # Ayarlar
│   ├── services/
│   │   ├── pdf_service.dart         # PDF işleme motoru
│   │   ├── conversion_service.dart  # Dönüştürme servisi
│   │   ├── ocr_service.dart         # OCR + İmza + Karşılaştırma
│   │   └── database_service.dart    # SQLite veritabanı
│   └── shared/
│       └── widgets/
│           ├── app_shell.dart           # Ana navigasyon
│           ├── minty_mascot.dart        # Minty maskot widget'ı
│           └── pdf_preview_widget.dart  # PDF önizleme
├── windows/                         # Windows platform kodu
├── assets/
│   ├── images/                      # Görseller
│   ├── icons/                       # İkonlar
│   └── animations/                  # Lottie animasyonlar
└── pubspec.yaml                     # Bağımlılıklar
```

---

## PDF Araçları (24 Araç)

| Araç | Açıklama | Kategori |
|------|----------|----------|
| PDF Birleştir | Birden fazla PDF'yi tek dosyada birleştir | Düzenle |
| PDF Böl | PDF'yi sayfalara veya bölümlere ayır | Düzenle |
| PDF Döndür | Sayfaları istediğin açıda döndür | Düzenle |
| Sayfa Sil | İstenmeyen sayfaları kaldır | Düzenle |
| Sayfa Ekle | PDF'ye yeni sayfalar ekle | Düzenle |
| Yeniden Sırala | Sayfaları sürükle-bırak ile sırala | Düzenle |
| Word → PDF | Word belgelerini PDF'ye dönüştür | Dönüştür |
| Excel → PDF | Excel tablolarını PDF'ye dönüştür | Dönüştür |
| PowerPoint → PDF | Sunumları PDF'ye dönüştür | Dönüştür |
| JPG → PDF | JPEG resimlerini PDF'ye dönüştür | Dönüştür |
| PNG → PDF | PNG resimlerini PDF'ye dönüştür | Dönüştür |
| PDF → Word | PDF'yi düzenlenebilir Word'e dönüştür | Dönüştür |
| PDF → Excel | PDF tablolarını Excel'e aktar | Dönüştür |
| PDF → Resim | PDF sayfalarını resim olarak kaydet | Dönüştür |
| Filigran Ekle | PDF'ye metin veya resim filigranı ekle | Düzenle |
| Numaralandır | Sayfalara otomatik numara ekle | Düzenle |
| Metadata Düzenle | Başlık, yazar, konu bilgilerini düzenle | Düzenle |
| PDF Şifrele | PDF'yi parola ile koru (AES-256) | Güvenlik |
| Şifre Kaldır | PDF'den parola korumasını kaldır | Güvenlik |
| PDF İmzala | PDF'ye dijital imza ekle | Güvenlik |
| OCR Metin Tanıma | Taranmış PDF'den metin çıkar | OCR |
| PDF Karşılaştır | İki PDF arasındaki farkları bul | OCR |
| PDF Sıkıştır | Dosya boyutunu küçült | Optimize |
| PDF Onar | Bozuk PDF dosyalarını kurtarmaya çalış | Optimize |

---

## Teknoloji Yığını

| Teknoloji | Kullanım |
|-----------|----------|
| Flutter 3.24 | UI Framework |
| Dart 3.5 | Programlama Dili |
| Syncfusion PDF | PDF İşleme Motoru |
| SQLite (FFI) | Yerel Veritabanı |
| window_manager | Pencere Yönetimi |
| flutter_animate | Animasyonlar |
| confetti | Kutlama Efekti |
| desktop_drop | Sürükle-Bırak |
| file_picker | Dosya Seçimi |
| google_fonts | Inter Yazı Tipi |
| provider | Durum Yönetimi |

---

## Tasarım Sistemi

### Renkler
- **Ana Renk:** Tiffany Blue `#81D8D0`
- **Koyu Ton:** `#4FBFB5`
- **Açık Ton:** `#B3EAE6`
- **Arka Plan (Aydınlık):** `#F8FAFB`
- **Arka Plan (Karanlık):** `#0F172A`

### Minty Maskot
Minty, Tiffany rengi PDF karakteridir. 5 farklı ruh hali vardır:
- `happy` - Normal gülümseme
- `thinking` - Düşünme ifadesi
- `celebrating` - Kutlama (konfeti ile)
- `sad` - Hata durumunda
- `working` - İşlem sırasında

---

## Güvenlik Notları

- ✅ Hiçbir dosya internet üzerinden gönderilmez
- ✅ Tüm işlemler yerel bilgisayarda gerçekleşir
- ✅ AES-256 bit şifreleme desteği
- ✅ Kullanıcı verileri buluta aktarılmaz
- ✅ Ağ izni gerektirmez

---

## Sorun Giderme

### "flutter doctor" hataları
```powershell
# Visual Studio C++ araçlarını kontrol et
flutter doctor --verbose

# Windows desktop desteğini etkinleştir
flutter config --enable-windows-desktop
```

### LibreOffice bulunamadı hatası
Word/Excel/PPT dönüştürme için LibreOffice kurulu olmalıdır:
1. https://www.libreoffice.org/download/ adresinden indir
2. Varsayılan konuma kur: `C:\Program Files\LibreOffice`

### Tesseract OCR bulunamadı hatası
1. https://github.com/UB-Mannheim/tesseract/wiki adresinden indir
2. Türkçe dil paketi için: Kurulum sırasında "Turkish" seç
3. PATH'e ekle: `C:\Program Files\Tesseract-OCR`
