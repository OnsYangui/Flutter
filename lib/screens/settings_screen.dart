import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/theme_colors.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'fr';

  final Map<String, String> _languages = {
    'fr': 'Français',
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _darkMode = themeProvider.isDarkMode;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _selectedLanguage = prefs.getString(AppConstants.prefLanguage) ?? 'fr';
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    if (key == AppConstants.prefThemeMode && mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.toggleTheme(value);
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.changeLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Paramètres'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: context.bgColor,
      body: ListView(
        children: [
          _buildSectionHeader(AppLocalizations.of(context)?.appearance ?? 'Apparence'),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)?.darkMode ?? 'Mode sombre'),
            subtitle: const Text('Activer le thème sombre'),
            secondary: const Icon(Icons.dark_mode),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              _saveSetting(AppConstants.prefThemeMode, value);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)?.language ?? 'Langue'),
            subtitle: Text(_languages[_selectedLanguage] ?? 'Français'),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(),
          _buildSectionHeader(AppLocalizations.of(context)?.notifications ?? 'Notifications'),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)?.notifications ?? 'Activer les notifications'),
            subtitle: Text(AppLocalizations.of(context)?.medicationReminders ?? 'Recevoir des rappels pour les médicaments'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSetting('notifications_enabled', value);
            },
          ),
          const Divider(),
          _buildSectionHeader(AppLocalizations.of(context)?.sounds ?? 'Effets'),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)?.sounds ?? 'Sons'),
            subtitle: const Text('Activer les effets sonores'),
            secondary: const Icon(Icons.volume_up),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _saveSetting('sound_enabled', value);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)?.vibration ?? 'Vibration'),
            subtitle: const Text('Activer le retour haptique'),
            secondary: const Icon(Icons.vibration),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _saveSetting('vibration_enabled', value);
            },
          ),
          const Divider(),
          _buildSectionHeader(AppLocalizations.of(context)?.about ?? 'À propos'),
          ListTile(
            title: Text(AppLocalizations.of(context)?.about ?? 'À propos de MediAssist'),
            subtitle: Text('${AppLocalizations.of(context)?.version ?? 'Version'} 1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            title: const Text('ML Kit'),
            subtitle: const Text('Services d\'IA utilisés'),
            leading: const Icon(Icons.smart_toy),
            onTap: () {
              _showMLKitInfo();
            },
          ),
          ListTile(
            title: const Text('Licences'),
            leading: const Icon(Icons.description),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de MediAssist'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MediAssist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Application de suivi médical personnel pour maladies chroniques, intégrant les services d\'IA de Google ML Kit.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showMLKitInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('ML Kit'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Services d\'IA utilisés:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _MLKitFeatureTile(
                icon: Icons.text_fields,
                title: 'Reconnaissance de texte (OCR)',
                description: 'Extrait le texte des ordonnances médicales',
              ),
              SizedBox(height: 12),
              _MLKitFeatureTile(
                icon: Icons.qr_code_scanner,
                title: 'Lecture de codes-barres',
                description: 'Scanne les codes-barres des médicaments',
              ),
              SizedBox(height: 12),
              _MLKitFeatureTile(
                icon: Icons.image_search,
                title: 'Étiquetage d\'image',
                description: 'Identifie des objets et éléments dans les images',
              ),
              SizedBox(height: 16),
              Text(
                'Tous les traitements sont effectués sur l\'appareil (offline) pour garantir la confidentialité des données.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context)?.language ?? 'Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MLKitFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MLKitFeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
