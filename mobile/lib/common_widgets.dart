import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'animals_page.dart';
import 'alerts_page.dart';
import 'profile_page.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSettings;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showSettings = true,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF06402b), Color(0xFF002819)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFfbbf24),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFfbbf24),
                      size: 20,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (showSettings)
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF06402B),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.settings, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Column(
        children: [
          AppHeader(
            title: 'Settings',
            showBackButton: true,
            showSettings: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingItem(
                  Icons.notifications_outlined,
                  'Notifications',
                  () {},
                ),
                _buildSettingItem(
                  Icons.lock_outline,
                  'Privacy & Security',
                  () {},
                ),
                _buildSettingItem(Icons.language, 'Language', () {}),
                _buildSettingItem(Icons.dark_mode_outlined, 'Dark Mode', () {}),
                _buildSettingItem(Icons.help_outline, 'Help Center', () {}),
                _buildSettingItem(Icons.info_outline, 'About', () {}),
                _buildSettingItem(
                  Icons.privacy_tip_outlined,
                  'Terms & Conditions',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF06402B)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF06402B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF717973)),
      ),
    );
  }
}
