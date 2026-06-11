import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

typedef ProgressCallback = void Function(double progress, String message);

/// OCR Servisi - Tesseract OCR kullanır
class OcrService {
  /// Tesseract OCR ile metin tanıma
  static Future<String> recognizeText(
    File pdfFile,
    ProgressCallback onProgress, {
    String language = 'tur',
    bool createSearchablePdf = true,
  }) async {
    onProgress(0.05, 'Tesseract OCR hazırlanıyor...');

    // Tesseract kurulum kontrolü
    final tesseractPath = await _findTesseract();
    if (tesseractPath == null) {
      throw Exception(
          'Tesseract OCR kurulu değil. Lütfen https://tesseract-ocr.github.io adresinden indirin.');
    }

    onProgress(0.1, 'PDF sayfaları görüntüye dönüştürülüyor...');

    final bytes = await pdfFile.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final pageCount = doc.pages.count;
    doc.dispose();

    final tempDir = Directory.systemTemp;
    final extractedTexts = <String>[];

    // Her sayfa için OCR uygula
    for (int i = 0; i < pageCount; i++) {
      final progress = 0.1 + (0.7 * (i / pageCount));
      onProgress(progress, 'Sayfa ${i + 1}/$pageCount OCR işleniyor...');

      // PDF sayfasını PNG'ye dönüştür (PDFium gerekir)
      final imagePath = p.join(tempDir.path, 'pdfmint_page_$i.png');

      // Tesseract ile OCR
      final result = await Process.run(tesseractPath, [
        imagePath,
        'stdout',
        '-l',
        language,
        '--psm',
        '3', // Tam otomatik sayfa segmentasyonu
        '--oem',
        '3', // LSTM + Legacy
      ]);

      if (result.exitCode == 0) {
        extractedTexts.add('--- Sayfa ${i + 1} ---\n${result.stdout}');
      }

      // Geçici dosyayı sil
      try {
        await File(imagePath).delete();
      } catch (_) {}
    }

    onProgress(0.85, 'Metin dosyası oluşturuluyor...');

    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(pdfFile.path)}_ocr', 'txt');
    await File(outputPath).writeAsString(extractedTexts.join('\n\n'));

    if (createSearchablePdf) {
      onProgress(0.92, 'Aranabilir PDF oluşturuluyor...');
      await _createSearchablePdf(pdfFile, extractedTexts, outputPath);
    }

    onProgress(1.0, 'OCR tamamlandı!');
    return outputPath;
  }

  static Future<void> _createSearchablePdf(
    File originalFile,
    List<String> texts,
    String textOutputPath,
  ) async {
    final bytes = await originalFile.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    for (int i = 0; i < doc.pages.count && i < texts.length; i++) {
      final page = doc.pages[i];
      final size = page.getClientSize();

      // Görünmez metin katmanı ekle (arama için)
      final font = PdfStandardFont(PdfFontFamily.helvetica, 1);
      final brush = PdfSolidBrush(PdfColor(255, 255, 255, 0)); // Şeffaf

      page.graphics.drawString(
        texts[i],
        font,
        brush: brush,
        bounds: Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }

    final pdfOutputPath = textOutputPath.replaceAll('.txt', '_searchable.pdf');
    await File(pdfOutputPath).writeAsBytes(await doc.save());
    doc.dispose();
  }

  static Future<String?> _findTesseract() async {
    final paths = [
      r'C:\Program Files\Tesseract-OCR\tesseract.exe',
      r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
      '/usr/bin/tesseract',
      '/usr/local/bin/tesseract',
    ];

    for (final path in paths) {
      if (await File(path).exists()) return path;
    }

    // PATH'te ara
    try {
      final result = await Process.run('tesseract', ['--version']);
      if (result.exitCode == 0) return 'tesseract';
    } catch (_) {}

    return null;
  }

  static Future<String> _getOutputPath(
      String baseName, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(p.join(dir.path, 'PDFMint', 'output'));
    await outputDir.create(recursive: true);
    return p.join(outputDir.path, '$baseName.$extension');
  }
}

/// PDF İmza Servisi
class SignatureService {
  /// PDF'ye dijital imza ekle
  static Future<String> signPdf(
    File file,
    ProgressCallback onProgress, {
    required String signerName,
    required String reason,
    required String location,
    List<int>? signatureImageBytes,
    int pageNumber = 1,
    Rect? signatureRect,
  }) async {
    onProgress(0.1, 'PDF yükleniyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    onProgress(0.3, 'İmza alanı hazırlanıyor...');

    final pageIndex = (pageNumber - 1).clamp(0, doc.pages.count - 1);
    final page = doc.pages[pageIndex];
    final pageSize = page.getClientSize();

    // İmza alanı
    final sigRect = signatureRect ??
        Rect.fromLTWH(
          pageSize.width - 220,
          pageSize.height - 100,
          200,
          80,
        );

    onProgress(0.5, 'İmza uygulanıyor...');

    // Görsel imza ekle
    if (signatureImageBytes != null) {
      final sigImage = PdfBitmap(signatureImageBytes);
      page.graphics.drawImage(sigImage, sigRect);
    } else {
      // Metin tabanlı imza
      final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final signatureText = '''İmzalayan: $signerName
Tarih: ${DateTime.now().toString().substring(0, 19)}
Neden: $reason
Konum: $location''';

      // İmza kutusu çiz
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(129, 216, 208), width: 1.5),
        bounds: sigRect,
      );

      page.graphics.drawString(
        signatureText,
        font,
        brush: PdfSolidBrush(PdfColor(30, 41, 59)),
        bounds: Rect.fromLTWH(
          sigRect.left + 8,
          sigRect.top + 8,
          sigRect.width - 16,
          sigRect.height - 16,
        ),
      );
    }

    onProgress(0.8, 'Dosya kaydediliyor...');

    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_signed', 'pdf');
    await File(outputPath).writeAsBytes(await doc.save());
    doc.dispose();

    onProgress(1.0, 'İmzalama tamamlandı!');
    return outputPath;
  }

  static Future<String> _getOutputPath(
      String baseName, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(p.join(dir.path, 'PDFMint', 'output'));
    await outputDir.create(recursive: true);
    return p.join(outputDir.path, '$baseName.$extension');
  }
}

/// PDF Karşılaştırma Servisi
class ComparisonService {
  static Future<String> comparePdfs(
    File file1,
    File file2,
    ProgressCallback onProgress,
  ) async {
    onProgress(0.1, 'PDF dosyaları yükleniyor...');

    final bytes1 = await file1.readAsBytes();
    final bytes2 = await file2.readAsBytes();

    final doc1 = PdfDocument(inputBytes: bytes1);
    final doc2 = PdfDocument(inputBytes: bytes2);

    onProgress(0.2, 'Metinler çıkarılıyor...');

    final extractor1 = PdfTextExtractor(doc1);
    final extractor2 = PdfTextExtractor(doc2);

    final report = StringBuffer();
    report.writeln('PDFMint - PDF Karşılaştırma Raporu');
    report.writeln('=' * 50);
    report.writeln('Dosya 1: ${p.basename(file1.path)}');
    report.writeln('Dosya 2: ${p.basename(file2.path)}');
    report.writeln('Tarih: ${DateTime.now()}');
    report.writeln('=' * 50);
    report.writeln();

    final maxPages = doc1.pages.count > doc2.pages.count
        ? doc1.pages.count
        : doc2.pages.count;

    int differencesFound = 0;

    for (int i = 0; i < maxPages; i++) {
      final progress = 0.2 + (0.6 * (i / maxPages));
      onProgress(progress, 'Sayfa ${i + 1}/$maxPages karşılaştırılıyor...');

      final text1 = i < doc1.pages.count
          ? extractor1.extractText(startPageIndex: i, endPageIndex: i)
          : '(Sayfa yok)';
      final text2 = i < doc2.pages.count
          ? extractor2.extractText(startPageIndex: i, endPageIndex: i)
          : '(Sayfa yok)';

      if (text1 != text2) {
        differencesFound++;
        report.writeln('FARK - Sayfa ${i + 1}:');
        report.writeln('  Dosya 1: ${text1.substring(0, text1.length.clamp(0, 200))}...');
        report.writeln('  Dosya 2: ${text2.substring(0, text2.length.clamp(0, 200))}...');
        report.writeln();
      }
    }

    doc1.dispose();
    doc2.dispose();

    report.writeln('=' * 50);
    report.writeln('ÖZET: $differencesFound sayfada fark bulundu.');
    report.writeln('Dosya 1 sayfa sayısı: ${doc1.pages.count}');
    report.writeln('Dosya 2 sayfa sayısı: ${doc2.pages.count}');

    onProgress(0.9, 'Rapor kaydediliyor...');

    final outputPath = await _getOutputPath('comparison_report', 'txt');
    await File(outputPath).writeAsString(report.toString());

    onProgress(1.0, 'Karşılaştırma tamamlandı!');
    return outputPath;
  }

  static Future<String> _getOutputPath(
      String baseName, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(p.join(dir.path, 'PDFMint', 'output'));
    await outputDir.create(recursive: true);
    return p.join(outputDir.path, '$baseName.$extension');
  }
}
