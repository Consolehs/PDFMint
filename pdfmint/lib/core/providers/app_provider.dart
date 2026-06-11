import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'tr';
  String _defaultSaveDir = '';
  bool _showMintyTips = true;
  int _processingThreads = 4;
  String _ocrLanguage = 'tur';

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  String get defaultSaveDir => _defaultSaveDir;
  bool get showMintyTips => _showMintyTips;
  int get processingThreads => _processingThreads;
  String get ocrLanguage => _ocrLanguage;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _language = prefs.getString('language') ?? 'tr';
    _defaultSaveDir = prefs.getString('defaultSaveDir') ?? '';
    _showMintyTips = prefs.getBool('showMintyTips') ?? true;
    _processingThreads = prefs.getInt('processingThreads') ?? 4;
    _ocrLanguage = prefs.getString('ocrLanguage') ?? 'tur';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setDefaultSaveDir(String dir) async {
    _defaultSaveDir = dir;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultSaveDir', dir);
    notifyListeners();
  }

  Future<void> setShowMintyTips(bool show) async {
    _showMintyTips = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showMintyTips', show);
    notifyListeners();
  }

  Future<void> setProcessingThreads(int threads) async {
    _processingThreads = threads;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('processingThreads', threads);
    notifyListeners();
  }

  Future<void> setOcrLanguage(String lang) async {
    _ocrLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ocrLanguage', lang);
    notifyListeners();
  }
}

// İşlem geçmişi modeli
class ProcessingHistory {
  final String id;
  final String toolId;
  final String toolName;
  final List<String> inputFiles;
  final String? outputFile;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final Duration duration;

  const ProcessingHistory({
    required this.id,
    required this.toolId,
    required this.toolName,
    required this.inputFiles,
    this.outputFile,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    required this.duration,
  });
}

class HistoryProvider extends ChangeNotifier {
  final List<ProcessingHistory> _history = [];

  List<ProcessingHistory> get history => List.unmodifiable(_history);

  void addHistory(ProcessingHistory entry) {
    _history.insert(0, entry);
    if (_history.length > 100) {
      _history.removeLast();
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
