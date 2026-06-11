# PDFMint 🌿

> **Tamamen offline çalışan, modern Windows PDF araçları uygulaması**

PDFMint, PDF24'e benzer ancak tamamen yerel çalışan, Tiffany Blue tasarımıyla öne çıkan, sevimli Minty maskotuna sahip bir PDF araçları paketidir.

---

## Özellikler

### 24 PDF Aracı
- **Düzenleme:** Birleştir, Böl, Döndür, Sayfa Sil/Ekle, Yeniden Sırala
- **Dönüştürme:** Word/Excel/PPT/JPG/PNG → PDF ve PDF → çeşitli formatlar
- **Güvenlik:** Şifrele (AES-256), Şifre Kaldır, İmzala
- **OCR:** Metin Tanıma, Karşılaştır
- **Optimize:** Sıkıştır, Onar, Filigran, Numaralandır, Metadata

### Tasarım
- 🎨 Tiffany Blue (#81D8D0) ana renk
- 🌙 Aydınlık & Karanlık tema
- ✨ Hafif animasyonlar ve geçiş efektleri
- 🎉 İşlem tamamlanınca konfeti efekti
- 🐾 Minty maskotu - yardım ipuçları ve kutlamalar

### Teknik
- ✅ %100 Offline - internet bağlantısı gerekmez
- ✅ Veriler buluta gönderilmez
- ✅ Sürükle-bırak desteği
- ✅ Çoklu dosya desteği
- ✅ İşlem geçmişi (SQLite)
- ✅ Hızlı arama ve kategori filtreleme
- ✅ PDF önizleme

---

## Hızlı Başlangıç

```powershell
# 1. Bağımlılıkları indir
flutter pub get

# 2. Geliştirme modunda çalıştır
flutter run -d windows

# 3. Release build oluştur
flutter build windows --release
```

Detaylı kurulum için [BUILD_GUIDE.md](BUILD_GUIDE.md) dosyasına bakın.

---

## Teknoloji

| Katman | Teknoloji |
|--------|-----------|
| UI | Flutter 3.24 + Material 3 |
| Dil | Dart 3.5 |
| PDF İşleme | Syncfusion Flutter PDF |
| Veritabanı | SQLite (sqflite_ffi) |
| Animasyon | flutter_animate + confetti |
| Pencere | window_manager |

---

## Minty Maskotu

Minty, Tiffany rengi PDF karakteridir. Uygulamada:
- Araç ipuçları gösterir
- İşlem tamamlanınca kutlar 🎉
- Hata durumunda nazikçe bilgilendirir
- Ayarlardan kapatılabilir

---

## Güvenlik

> Hiçbir dosya internet üzerinden gönderilmez. Tüm işlemler yerel bilgisayarınızda gerçekleşir.

- AES-256 bit PDF şifreleme
- Ağ izni gerektirmez
- Kullanıcı gizliliği önceliklidir

---

## Lisans

MIT License - Özgürce kullanabilirsiniz.
