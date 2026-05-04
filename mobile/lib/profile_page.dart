import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'navigation.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'map_page.dart';
import 'alerts_page.dart';
import 'reports_page.dart';
import 'animals_page.dart' hide Text, ElevatedButton;
import 'team_page.dart';
import 'devices_page.dart';
import 'geofences_page.dart';
import 'tasks_page.dart';
import 'auction_page.dart';
import 'unified_header.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNav = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user =
              auth.user ??
              {
                'name': 'Abdullah',
                'email': 'demo@oasis.com',
                'role': 'Owner',
                'phone': '+201066746002',
              };

          return CustomScrollView(
            slivers: [
              const UnifiedAppBar(title: 'Profile', showBackButton: false),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        Icons.person_outline,
                        'Personal Information',
                        () => _showPersonalInfoDialog(context, auth),
                      ),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.task_alt,
                        'Tasks',
                        () => PageNavigator.navigateToPage(context, 'Tasks'),
                      ),
                      _buildMenuItem(
                        Icons.lock_outline,
                        'Privacy & Security',
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.settings,
                        'Settings',
                        () => PageNavigator.navigateToPage(context, 'Settings'),
                      ),
                      _buildMenuItem(
                        Icons.vaccines,
                        'Vaccinations',
                        () => PageNavigator.navigateToPage(
                          context,
                          'Vaccinations',
                        ),
                      ),
                      _buildMenuItem(
                        Icons.medical_services,
                        'Medical Records',
                        () => PageNavigator.navigateToPage(
                          context,
                          'MedicalRecords',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Farm Management',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        Icons.groups_outlined,
                        'Team Members',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TeamPage()),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.pets_outlined,
                        'Animals',
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AnimalsPage()),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.fence_outlined,
                        'Geofences',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GeofencesPage()),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.devices_outlined,
                        'Devices',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DevicesPage()),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.task_alt,
                        'Tasks',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TasksPage()),
                        ),
                      ),
                      _buildMenuItem(
                        Icons.gavel,
                        'Auctions',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AuctionPage()),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Subscription',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFfbbf24).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFFfbbf24),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Premium Plan',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF06402B),
                                    ),
                                  ),
                                  Text(
                                    'Up to 500 animals',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF717973),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B5D3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Support',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(Icons.help_outline, 'Help Center', () {}),
                      _buildMenuItem(Icons.info_outline, 'About', () {}),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            auth.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFba1a1a),
                            side: const BorderSide(color: Color(0xFFba1a1a)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      bottomNavigationBar: UnifiedBottomNav(
        currentIndex: _selectedNav,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF06402B)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF06402B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF717973)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
    switch (index) {
      case 0:
        PageNavigator.navigateAndReplace(context, 'Dashboard');
        break;
      case 1:
        PageNavigator.navigateAndReplace(context, 'Map');
        break;
      case 2:
        PageNavigator.navigateAndReplace(context, 'Alerts');
        break;
      case 3:
        PageNavigator.navigateAndReplace(context, 'Auctions');
        break;
      case 4:
        break;
    }
  }

  void _showPersonalInfoDialog(BuildContext context, AuthProvider auth) {
    final user = auth.user;
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final locationController = TextEditingController(
      text: user?['location'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF06402B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF06402B),
                  child: Text(
                    (nameController.text.isNotEmpty
                            ? nameController.text[0]
                            : 'U')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameController.text.isNotEmpty
                          ? nameController.text
                          : 'User',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    Text(
                      user?['role'] ?? 'Member',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: const Color(0xFFf4f4ef),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: const Color(0xFFf4f4ef),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                filled: true,
                fillColor: const Color(0xFFf4f4ef),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                filled: true,
                fillColor: const Color(0xFFf4f4ef),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final userId = user?['id'];
                    if (userId != null) {
                      await ApiService.updateUser(userId, {
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'location': locationController.text,
                      });

                      auth.user?['name'] = nameController.text;
                      auth.user?['phone'] = phoneController.text;
                      auth.notifyListeners();
                    }

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated!'),
                          backgroundColor: Color(0xFF0B5D3B),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Color(0xFFba1a1a),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
