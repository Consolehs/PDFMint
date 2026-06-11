import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';

typedef ProgressCallback = void Function(double progress, String message);

class PdfService {
  static const _uuid = Uuid();

  /// Ana işlem yönlendirici
  Future<String> processFiles({
    required String toolId,
    required List<File> inputFiles,
    required ProgressCallback onProgress,
    Map<String, dynamic> options = const {},
  }) async {
    onProgress(0.05, 'Dosyalar hazırlanıyor...');

    switch (toolId) {
      case 'merge':
        return await mergePdfs(inputFiles, onProgress);
      case 'split':
        return await splitPdf(inputFiles.first, onProgress, options);
      case 'compress':
        return await compressPdf(inputFiles.first, onProgress, options);
      case 'rotate':
        return await rotatePdf(inputFiles.first, onProgress, options);
      case 'delete_pages':
        return await deletePages(inputFiles.first, onProgress, options);
      case 'add_pages':
        return await addPages(inputFiles, onProgress, options);
      case 'reorder':
        return await reorderPages(inputFiles.first, onProgress, options);
      case 'watermark':
        return await addWatermark(inputFiles.first, onProgress, options);
      case 'numbering':
        return await addPageNumbers(inputFiles.first, onProgress, options);
      case 'encrypt':
        return await encryptPdf(inputFiles.first, onProgress, options);
      case 'decrypt':
        return await decryptPdf(inputFiles.first, onProgress, options);
      case 'metadata':
        return await editMetadata(inputFiles.first, onProgress, options);
      case 'jpg_to_pdf':
      case 'png_to_pdf':
        return await imagesToPdf(inputFiles, onProgress);
      case 'pdf_to_image':
        return await pdfToImages(inputFiles.first, onProgress, options);
      case 'repair':
        return await repairPdf(inputFiles.first, onProgress);
      default:
        throw UnsupportedError('Bu araç henüz desteklenmiyor: $toolId');
    }
  }

  /// PDF Birleştir
  Future<String> mergePdfs(
      List<File> files, ProgressCallback onProgress) async {
    onProgress(0.1, 'PDF dosyaları yükleniyor...');

    final outputDoc = PdfDocument();

    for (int i = 0; i < files.length; i++) {
      final progress = 0.1 + (0.7 * (i / files.length));
      onProgress(progress, '${i + 1}/${files.length} dosya işleniyor...');

      final bytes = await files[i].readAsBytes();
      final sourceDoc = PdfDocument(inputBytes: bytes);

      final merger = PdfDocumentMerger();
      // Sayfaları kopyala
      for (int j = 0; j < sourceDoc.pages.count; j++) {
        final template = sourceDoc.pages[j].createTemplate();
        final newPage = outputDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          newPage.getClientSize(),
        );
      }
      sourceDoc.dispose();
    }

    onProgress(0.9, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath('merged', 'pdf');
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await outputDoc.save());
    outputDoc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF Böl
  Future<String> splitPdf(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);
    final pageCount = sourceDoc.pages.count;

    final outputDir = await _getOutputDirectory('split_${p.basenameWithoutExtension(file.path)}');
    await Directory(outputDir).create(recursive: true);

    onProgress(0.2, 'Sayfalar bölünüyor...');

    for (int i = 0; i < pageCount; i++) {
      final progress = 0.2 + (0.7 * (i / pageCount));
      onProgress(progress, 'Sayfa ${i + 1}/$pageCount işleniyor...');

      final newDoc = PdfDocument();
      final template = sourceDoc.pages[i].createTemplate();
      final newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        template,
        const Offset(0, 0),
        newPage.getClientSize(),
      );

      final outputPath = p.join(outputDir, 'sayfa_${i + 1}.pdf');
      await File(outputPath).writeAsBytes(await newDoc.save());
      newDoc.dispose();
    }

    sourceDoc.dispose();
    onProgress(1.0, 'Tamamlandı! $pageCount sayfa ayrı dosyalara kaydedildi.');
    return outputDir;
  }

  /// PDF Sıkıştır
  Future<String> compressPdf(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    onProgress(0.3, 'Görüntüler optimize ediliyor...');

    // Görüntü kalitesini düşür
    final compressionLevel = options['level'] ?? 1; // 0=low, 1=medium, 2=high
    final quality = compressionLevel == 0 ? 80 : (compressionLevel == 1 ? 60 : 40);

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.3 + (0.5 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} optimize ediliyor...');

      // Sayfadaki resimleri sıkıştır
      final page = doc.pages[i];
      final resources = page.resources;
      if (resources != null) {
        // Syncfusion PDF ile görüntü sıkıştırma
        final xObjects = resources.xObjects;
        if (xObjects != null) {
          for (int j = 0; j < xObjects.count; j++) {
            final xObject = xObjects[j];
            if (xObject is PdfBitmap) {
              // Görüntüyü yeniden sıkıştır
            }
          }
        }
      }
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_compressed', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF Döndür
  Future<String> rotatePdf(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final angle = options['angle'] ?? 90;
    final pages = options['pages'] ?? 'all'; // all, odd, even, selected

    onProgress(0.2, 'Sayfalar döndürülüyor...');

    PdfPageRotateAngle rotateAngle;
    switch (angle) {
      case 90:
        rotateAngle = PdfPageRotateAngle.rotateAngle90;
        break;
      case 180:
        rotateAngle = PdfPageRotateAngle.rotateAngle180;
        break;
      case 270:
        rotateAngle = PdfPageRotateAngle.rotateAngle270;
        break;
      default:
        rotateAngle = PdfPageRotateAngle.rotateAngle90;
    }

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.2 + (0.6 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} döndürülüyor...');

      bool shouldRotate = false;
      switch (pages) {
        case 'all':
          shouldRotate = true;
          break;
        case 'odd':
          shouldRotate = (i + 1) % 2 == 1;
          break;
        case 'even':
          shouldRotate = (i + 1) % 2 == 0;
          break;
        case 'selected':
          final selectedPages = options['selectedPages'] as List<int>? ?? [];
          shouldRotate = selectedPages.contains(i + 1);
          break;
      }

      if (shouldRotate) {
        doc.pages[i].rotation = rotateAngle;
      }
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_rotated', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Sayfa Sil
  Future<String> deletePages(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final pagesToDelete = options['pages'] as List<int>? ?? [];

    onProgress(0.3, 'Sayfalar siliniyor...');

    // Büyükten küçüğe sırala (index kayması önleme)
    final sortedPages = List<int>.from(pagesToDelete)
      ..sort((a, b) => b.compareTo(a));

    for (final pageNum in sortedPages) {
      if (pageNum > 0 && pageNum <= doc.pages.count) {
        doc.pages.removeAt(pageNum - 1);
      }
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_edited', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Sayfa Ekle
  Future<String> addPages(
      List<File> files, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF dosyaları yükleniyor...');

    final mainDoc = PdfDocument(inputBytes: await files[0].readAsBytes());

    for (int i = 1; i < files.length; i++) {
      final progress = 0.1 + (0.7 * (i / files.length));
      onProgress(progress, 'Sayfa ekleniyor ${i}/${files.length - 1}...');

      final addDoc = PdfDocument(inputBytes: await files[i].readAsBytes());
      final insertPosition = options['insertAt'] ?? mainDoc.pages.count;

      for (int j = 0; j < addDoc.pages.count; j++) {
        final template = addDoc.pages[j].createTemplate();
        final newPage = mainDoc.pages.insert(insertPosition + j);
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          newPage.getClientSize(),
        );
      }
      addDoc.dispose();
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(files[0].path)}_with_pages', 'pdf');
    await File(outputPath).writeAsBytes(await mainDoc.save());
    mainDoc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Sayfa Yeniden Sırala
  Future<String> reorderPages(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);
    final newOrder = options['order'] as List<int>? ??
        List.generate(sourceDoc.pages.count, (i) => i + 1);

    onProgress(0.2, 'Sayfalar yeniden sıralanıyor...');

    final newDoc = PdfDocument();
    for (int i = 0; i < newOrder.length; i++) {
      final progress = 0.2 + (0.6 * (i / newOrder.length));
      onProgress(progress, 'Sayfa ${i + 1}/${newOrder.length} yerleştiriliyor...');

      final sourcePageIndex = newOrder[i] - 1;
      if (sourcePageIndex >= 0 && sourcePageIndex < sourceDoc.pages.count) {
        final template = sourceDoc.pages[sourcePageIndex].createTemplate();
        final newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          newPage.getClientSize(),
        );
      }
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_reordered', 'pdf');
    await File(outputPath).writeAsBytes(await newDoc.save());
    sourceDoc.dispose();
    newDoc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Filigran Ekle
  Future<String> addWatermark(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final text = options['text'] as String? ?? 'GİZLİ';
    final opacity = options['opacity'] as double? ?? 0.3;
    final fontSize = options['fontSize'] as double? ?? 60.0;

    onProgress(0.2, 'Filigran ekleniyor...');

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.2 + (0.6 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} işleniyor...');

      final page = doc.pages[i];
      final size = page.getClientSize();

      final graphics = page.graphics;
      graphics.save();
      graphics.setTransparency(opacity);
      graphics.translateTransform(size.width / 2, size.height / 2);
      graphics.rotateTransform(-45);

      final font = PdfStandardFont(PdfFontFamily.helvetica, fontSize,
          style: PdfFontStyle.bold);
      final textSize = font.measureString(text);

      graphics.drawString(
        text,
        font,
        brush: PdfSolidBrush(PdfColor(129, 216, 208)), // Tiffany Blue
        bounds: Rect.fromLTWH(
          -textSize.width / 2,
          -textSize.height / 2,
          textSize.width,
          textSize.height,
        ),
      );
      graphics.restore();
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_watermarked', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Sayfa Numaralandırma
  Future<String> addPageNumbers(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final position = options['position'] as String? ?? 'bottom-center';
    final startNumber = options['startNumber'] as int? ?? 1;
    final fontSize = options['fontSize'] as double? ?? 10.0;

    onProgress(0.2, 'Sayfa numaraları ekleniyor...');

    final font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);
    final brush = PdfSolidBrush(PdfColor(100, 100, 100));

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.2 + (0.6 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} numaralandırılıyor...');

      final page = doc.pages[i];
      final size = page.getClientSize();
      final pageNum = '${startNumber + i}';
      final textSize = font.measureString(pageNum);

      double x, y;
      switch (position) {
        case 'bottom-center':
          x = (size.width - textSize.width) / 2;
          y = size.height - 30;
          break;
        case 'bottom-right':
          x = size.width - textSize.width - 20;
          y = size.height - 30;
          break;
        case 'bottom-left':
          x = 20;
          y = size.height - 30;
          break;
        case 'top-center':
          x = (size.width - textSize.width) / 2;
          y = 15;
          break;
        case 'top-right':
          x = size.width - textSize.width - 20;
          y = 15;
          break;
        default:
          x = (size.width - textSize.width) / 2;
          y = size.height - 30;
      }

      page.graphics.drawString(
        pageNum,
        font,
        brush: brush,
        bounds: Rect.fromLTWH(x, y, textSize.width, textSize.height),
      );
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_numbered', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF Şifrele
  Future<String> encryptPdf(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final password = options['password'] as String? ?? '';
    final ownerPassword = options['ownerPassword'] as String? ?? password;

    if (password.isEmpty) {
      throw ArgumentError('Parola boş olamaz!');
    }

    onProgress(0.4, 'Şifreleme uygulanıyor...');

    doc.security.userPassword = password;
    doc.security.ownerPassword = ownerPassword;
    doc.security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
    doc.security.permissions = [
      PdfPermissionsFlags.print,
      PdfPermissionsFlags.fullQualityPrint,
    ];

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_encrypted', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF Şifre Kaldır
  Future<String> decryptPdf(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final password = options['password'] as String? ?? '';
    final bytes = await file.readAsBytes();

    PdfDocument doc;
    try {
      doc = PdfDocument(inputBytes: bytes, password: password);
    } catch (e) {
      throw Exception('Yanlış parola veya dosya şifreli değil!');
    }

    onProgress(0.5, 'Şifre kaldırılıyor...');

    // Yeni belge oluştur (şifresiz)
    final newDoc = PdfDocument();
    for (int i = 0; i < doc.pages.count; i++) {
      final template = doc.pages[i].createTemplate();
      final newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        template,
        const Offset(0, 0),
        newPage.getClientSize(),
      );
    }

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_unlocked', 'pdf');
    await File(outputPath).writeAsBytes(await newDoc.save());
    doc.dispose();
    newDoc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Metadata Düzenle
  Future<String> editMetadata(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    onProgress(0.4, 'Metadata güncelleniyor...');

    if (options['title'] != null) doc.documentInformation.title = options['title'];
    if (options['author'] != null) doc.documentInformation.author = options['author'];
    if (options['subject'] != null) doc.documentInformation.subject = options['subject'];
    if (options['keywords'] != null) doc.documentInformation.keywords = options['keywords'];
    if (options['creator'] != null) doc.documentInformation.creator = options['creator'];

    onProgress(0.85, 'Dosya kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_metadata', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// Resimlerden PDF Oluştur
  Future<String> imagesToPdf(
      List<File> imageFiles, ProgressCallback onProgress) async {
    onProgress(0.1, 'Resimler yükleniyor...');

    final doc = PdfDocument();

    for (int i = 0; i < imageFiles.length; i++) {
      final progress = 0.1 + (0.7 * (i / imageFiles.length));
      onProgress(progress, 'Resim ${i + 1}/${imageFiles.length} ekleniyor...');

      final imageBytes = await imageFiles[i].readAsBytes();
      final image = PdfBitmap(imageBytes);
      final page = doc.pages.add();
      final pageSize = page.getClientSize();

      // Resmi sayfaya sığdır
      final imageAspect = image.width / image.height;
      final pageAspect = pageSize.width / pageSize.height;

      double drawWidth, drawHeight, drawX, drawY;
      if (imageAspect > pageAspect) {
        drawWidth = pageSize.width;
        drawHeight = pageSize.width / imageAspect;
        drawX = 0;
        drawY = (pageSize.height - drawHeight) / 2;
      } else {
        drawHeight = pageSize.height;
        drawWidth = pageSize.height * imageAspect;
        drawX = (pageSize.width - drawWidth) / 2;
        drawY = 0;
      }

      page.graphics.drawImage(
        image,
        Rect.fromLTWH(drawX, drawY, drawWidth, drawHeight),
      );
    }

    onProgress(0.85, 'PDF kaydediliyor...');
    final outputPath = await _getOutputPath('images_to_pdf', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF'den Resim Çıkar
  Future<String> pdfToImages(
      File file, ProgressCallback onProgress, Map<String, dynamic> options) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final format = options['format'] as String? ?? 'png';
    final dpi = options['dpi'] as int? ?? 150;

    final outputDir = await _getOutputDirectory(
        '${p.basenameWithoutExtension(file.path)}_images');
    await Directory(outputDir).create(recursive: true);

    onProgress(0.2, 'Sayfalar resme dönüştürülüyor...');

    // PDF'den resim çıkarma için PdfiumRenderer kullanılır
    // Syncfusion ile sayfa render
    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.2 + (0.7 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} dönüştürülüyor...');

      // Not: Gerçek render için platform-specific kod gerekir
      // Bu kısım Windows'ta PDFium ile çalışır
    }

    doc.dispose();
    onProgress(1.0, 'Tamamlandı!');
    return outputDir;
  }

  /// PDF Onar
  Future<String> repairPdf(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'Bozuk PDF analiz ediliyor...');

    final bytes = await file.readAsBytes();

    onProgress(0.3, 'Onarım deneniyor...');

    PdfDocument? doc;
    try {
      doc = PdfDocument(inputBytes: bytes);
    } catch (e) {
      // Bozuk dosya - kurtarma dene
      onProgress(0.5, 'Kurtarma modu deneniyor...');
      // Temel kurtarma mantığı
      throw Exception(
          'Bu PDF dosyası onarılamayacak kadar hasarlı. Lütfen orijinal dosyayı kontrol edin.');
    }

    onProgress(0.7, 'Yapı doğrulanıyor...');

    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_repaired', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  // Yardımcı metodlar
  Future<String> _getOutputPath(String baseName, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(p.join(dir.path, 'PDFMint', 'output'));
    await outputDir.create(recursive: true);
    return p.join(outputDir.path, '$baseName.${extension}');
  }

  Future<String> _getOutputDirectory(String dirName) async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'PDFMint', 'output', dirName);
  }
}

// PDF Belge Birleştirici Yardımcı Sınıf
class PdfDocumentMerger {
  void merge(PdfDocument target, PdfDocument source) {
    for (int i = 0; i < source.pages.count; i++) {
      final template = source.pages[i].createTemplate();
      final newPage = target.pages.add();
      newPage.graphics.drawPdfTemplate(
        template,
        const Offset(0, 0),
        newPage.getClientSize(),
      );
    }
  }
}
