import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'data_provider.dart';
import 'navigation.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _darkMode = false;
  bool _locationTracking = true;
  String _temperatureUnit = 'Celsius';
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = context.read<DataProvider>().locale;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();
    final tr = data.tr;
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFAF1F5),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFAF1F5), Color(0xFFfafaf5)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF06402B),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('settings.title'),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF06402B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(tr('settings.account')),
                  _buildCard([
                    _buildSettingTile(
                      icon: Icons.person,
                      title: tr('common.name'),
                      subtitle: user?['name'] ?? 'Admin',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.email,
                      title: tr('auth.email'),
                      subtitle: user?['email'] ?? 'admin@oasis.com',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.phone,
                      title: tr('users.phone'),
                      subtitle: user?['phone'] ?? '+966501234567',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader(tr('settings.notifications')),
                  _buildCard([
                    _buildSwitchTile(
                      icon: Icons.notifications,
                      title: tr('settings.pushNotifications'),
                      subtitle: tr('settings.pushNotificationsSubtitle'),
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.email,
                      title: tr('settings.emailNotifications'),
                      subtitle: tr('settings.emailNotificationsSubtitle'),
                      value: _emailNotifications,
                      onChanged: (v) => setState(() => _emailNotifications = v),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader(tr('settings.appSettings')),
                  _buildCard([
                    _buildSwitchTile(
                      icon: Icons.dark_mode,
                      title: tr('settings.darkMode'),
                      subtitle: tr('settings.darkModeSubtitle'),
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.location_on,
                      title: tr('settings.locationTracking'),
                      subtitle: tr('settings.locationTrackingSubtitle'),
                      value: _locationTracking,
                      onChanged: (v) => setState(() => _locationTracking = v),
                    ),
                    _buildDropdownTile(
                      icon: Icons.thermostat,
                      title: tr('settings.temperatureUnit'),
                      value: _temperatureUnit,
                      items: ['Celsius', 'Fahrenheit'],
                      onChanged: (v) => setState(() => _temperatureUnit = v!),
                    ),
                    _buildDropdownTile(
                      icon: Icons.language,
                      title: tr('settings.language'),
                      value: _selectedLanguageCode ?? data.locale,
                      items: data.languages.map((l) => l['name'] as String? ?? l['code'] as String).toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        final lang = data.languages.firstWhere(
                          (l) => l['name'] == v,
                          orElse: () => {'code': 'en'},
                        );
                        final code = lang['code'] as String;
                        await data.setLocale(code);
                        if (mounted) {
                          setState(() {
                            _selectedLanguageCode = v;
                          });
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader(tr('settings.about')),
                  _buildCard([
                    _buildSettingTile(
                      icon: Icons.info,
                      title: tr('settings.appVersion'),
                      subtitle: '1.0.0',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.policy,
                      title: tr('settings.privacyPolicy'),
                      subtitle: tr('settings.privacyPolicy'),
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.description,
                      title: tr('settings.termsOfService'),
                      subtitle: tr('settings.termsOfService'),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFba1a1a),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(tr('settings.signOut')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF06402B),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF06402B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF717973)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Color(0xFF06402B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF06402B),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF06402B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}
