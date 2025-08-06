import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/alert_dialog_widget.dart';
import '../widgets/custom_app_bar.dart';

/// Settings screen widget for managing app preferences and configurations
class SettingsScreen extends StatefulWidget {
  /// Creates a SettingsScreen widget
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _weatherAlerts = true;
  bool _diseaseAlerts = true;
  bool _marketPriceAlerts = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _temperatureUnit = 'Celsius';
  
  final List<String> _languages = [
    'English',
    'Hindi',
    'Bengali',
    'Telugu',
    'Tamil',
    'Gujarati',
    'Marathi',
    'Kannada',
    'Malayalam',
    'Punjabi'
  ];
  
  final List<String> _temperatureUnits = ['Celsius', 'Fahrenheit'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storageService = StorageService();
    
    setState(() {
      _notificationsEnabled = storageService.getBool('notifications_enabled') ?? true;
      _weatherAlerts = storageService.getBool('weather_alerts') ?? true;
      _diseaseAlerts = storageService.getBool('disease_alerts') ?? true;
      _marketPriceAlerts = storageService.getBool('market_price_alerts') ?? false;
      _darkMode = storageService.getBool('dark_mode') ?? false;
      _selectedLanguage = storageService.getString('selected_language') ?? 'English';
      _temperatureUnit = storageService.getString('temperature_unit') ?? 'Celsius';
    });
  }

  Future<void> _saveSettings() async {
    final storageService = StorageService();
    
    await storageService.saveBool('notifications_enabled', _notificationsEnabled);
    await storageService.saveBool('weather_alerts', _weatherAlerts);
    await storageService.saveBool('disease_alerts', _diseaseAlerts);
    await storageService.saveBool('market_price_alerts', _marketPriceAlerts);
    await storageService.saveBool('dark_mode', _darkMode);
    await storageService.saveString('selected_language', _selectedLanguage);
    await storageService.saveString('temperature_unit', _temperatureUnit);
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  _saveSettings();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showTemperatureUnitDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temperature Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _temperatureUnits.map((unit) {
            return RadioListTile<String>(
              title: Text('$unit (${unit == 'Celsius' ? '°C' : '°F'})'),
              value: unit,
              groupValue: _temperatureUnit,
              onChanged: (value) {
                setState(() => _temperatureUnit = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialogWidget(
        title: 'Logout',
        content: 'Are you sure you want to logout from your account?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
        onConfirm: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialogWidget(
        title: 'Delete Account',
        content: 'This action cannot be undone. All your data will be permanently deleted.',
        confirmText: 'Delete Account',
        cancelText: 'Cancel',
        onConfirm: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          try {
            // Changed from deleteUser() to deleteAccount() or similar method
            // You need to implement this method in your AuthProvider
            await authProvider.deleteAccount();
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete account: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: const CustomAppBar(title: 'Settings'),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications Section
        _buildSectionHeader('Notifications'),
        _buildNotificationSettings(),
        const SizedBox(height: 24),
        
        // Preferences Section
        _buildSectionHeader('Preferences'),
        _buildPreferencesSettings(),
        const SizedBox(height: 24),
        
        // Account Section
        _buildSectionHeader('Account'),
        _buildAccountSettings(),
        const SizedBox(height: 24),
        
        // Support Section
        _buildSectionHeader('Support & Information'),
        _buildSupportSettings(),
        const SizedBox(height: 24),
        
        // Danger Zone
        _buildSectionHeader('Danger Zone'),
        _buildDangerZoneSettings(),
      ],
    ),
  );

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _buildNotificationSettings() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive app notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSettings();
            if (value) {
              NotificationService().initialize();
            }
          },
          activeColor: AppColors.primary,
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Weather Alerts'),
          subtitle: const Text('Get notified about weather changes'),
          value: _weatherAlerts,
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() => _weatherAlerts = value);
                  _saveSettings();
                }
              : null,
          activeColor: AppColors.primary,
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Disease Alerts'),
          subtitle: const Text('Notifications about crop diseases'),
          value: _diseaseAlerts,
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() => _diseaseAlerts = value);
                  _saveSettings();
                }
              : null,
          activeColor: AppColors.primary,
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Market Price Alerts'),
          subtitle: const Text('Updates on crop price changes'),
          value: _marketPriceAlerts,
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() => _marketPriceAlerts = value);
                  _saveSettings();
                }
              : null,
          activeColor: AppColors.primary,
        ),
      ],
    ),
  );

  Widget _buildPreferencesSettings() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
                setState(() => _darkMode = value);
                _saveSettings();
              },
              activeColor: AppColors.primary,
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_selectedLanguage),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showLanguageDialog,
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Temperature Unit'),
          subtitle: Text('$_temperatureUnit (${_temperatureUnit == 'Celsius' ? '°C' : '°F'})'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showTemperatureUnitDialog,
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Data & Storage'),
          subtitle: const Text('Manage app data usage'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/data_management');
          },
        ),
      ],
    ),
  );

  Widget _buildAccountSettings() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: AppColors.primary),
          title: const Text('Edit Profile'),
          subtitle: const Text('Update your personal information'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.security, color: AppColors.primary),
          title: const Text('Security'),
          subtitle: const Text('Password, authentication settings'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/security_settings');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.cloud_sync, color: AppColors.primary),
          title: const Text('Sync Data'),
          subtitle: const Text('Backup and sync your data'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data sync initiated')),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildSupportSettings() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.help, color: AppColors.primary),
          title: const Text('Help & FAQ'),
          subtitle: const Text('Get help and find answers'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/help');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.feedback, color: AppColors.primary),
          title: const Text('Send Feedback'),
          subtitle: const Text('Help us improve the app'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchUrl('mailto:feedback@agridirect.com?subject=App Feedback');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.star_rate, color: AppColors.primary),
          title: const Text('Rate App'),
          subtitle: const Text('Rate us on app store'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchUrl('https://play.google.com/store/apps/details?id=com.agridirect.app');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.info, color: AppColors.primary),
          title: const Text('About'),
          subtitle: Text('AgriDirect v${AppConstants.appVersion}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.privacy_tip, color: AppColors.primary),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchUrl('https://agridirect.com/privacy-policy');
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.description, color: AppColors.primary),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchUrl('https://agridirect.com/terms-of-service');
          },
        ),
      ],
    ),
  );

  Widget _buildDangerZoneSettings() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.logout, color: AppColors.error),
          title: Text(
            'Logout',
            style: TextStyle(color: AppColors.error),
          ),
          subtitle: const Text('Sign out of your account'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showLogoutDialog,
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.delete_forever, color: AppColors.error),
          title: Text(
            'Delete Account',
            style: TextStyle(color: AppColors.error),
          ),
          subtitle: const Text('Permanently delete your account'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showDeleteAccountDialog,
        ),
      ],
    ),
  );
}