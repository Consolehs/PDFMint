import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/widgets/minty_mascot.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: const Text('Ayarlar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görünüm
            _buildSection(
              'Görünüm',
              Icons.palette_rounded,
              [
                _buildThemeSelector(context, appProvider, isDark),
              ],
              isDark,
            ),
            const SizedBox(height: 20),

            // Dosya İşlemleri
            _buildSection(
              'Dosya İşlemleri',
              Icons.folder_rounded,
              [
                _buildSaveDirectorySetting(context, appProvider, isDark),
              ],
              isDark,
            ),
            const SizedBox(height: 20),

            // OCR Ayarları
            _buildSection(
              'OCR Metin Tanıma',
              Icons.document_scanner_rounded,
              [
                _buildOcrLanguageSetting(context, appProvider, isDark),
              ],
              isDark,
            ),
            const SizedBox(height: 20),

            // Performans
            _buildSection(
              'Performans',
              Icons.speed_rounded,
              [
                _buildThreadsSetting(context, appProvider, isDark),
              ],
              isDark,
            ),
            const SizedBox(height: 20),

            // Minty
            _buildSection(
              'Minty Maskot',
              Icons.emoji_emotions_rounded,
              [
                _buildMintyToggle(context, appProvider, isDark),
              ],
              isDark,
            ),
            const SizedBox(height: 32),

            // Hakkında
            _buildAboutCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildThemeSelector(
      BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeOption(
                context,
                'Aydınlık',
                Icons.light_mode_rounded,
                ThemeMode.light,
                provider,
                isDark,
              ),
              const SizedBox(width: 12),
              _buildThemeOption(
                context,
                'Karanlık',
                Icons.dark_mode_rounded,
                ThemeMode.dark,
                provider,
                isDark,
              ),
              const SizedBox(width: 12),
              _buildThemeOption(
                context,
                'Sistem',
                Icons.brightness_auto_rounded,
                ThemeMode.system,
                provider,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode mode,
    AppProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : (isDark ? AppColors.darkBackground : AppColors.lightGrey),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveDirectorySetting(
      BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varsayılan Kayıt Klasörü',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    provider.defaultSaveDir.isEmpty
                        ? 'Seçilmedi (Kaynak klasör kullanılır)'
                        : provider.defaultSaveDir,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final result =
                      await FilePicker.platform.getDirectoryPath();
                  if (result != null) {
                    provider.setDefaultSaveDir(result);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Seç'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOcrLanguageSetting(
      BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OCR Dili',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: DropdownButton<String>(
              value: provider.ocrLanguage,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'tur', child: Text('Türkçe')),
                DropdownMenuItem(value: 'eng', child: Text('İngilizce')),
                DropdownMenuItem(value: 'deu', child: Text('Almanca')),
                DropdownMenuItem(value: 'fra', child: Text('Fransızca')),
                DropdownMenuItem(value: 'spa', child: Text('İspanyolca')),
                DropdownMenuItem(value: 'ara', child: Text('Arapça')),
              ],
              onChanged: (v) {
                if (v != null) provider.setOcrLanguage(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadsSetting(
      BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İşlem Çekirdek Sayısı',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${provider.processingThreads} çekirdek',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: provider.processingThreads.toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            activeColor: AppColors.primary,
            onChanged: (v) => provider.setProcessingThreads(v.round()),
          ),
          Text(
            'Daha fazla çekirdek = Daha hızlı işlem (ancak daha fazla RAM kullanır)',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMintyToggle(
      BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          MintyMascot(
            mood: provider.showMintyTips
                ? MintyMood.happy
                : MintyMood.sad,
            size: 44,
            animate: provider.showMintyTips,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minty\'nin İpuçları',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                Text(
                  'Minty, araçları kullanırken yardımcı ipuçları gösterir',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.showMintyTips,
            onChanged: (v) => provider.setShowMintyTips(v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkHeroGradient : AppColors.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          MintyMascot(
            mood: MintyMood.happy,
            size: 60,
            animate: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDFMint v1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.darkText : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamamen offline çalışan PDF araçları.\nVerilerin hiçbir zaman buluta gönderilmez.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.darkGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAboutChip('🔒 Offline'),
                    const SizedBox(width: 8),
                    _buildAboutChip('⚡ Hızlı'),
                    const SizedBox(width: 8),
                    _buildAboutChip('🆓 Ücretsiz'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildAboutChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDeep,
        ),
      ),
    );
  }
}
