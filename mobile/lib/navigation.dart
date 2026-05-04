import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'map_page.dart';
import 'animals_page.dart';
import 'alerts_page.dart';
import 'profile_page.dart';
import 'team_page.dart';
import 'devices_page.dart';
import 'geofences_page.dart';
import 'tasks_page.dart';
import 'auction_page.dart';
import 'vaccination_page.dart';
import 'medical_records_page.dart';
import 'settings_page.dart';
import 'reports_page.dart';

class PageNavigator {
  static void navigateToPage(
    BuildContext context,
    String pageName, {
    Map<String, dynamic>? args,
  }) {
    Widget page;
    switch (pageName) {
      case 'Dashboard':
        page = DashboardPage();
        break;
      case 'Map':
        page = MapPage();
        break;
      case 'Animals':
        page = AnimalsPage();
        break;
      case 'Alerts':
        page = AlertsPage();
        break;
      case 'Profile':
        page = ProfilePage();
        break;
      case 'Team':
        page = TeamPage();
        break;
      case 'Devices':
        page = DevicesPage();
        break;
      case 'Geofences':
        page = GeofencesPage();
        break;
      case 'Tasks':
        page = TasksPage();
        break;
      case 'Auctions':
        page = AuctionPage();
        break;
      case 'Vaccinations':
        page = VaccinationPage();
        break;
      case 'MedicalRecords':
        page = MedicalRecordsPage();
        break;
      case 'Settings':
        page = SettingsPage();
        break;
      case 'Reports':
        page = ReportsPage();
        break;
      default:
        page = DashboardPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  static void navigateAndReplace(BuildContext context, String pageName) {
    Widget page;
    switch (pageName) {
      case 'Dashboard':
        page = DashboardPage();
        break;
      case 'Map':
        page = MapPage();
        break;
      case 'Animals':
      case 'MedicalRecords':
      case 'Settings':
      case 'Vaccinations':
        page = AnimalsPage();
        break;
      case 'Alerts':
        page = AlertsPage();
        break;
      case 'Profile':
        page = ProfilePage();
        break;
      case 'Team':
        page = TeamPage();
        break;
      case 'Devices':
        page = DevicesPage();
        break;
      case 'Geofences':
        page = GeofencesPage();
        break;
      case 'Tasks':
        page = TasksPage();
        break;
      case 'Auctions':
        page = AuctionPage();
        break;
      case 'Vaccinations':
        page = VaccinationPage();
        break;
      case 'Reports':
        page = ReportsPage();
        break;
      default:
        page = DashboardPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  static void goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

const Map<String, List<String>> pageNavigationTree = {
  'Dashboard': ['Map', 'Animals', 'Alerts', 'Profile'],
  'Map': ['Dashboard', 'Animals', 'Alerts', 'Profile', 'Home'],
  'Animals': ['Dashboard', 'Map', 'Alerts', 'Profile'],
  'Alerts': ['Dashboard', 'Map', 'Animals', 'Profile'],
  'Profile': [
    'Dashboard',
    'Team',
    'Animals',
    'Geofences',
    'Devices',
    'Tasks',
    'Auctions',
  ],
  'Team': ['Profile'],
  'Devices': ['Profile'],
  'Geofences': ['Profile'],
  'Tasks': ['Profile'],
  'Auctions': ['Dashboard', 'Map', 'Animals', 'Alerts', 'Profile'],
  'Reports': ['Dashboard', 'Map', 'Animals', 'Alerts', 'Profile'],
};

const List<String> bottomNavItems = [
  'Home',
  'Map',
  'Animals',
  'Alerts',
  'Profile',
];

List<IconData> bottomNavIcons = [
  Icons.home,
  Icons.map,
  Icons.pets,
  Icons.notifications_active,
  Icons.person,
];

class UnifiedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showAuctions;

  const UnifiedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showAuctions = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = showAuctions
        ? ['Home', 'Map', 'Animals', 'Auctions', 'Profile']
        : bottomNavItems;
    final icons = showAuctions
        ? [Icons.home, Icons.map, Icons.pets, Icons.gavel, Icons.person]
        : bottomNavIcons;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF002819),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = currentIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFfbbf24).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index],
                        color: isActive
                            ? const Color(0xFFfbbf24)
                            : Colors.white.withOpacity(0.5),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFFfbbf24)
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showSettings;
  final Widget? trailing;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.showSettings = true,
    this.trailing,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF06402b), Color(0xFF002819)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (showBack)
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
                onTap: () => PageNavigator.navigateToPage(context, 'Profile'),
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
            if (trailing != null) trailing!,
            if (showSettings)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF06402B),
                offset: const Offset(0, 50),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () =>
                        PageNavigator.navigateToPage(context, 'Profile'),
                    child: const Row(
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Profile', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Settings', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Sign Out', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFfbbf24)),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFe3e3de).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF717973)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF06402B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF717973)),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFba1a1a)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF717973)),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
