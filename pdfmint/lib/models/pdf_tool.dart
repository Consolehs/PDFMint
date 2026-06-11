import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum ToolCategory {
  organize,
  convert,
  edit,
  security,
  ocr,
  optimize,
}

extension ToolCategoryExtension on ToolCategory {
  String get label {
    switch (this) {
      case ToolCategory.organize:
        return 'Düzenle';
      case ToolCategory.convert:
        return 'Dönüştür';
      case ToolCategory.edit:
        return 'Düzenle';
      case ToolCategory.security:
        return 'Güvenlik';
      case ToolCategory.ocr:
        return 'OCR';
      case ToolCategory.optimize:
        return 'Optimize';
    }
  }

  Color get color {
    switch (this) {
      case ToolCategory.organize:
        return AppColors.toolOrganize;
      case ToolCategory.convert:
        return AppColors.toolConvert;
      case ToolCategory.edit:
        return AppColors.toolEdit;
      case ToolCategory.security:
        return AppColors.toolSecurity;
      case ToolCategory.ocr:
        return AppColors.toolOcr;
      case ToolCategory.optimize:
        return AppColors.toolOptimize;
    }
  }

  IconData get icon {
    switch (this) {
      case ToolCategory.organize:
        return Icons.folder_special_rounded;
      case ToolCategory.convert:
        return Icons.swap_horiz_rounded;
      case ToolCategory.edit:
        return Icons.edit_rounded;
      case ToolCategory.security:
        return Icons.security_rounded;
      case ToolCategory.ocr:
        return Icons.text_fields_rounded;
      case ToolCategory.optimize:
        return Icons.tune_rounded;
    }
  }
}

class PdfTool {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final Color? customColor;
  final bool isNew;
  final bool isPro;

  const PdfTool({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.customColor,
    this.isNew = false,
    this.isPro = false,
  });

  Color get color => customColor ?? category.color;
}

// Tüm araçların listesi
class PdfTools {
  static const List<PdfTool> all = [
    // Düzenleme & Organizasyon
    PdfTool(
      id: 'merge',
      title: 'PDF Birleştir',
      description: 'Birden fazla PDF\'yi tek dosyada birleştir',
      icon: Icons.merge_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'split',
      title: 'PDF Böl',
      description: 'PDF\'yi sayfalara veya bölümlere ayır',
      icon: Icons.call_split_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'rotate',
      title: 'PDF Döndür',
      description: 'Sayfaları istediğin açıda döndür',
      icon: Icons.rotate_right_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'delete_pages',
      title: 'Sayfa Sil',
      description: 'İstenmeyen sayfaları kaldır',
      icon: Icons.delete_sweep_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'add_pages',
      title: 'Sayfa Ekle',
      description: 'PDF\'ye yeni sayfalar ekle',
      icon: Icons.add_box_rounded,
      category: ToolCategory.organize,
    ),
    PdfTool(
      id: 'reorder',
      title: 'Yeniden Sırala',
      description: 'Sayfaları sürükle-bırak ile yeniden sırala',
      icon: Icons.reorder_rounded,
      category: ToolCategory.organize,
    ),

    // Dönüştürme - PDF'ye
    PdfTool(
      id: 'word_to_pdf',
      title: 'Word → PDF',
      description: 'Word belgelerini PDF\'ye dönüştür',
      icon: Icons.description_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFF2B579A),
    ),
    PdfTool(
      id: 'excel_to_pdf',
      title: 'Excel → PDF',
      description: 'Excel tablolarını PDF\'ye dönüştür',
      icon: Icons.table_chart_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFF217346),
    ),
    PdfTool(
      id: 'ppt_to_pdf',
      title: 'PowerPoint → PDF',
      description: 'Sunumları PDF\'ye dönüştür',
      icon: Icons.slideshow_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFFD24726),
    ),
    PdfTool(
      id: 'jpg_to_pdf',
      title: 'JPG → PDF',
      description: 'JPEG resimlerini PDF\'ye dönüştür',
      icon: Icons.image_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFFFF6B6B),
    ),
    PdfTool(
      id: 'png_to_pdf',
      title: 'PNG → PDF',
      description: 'PNG resimlerini PDF\'ye dönüştür',
      icon: Icons.photo_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFF9B59B6),
    ),

    // Dönüştürme - PDF'den
    PdfTool(
      id: 'pdf_to_word',
      title: 'PDF → Word',
      description: 'PDF\'yi düzenlenebilir Word\'e dönüştür',
      icon: Icons.article_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFF2B579A),
    ),
    PdfTool(
      id: 'pdf_to_excel',
      title: 'PDF → Excel',
      description: 'PDF tablolarını Excel\'e aktar',
      icon: Icons.grid_on_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFF217346),
    ),
    PdfTool(
      id: 'pdf_to_image',
      title: 'PDF → Resim',
      description: 'PDF sayfalarını resim olarak kaydet',
      icon: Icons.photo_library_rounded,
      category: ToolCategory.convert,
      customColor: Color(0xFFE67E22),
    ),

    // Düzenleme
    PdfTool(
      id: 'watermark',
      title: 'Filigran Ekle',
      description: 'PDF\'ye metin veya resim filigranı ekle',
      icon: Icons.branding_watermark_rounded,
      category: ToolCategory.edit,
    ),
    PdfTool(
      id: 'numbering',
      title: 'Numaralandır',
      description: 'Sayfalara otomatik numara ekle',
      icon: Icons.format_list_numbered_rounded,
      category: ToolCategory.edit,
    ),
    PdfTool(
      id: 'metadata',
      title: 'Metadata Düzenle',
      description: 'Başlık, yazar, konu bilgilerini düzenle',
      icon: Icons.info_outline_rounded,
      category: ToolCategory.edit,
    ),

    // Güvenlik
    PdfTool(
      id: 'encrypt',
      title: 'PDF Şifrele',
      description: 'PDF\'yi parola ile koru',
      icon: Icons.lock_rounded,
      category: ToolCategory.security,
    ),
    PdfTool(
      id: 'decrypt',
      title: 'Şifre Kaldır',
      description: 'PDF\'den parola korumasını kaldır',
      icon: Icons.lock_open_rounded,
      category: ToolCategory.security,
    ),
    PdfTool(
      id: 'sign',
      title: 'PDF İmzala',
      description: 'PDF\'ye dijital imza ekle',
      icon: Icons.draw_rounded,
      category: ToolCategory.security,
    ),

    // OCR & Analiz
    PdfTool(
      id: 'ocr',
      title: 'OCR Metin Tanıma',
      description: 'Taranmış PDF\'den metin çıkar',
      icon: Icons.document_scanner_rounded,
      category: ToolCategory.ocr,
      isNew: true,
    ),
    PdfTool(
      id: 'compare',
      title: 'PDF Karşılaştır',
      description: 'İki PDF arasındaki farkları bul',
      icon: Icons.compare_rounded,
      category: ToolCategory.ocr,
    ),

    // Optimize
    PdfTool(
      id: 'compress',
      title: 'PDF Sıkıştır',
      description: 'Dosya boyutunu küçült, kaliteyi koru',
      icon: Icons.compress_rounded,
      category: ToolCategory.optimize,
    ),
    PdfTool(
      id: 'repair',
      title: 'PDF Onar',
      description: 'Bozuk PDF dosyalarını kurtarmaya çalış',
      icon: Icons.build_rounded,
      category: ToolCategory.optimize,
    ),
  ];

  static List<PdfTool> byCategory(ToolCategory category) {
    return all.where((tool) => tool.category == category).toList();
  }

  static PdfTool? findById(String id) {
    try {
      return all.firstWhere((tool) => tool.id == id);
    } catch (_) {
      return null;
    }
  }
}
