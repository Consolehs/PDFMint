import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:confetti/confetti.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../models/pdf_tool.dart';
import '../../shared/widgets/minty_mascot.dart';
import '../../services/pdf_service.dart';

class ToolScreen extends StatefulWidget {
  final PdfTool tool;

  const ToolScreen({super.key, required this.tool});

  @override
  State<ToolScreen> createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  final List<File> _selectedFiles = [];
  bool _isDragging = false;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusMessage = '';
  bool _isSuccess = false;
  String? _outputPath;
  late ConfettiController _confettiController;
  MintyMood _mintyMood = MintyMood.happy;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tool = widget.tool;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tool.icon, color: tool.color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(tool.title),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Sol Panel - Dosya Seçimi
              Expanded(
                flex: 3,
                child: _buildFilePanel(isDark),
              ),
              // Sağ Panel - Ayarlar ve İşlem
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: Border(
                    left: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: _buildOptionsPanel(isDark),
              ),
            ],
          ),
          // Konfeti Efekti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                Colors.white,
                AppColors.success,
              ],
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePanel(bool isDark) {
    return Column(
      children: [
        // Sürükle-Bırak Alanı
        Expanded(
          child: DropTarget(
            onDragDone: (details) {
              setState(() {
                _isDragging = false;
                for (final file in details.files) {
                  _selectedFiles.add(File(file.path));
                }
              });
            },
            onDragEntered: (_) => setState(() => _isDragging = true),
            onDragExited: (_) => setState(() => _isDragging = false),
            child: _selectedFiles.isEmpty
                ? _buildDropZone(isDark)
                : _buildFileList(isDark),
          ),
        ),
        // Alt Araç Çubuğu
        if (_selectedFiles.isNotEmpty) _buildFileToolbar(isDark),
      ],
    );
  }

  Widget _buildDropZone(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isDragging
            ? AppColors.primary.withOpacity(0.08)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDragging
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: _isDragging ? 2 : 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _pickFiles,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(_isDragging ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isDragging
                      ? Icons.file_download_rounded
                      : Icons.upload_file_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isDragging
                    ? 'Dosyaları buraya bırak!'
                    : 'Dosyaları sürükle & bırak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _isDragging
                      ? AppColors.primary
                      : (isDark ? AppColors.darkText : AppColors.lightText),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'veya tıklayarak dosya seç',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildFileTypeChips(isDark),
              const SizedBox(height: 32),
              MintyHelpBubble(
                message: _getMintyTip(),
                mood: MintyMood.thinking,
                mascotSize: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeChips(bool isDark) {
    final types = _getAcceptedFileTypes();
    return Wrap(
      spacing: 8,
      children: types
          .map((type) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFileList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Text(
                '${_selectedFiles.length} dosya seçildi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Dosya Ekle'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return _buildFileItem(file, index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(File file, int index, bool isDark) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = file.existsSync()
        ? _formatFileSize(file.lengthSync())
        : 'Bilinmiyor';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () =>
                setState(() => _selectedFiles.removeAt(index)),
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildFileToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedFiles.clear()),
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const Text('Temizle'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
          const Spacer(),
          Text(
            'Toplam: ${_selectedFiles.length} dosya',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsPanel(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Başlığı
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Seçenekler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
        Divider(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        // İşlem Seçenekleri
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildToolOptions(isDark),
          ),
        ),
        // İşlem Butonu ve Durum
        _buildActionSection(isDark),
      ],
    );
  }

  Widget _buildToolOptions(bool isDark) {
    // Araç tipine göre özel seçenekler
    switch (widget.tool.id) {
      case 'compress':
        return _buildCompressOptions(isDark);
      case 'split':
        return _buildSplitOptions(isDark);
      case 'rotate':
        return _buildRotateOptions(isDark);
      case 'watermark':
        return _buildWatermarkOptions(isDark);
      case 'encrypt':
        return _buildEncryptOptions(isDark);
      case 'numbering':
        return _buildNumberingOptions(isDark);
      default:
        return _buildDefaultOptions(isDark);
    }
  }

  Widget _buildDefaultOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MintyHelpBubble(
          message: _getMintyTip(),
          mood: MintyMood.happy,
          mascotSize: 44,
        ),
        const SizedBox(height: 20),
        _buildOutputFormatSection(isDark),
      ],
    );
  }

  Widget _buildCompressOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sıkıştırma Seviyesi', isDark),
        const SizedBox(height: 12),
        ...['Düşük (Yüksek Kalite)', 'Orta (Dengeli)', 'Yüksek (Küçük Boyut)']
            .asMap()
            .entries
            .map((e) => _buildRadioOption(e.value, e.key == 1, isDark)),
        const SizedBox(height: 20),
        MintyHelpBubble(
          message:
              'Orta seviye genellikle en iyi denge noktasıdır. Görüntü kalitesini korurken boyutu %40-60 küçültebilir.',
          mood: MintyMood.thinking,
          mascotSize: 40,
        ),
      ],
    );
  }

  Widget _buildSplitOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Bölme Yöntemi', isDark),
        const SizedBox(height: 12),
        ...['Her sayfayı ayrı kaydet', 'Sayfa aralığı belirt', 'Eşit parçalara böl']
            .asMap()
            .entries
            .map((e) => _buildRadioOption(e.value, e.key == 0, isDark)),
      ],
    );
  }

  Widget _buildRotateOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Döndürme Açısı', isDark),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['90° Sağ', '90° Sol', '180°'].map((angle) {
            return OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.rotate_right_rounded, size: 16),
              label: Text(angle),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Hangi Sayfalar', isDark),
        const SizedBox(height: 8),
        ...['Tüm sayfalar', 'Seçili sayfalar', 'Tek sayfalar', 'Çift sayfalar']
            .asMap()
            .entries
            .map((e) => _buildRadioOption(e.value, e.key == 0, isDark)),
      ],
    );
  }

  Widget _buildWatermarkOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filigran Tipi', isDark),
        const SizedBox(height: 12),
        ...['Metin Filigranı', 'Resim Filigranı']
            .asMap()
            .entries
            .map((e) => _buildRadioOption(e.value, e.key == 0, isDark)),
        const SizedBox(height: 16),
        _buildSectionTitle('Filigran Metni', isDark),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Örn: GİZLİ, TASLAK...',
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Opaklık', isDark),
        Slider(
          value: 0.3,
          onChanged: (_) {},
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEncryptOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Parola', isDark),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Güçlü bir parola girin',
            prefixIcon: const Icon(Icons.lock_rounded, size: 18),
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Parolayı tekrar girin',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        MintyHelpBubble(
          message:
              'Güçlü bir parola için büyük-küçük harf, rakam ve özel karakter kullan!',
          mood: MintyMood.thinking,
          mascotSize: 40,
        ),
      ],
    );
  }

  Widget _buildNumberingOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Numara Konumu', isDark),
        const SizedBox(height: 12),
        ...['Alt Orta', 'Alt Sağ', 'Alt Sol', 'Üst Orta', 'Üst Sağ']
            .asMap()
            .entries
            .map((e) => _buildRadioOption(e.value, e.key == 0, isDark)),
        const SizedBox(height: 16),
        _buildSectionTitle('Başlangıç Numarası', isDark),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1',
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputFormatSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Çıktı Formatı', isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: DropdownButton<String>(
            value: 'PDF',
            isExpanded: true,
            underline: const SizedBox(),
            items: ['PDF', 'PDF/A'].map((format) {
              return DropdownMenuItem(value: format, child: Text(format));
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildRadioOption(String label, bool selected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_isProcessing) ...[
            Row(
              children: [
                MintyMascot(
                    mood: MintyMood.working, size: 36, animate: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_isSuccess && _outputPath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'İşlem tamamlandı!',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openOutputFolder(),
                    child: const Text('Klasörü Aç'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedFiles.isEmpty || _isProcessing
                  ? null
                  : _processFiles,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(widget.tool.icon, size: 18),
              label: Text(
                _isProcessing ? 'İşleniyor...' : widget.tool.title,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.tool.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _getAllowedExtensions(),
    );

    if (result != null) {
      setState(() {
        for (final file in result.files) {
          if (file.path != null) {
            _selectedFiles.add(File(file.path!));
          }
        }
      });
    }
  }

  Future<void> _processFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isSuccess = false;
      _progress = 0.0;
      _statusMessage = 'İşlem başlatılıyor...';
      _mintyMood = MintyMood.working;
    });

    try {
      final service = PdfService();
      final outputPath = await service.processFiles(
        toolId: widget.tool.id,
        inputFiles: _selectedFiles,
        onProgress: (progress, message) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _statusMessage = message;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _outputPath = outputPath;
          _progress = 1.0;
          _statusMessage = 'Tamamlandı!';
          _mintyMood = MintyMood.celebrating;
        });
        _confettiController.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _statusMessage = 'Hata: ${e.toString()}';
          _mintyMood = MintyMood.sad;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            MintyMascot(mood: MintyMood.sad, size: 40),
            const SizedBox(width: 12),
            const Text('Bir sorun oluştu'),
          ],
        ),
        content: Text(
          'Endişelenme! Şunları deneyebilirsin:\n\n• Dosyanın bozuk olmadığından emin ol\n• Farklı bir dosya seç\n• Uygulamayı yeniden başlat\n\nHata: $error',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _openOutputFolder() {
    if (_outputPath != null) {
      final dir = File(_outputPath!).parent.path;
      Process.run('explorer', [dir]);
    }
  }

  List<String> _getAllowedExtensions() {
    switch (widget.tool.id) {
      case 'word_to_pdf':
        return ['doc', 'docx'];
      case 'excel_to_pdf':
        return ['xls', 'xlsx'];
      case 'ppt_to_pdf':
        return ['ppt', 'pptx'];
      case 'jpg_to_pdf':
        return ['jpg', 'jpeg'];
      case 'png_to_pdf':
        return ['png'];
      default:
        return ['pdf'];
    }
  }

  List<String> _getAcceptedFileTypes() {
    switch (widget.tool.id) {
      case 'word_to_pdf':
        return ['.DOC', '.DOCX'];
      case 'excel_to_pdf':
        return ['.XLS', '.XLSX'];
      case 'ppt_to_pdf':
        return ['.PPT', '.PPTX'];
      case 'jpg_to_pdf':
        return ['.JPG', '.JPEG'];
      case 'png_to_pdf':
        return ['.PNG'];
      default:
        return ['.PDF'];
    }
  }

  String _getMintyTip() {
    final tips = {
      'merge': 'Dosyaları istediğin sırayla sürükleyerek birleştirebilirsin!',
      'split': 'Büyük PDF\'leri küçük parçalara bölerek paylaşımı kolaylaştır.',
      'compress':
          'Sıkıştırma, e-posta eklerine mükemmel! Boyutu %60\'a kadar küçültebilirim.',
      'rotate': 'Taranmış belgeleri düzeltmek için harika!',
      'encrypt': 'Güçlü şifreleme ile belgelerini güvende tut!',
      'ocr': 'Taranmış belgelerdeki metni dijitale aktarıyorum!',
      'watermark': 'Telif hakkı veya gizlilik için filigran ekleyebilirsin.',
    };
    return tips[widget.tool.id] ??
        '${widget.tool.title} işlemi için dosyaları seç ve başla!';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
