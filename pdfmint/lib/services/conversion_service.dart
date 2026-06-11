import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

typedef ProgressCallback = void Function(double progress, String message);

/// Dönüştürme servisi - Windows'ta LibreOffice veya COM API kullanır
class ConversionService {
  /// Word → PDF (Windows'ta LibreOffice veya COM kullanır)
  static Future<String> wordToPdf(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'Word dosyası hazırlanıyor...');

    // Windows'ta LibreOffice ile dönüştürme
    final libreOfficePath = await _findLibreOffice();

    if (libreOfficePath != null) {
      return await _convertWithLibreOffice(
          file, 'pdf', onProgress, libreOfficePath);
    }

    // LibreOffice yoksa Windows COM API dene
    if (Platform.isWindows) {
      return await _convertWithWindowsCom(file, 'word', onProgress);
    }

    throw Exception(
        'Dönüştürme için LibreOffice kurulu olmalıdır. Lütfen LibreOffice\'i yükleyin.');
  }

  /// Excel → PDF
  static Future<String> excelToPdf(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'Excel dosyası hazırlanıyor...');

    final libreOfficePath = await _findLibreOffice();
    if (libreOfficePath != null) {
      return await _convertWithLibreOffice(
          file, 'pdf', onProgress, libreOfficePath);
    }

    if (Platform.isWindows) {
      return await _convertWithWindowsCom(file, 'excel', onProgress);
    }

    throw Exception('Dönüştürme için LibreOffice kurulu olmalıdır.');
  }

  /// PowerPoint → PDF
  static Future<String> pptToPdf(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'PowerPoint dosyası hazırlanıyor...');

    final libreOfficePath = await _findLibreOffice();
    if (libreOfficePath != null) {
      return await _convertWithLibreOffice(
          file, 'pdf', onProgress, libreOfficePath);
    }

    if (Platform.isWindows) {
      return await _convertWithWindowsCom(file, 'powerpoint', onProgress);
    }

    throw Exception('Dönüştürme için LibreOffice kurulu olmalıdır.');
  }

  /// PDF → Word (metin çıkarma + DOCX oluşturma)
  static Future<String> pdfToWord(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'PDF analiz ediliyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    onProgress(0.3, 'Metin çıkarılıyor...');

    final textExtractor = PdfTextExtractor(doc);
    final allText = StringBuffer();

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.3 + (0.4 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} işleniyor...');
      allText.writeln(textExtractor.extractText(startPageIndex: i, endPageIndex: i));
      allText.writeln('\n--- Sayfa ${i + 2} ---\n');
    }

    doc.dispose();

    onProgress(0.75, 'Word dosyası oluşturuluyor...');

    // Basit RTF formatında kaydet (Word açabilir)
    final rtfContent = _createRtfFromText(allText.toString());
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_converted', 'rtf');
    await File(outputPath).writeAsString(rtfContent);

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  /// PDF → Excel (tablo çıkarma)
  static Future<String> pdfToExcel(
      File file, ProgressCallback onProgress) async {
    onProgress(0.1, 'PDF analiz ediliyor...');

    final bytes = await file.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);

    onProgress(0.3, 'Tablolar çıkarılıyor...');

    final textExtractor = PdfTextExtractor(doc);
    final csvContent = StringBuffer();
    csvContent.writeln('Sayfa,Satır,İçerik');

    for (int i = 0; i < doc.pages.count; i++) {
      final progress = 0.3 + (0.5 * (i / doc.pages.count));
      onProgress(progress, 'Sayfa ${i + 1}/${doc.pages.count} işleniyor...');

      final text = textExtractor.extractText(
          startPageIndex: i, endPageIndex: i);
      final lines = text.split('\n');
      for (int j = 0; j < lines.length; j++) {
        final line = lines[j].trim();
        if (line.isNotEmpty) {
          csvContent.writeln('${i + 1},${j + 1},"${line.replaceAll('"', '""')}"');
        }
      }
    }

    doc.dispose();

    onProgress(0.85, 'CSV dosyası kaydediliyor...');
    final outputPath = await _getOutputPath(
        '${p.basenameWithoutExtension(file.path)}_data', 'csv');
    await File(outputPath).writeAsString(csvContent.toString());

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  // Yardımcı metodlar
  static Future<String?> _findLibreOffice() async {
    final possiblePaths = [
      r'C:\Program Files\LibreOffice\program\soffice.exe',
      r'C:\Program Files (x86)\LibreOffice\program\soffice.exe',
      '/usr/bin/libreoffice',
      '/usr/bin/soffice',
      '/Applications/LibreOffice.app/Contents/MacOS/soffice',
    ];

    for (final path in possiblePaths) {
      if (await File(path).exists()) {
        return path;
      }
    }
    return null;
  }

  static Future<String> _convertWithLibreOffice(
    File file,
    String outputFormat,
    ProgressCallback onProgress,
    String libreOfficePath,
  ) async {
    onProgress(0.2, 'LibreOffice ile dönüştürülüyor...');

    final outputDir = await _getOutputDirectory('converted');
    await Directory(outputDir).create(recursive: true);

    final result = await Process.run(libreOfficePath, [
      '--headless',
      '--convert-to',
      outputFormat,
      '--outdir',
      outputDir,
      file.path,
    ]);

    if (result.exitCode != 0) {
      throw Exception('LibreOffice hatası: ${result.stderr}');
    }

    onProgress(0.9, 'Dosya hazırlanıyor...');

    final outputFileName =
        '${p.basenameWithoutExtension(file.path)}.$outputFormat';
    return p.join(outputDir, outputFileName);
  }

  static Future<String> _convertWithWindowsCom(
    File file,
    String appType,
    ProgressCallback onProgress,
  ) async {
    onProgress(0.2, 'Windows COM API ile dönüştürülüyor...');

    // PowerShell script ile dönüştürme
    final outputPath = await _getOutputPath(
        p.basenameWithoutExtension(file.path), 'pdf');

    final script = _buildPowerShellScript(file.path, outputPath, appType);
    final scriptFile = File(
        p.join(Directory.systemTemp.path, 'pdfmint_convert.ps1'));
    await scriptFile.writeAsString(script);

    onProgress(0.4, 'Dönüştürme başlatılıyor...');

    final result = await Process.run('powershell', [
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      scriptFile.path,
    ]);

    await scriptFile.delete();

    if (result.exitCode != 0) {
      throw Exception('Dönüştürme hatası: ${result.stderr}');
    }

    onProgress(1.0, 'Tamamlandı!');
    return outputPath;
  }

  static String _buildPowerShellScript(
      String inputPath, String outputPath, String appType) {
    switch (appType) {
      case 'word':
        return '''
\$word = New-Object -ComObject Word.Application
\$word.Visible = \$false
\$doc = \$word.Documents.Open("$inputPath")
\$doc.SaveAs("$outputPath", 17)  # 17 = wdFormatPDF
\$doc.Close()
\$word.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject(\$word) | Out-Null
''';
      case 'excel':
        return '''
\$excel = New-Object -ComObject Excel.Application
\$excel.Visible = \$false
\$workbook = \$excel.Workbooks.Open("$inputPath")
\$workbook.ExportAsFixedFormat(0, "$outputPath")  # 0 = xlTypePDF
\$workbook.Close()
\$excel.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject(\$excel) | Out-Null
''';
      case 'powerpoint':
        return '''
\$ppt = New-Object -ComObject PowerPoint.Application
\$presentation = \$ppt.Presentations.Open("$inputPath")
\$presentation.SaveAs("$outputPath", 32)  # 32 = ppSaveAsPDF
\$presentation.Close()
\$ppt.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject(\$ppt) | Out-Null
''';
      default:
        return '';
    }
  }

  static String _createRtfFromText(String text) {
    final escaped = text
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}');

    return '''{\\rtf1\\ansi\\deff0
{\\fonttbl{\\f0\\froman\\fcharset0 Times New Roman;}}
{\\colortbl ;\\red0\\green0\\blue0;}
\\f0\\fs24
${escaped.replaceAll('\n', '\\par\n')}
}''';
  }

  static Future<String> _getOutputPath(
      String baseName, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir =
        Directory(p.join(dir.path, 'PDFMint', 'output'));
    await outputDir.create(recursive: true);
    return p.join(outputDir.path, '$baseName.$extension');
  }

  static Future<String> _getOutputDirectory(String dirName) async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'PDFMint', 'output', dirName);
  }
}
