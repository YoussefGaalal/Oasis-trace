import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';

class UnifiedHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showSearch;
  final bool showNotifications;
  final int? notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  const UnifiedHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.showSearch = true,
    this.showNotifications = true,
    this.notificationCount,
    this.onSearchTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAF1F5), Color(0xFFfafaf5)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
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
              if (showBackButton) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    if (auth.user != null)
                      Text(
                        auth.user!['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF717973),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (showSearch)
                    _HeaderButton(
                      icon: Icons.search,
                      onTap: onSearchTap ?? () => _showSearch(context),
                    ),
                  if (showNotifications)
                    _HeaderButton(
                      icon: Icons.notifications_none,
                      badge: notificationCount,
                      onTap:
                          onNotificationTap ??
                          () => _showNotifications(context),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: (value) {
                      if (onSearchTap != null) {
                        onSearchTap!();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search animals, devices, tasks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFf4f4ef),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Links',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF717973),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: Color(0xFF06402B)),
              title: const Text('Animals'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Animals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.devices, color: Color(0xFF06402B)),
              title: const Text('Devices'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Devices');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Color(0xFFba1a1a)),
              title: const Text('Alerts'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Alerts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF06402B)),
              title: const Text('Map'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Map');
              },
            ),
            ListTile(
              leading: const Icon(Icons.vaccines, color: Color(0xFF06402B)),
              title: const Text('Vaccinations'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Vaccinations');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.medical_services,
                color: Color(0xFFba1a1a),
              ),
              title: const Text('Medical Records'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'MedicalRecords');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    PageNavigator.navigateToPage(context, 'Alerts');
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final int? badge;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 8),
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
        child: Stack(
          children: [
            Center(child: Icon(icon, color: const Color(0xFF06402B), size: 22)),
            if (badge != null && badge! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFba1a1a),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const UnifiedAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SliverAppBar(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (showBackButton)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.pop(context),
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
                  if (showBackButton) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF06402B),
                          ),
                        ),
                        if (auth.user != null)
                          Text(
                            auth.user!['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF717973),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
