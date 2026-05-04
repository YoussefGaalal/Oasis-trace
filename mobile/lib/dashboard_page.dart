import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'data_provider.dart';
import 'navigation.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = context.read<DataProvider>();
      data.loadDashboard();
      data.loadAnimals();
      data.loadAlerts();
      data.loadDevices();
      data.loadGeofences();
    });
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF06402B),
              ),
            ),
            const SizedBox(height: 24),
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
            ListTile(
              leading: const Icon(Icons.task_alt, color: Color(0xFF735c00)),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Tasks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF0B5D3B)),
              title: const Text('Team'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Team');
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel, color: Color(0xFF4f6357)),
              title: const Text('Auctions'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Auctions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF717973)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                PageNavigator.navigateToPage(context, 'Settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: const Color(0xFF06402B),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      body: Consumer2<AuthProvider, DataProvider>(
        builder: (context, auth, data, _) {
          final dashboard = data.dashboardData;
          final isLoading = data.isLoading;
          final animals = data.animals.isNotEmpty
              ? data.animals
              : (dashboard?['recent_animals'] as List? ?? []);
          final alerts = dashboard?['recent_alerts'] as List? ?? [];

          int totalAnimals = (dashboard?['total_animals'] as int?) ?? data.animals.length;
          int activeAlerts = (dashboard?['active_alerts'] as int?) ?? data.alerts.length;
          int totalDevices = (dashboard?['total_devices'] as int?) ?? data.devices.length;
          int totalGeofences = (dashboard?['total_geofences'] as int?) ?? (data.geofences.length);
          int pendingTasks = (data.tasks as List?)?.where((t) => t['status'] == 'pending').length ?? 0;

          return CustomScrollView(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06402B),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: Color(0xFFfbbf24),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auth.user?['name'] ?? 'Welcome',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF06402B),
                                      ),
                                    ),
                                    Text(
                                      auth.user?['role'] ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF717973),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF06402B),
                                  ),
                                  onPressed: () => _showSearch(context),
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none,
                                        color: Color(0xFF06402B),
                                      ),
                                      onPressed: () =>
                                          PageNavigator.navigateToPage(
                                            context,
                                            'Alerts',
                                          ),
                                    ),
                                    if (activeAlerts > 0)
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
                                            '$activeAlerts',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  ),
                )
              else ...[
                // Quick Actions
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickAction(
                            Icons.add,
                            'Add Animal',
                            () => PageNavigator.navigateToPage(
                              context,
                              'Animals',
                            ),
                          ),
                          _buildQuickAction(
                            Icons.map,
                            'View Map',
                            () => PageNavigator.navigateToPage(context, 'Map'),
                          ),
                          _buildQuickAction(
                            Icons.pets,
                            'Animals',
                            () => PageNavigator.navigateToPage(
                              context,
                              'Animals',
                            ),
                          ),
                          _buildQuickAction(
                            Icons.fence,
                            'Geofences',
                            () => PageNavigator.navigateToPage(
                              context,
                              'Geofences',
                            ),
                          ),
                          _buildQuickAction(
                            Icons.devices,
                            'Devices',
                            () => PageNavigator.navigateToPage(
                              context,
                              'Devices',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Total Animals Card
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildStatCard(
                      title: 'TOTAL ANIMALS',
                      value: '$totalAnimals',
                      icon: Icons.pets,
                      color: const Color(0xFFfbbf24),
                      onTap: () =>
                          PageNavigator.navigateToPage(context, 'Animals'),
                    ),
                  ),
                ),
                // Stats Row
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSmallStatCard(
                            icon: Icons.notifications,
                            title: 'Alerts',
                            value: '$activeAlerts',
                            color: const Color(0xFFba1a1a),
                            bgColor: const Color(0xFFffdad6),
                            onTap: () =>
                                PageNavigator.navigateToPage(context, 'Alerts'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallStatCard(
                            icon: Icons.devices,
                            title: 'Devices',
                            value: '$totalDevices',
                            color: const Color(0xFF06402B),
                            bgColor: const Color(0xFFe8f5e9),
                            onTap: () => PageNavigator.navigateToPage(
                              context,
                              'Devices',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Geofences Row
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSmallStatCard(
                            icon: Icons.fence,
                            title: 'Geofences',
                            value: '$totalGeofences',
                            color: const Color(0xFF1976D2),
                            bgColor: const Color(0xFFe3f2fd),
                            onTap: () => PageNavigator.navigateToPage(
                              context,
                              'Geofences',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallStatCard(
                            icon: Icons.task_alt,
                            title: 'Tasks',
                            value: '$pendingTasks',
                            color: const Color(0xFF735c00),
                            bgColor: const Color(0xFFfff8e1),
                            onTap: () =>
                                PageNavigator.navigateToPage(context, 'Tasks'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Recent Alerts
                if (alerts.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF06402B),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                PageNavigator.navigateToPage(context, 'Alerts'),
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Color(0xFFfbbf24)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= alerts.length) return null;
                        final alert = alerts[index];
                        return _buildAlertCard(alert);
                      }, childCount: alerts.length > 3 ? 3 : alerts.length),
                    ),
                  ),
                ],
                // Recent Animals
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Animals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF06402B),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              PageNavigator.navigateToPage(context, 'Animals'),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Color(0xFFfbbf24)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= animals.length) return null;
                      final animal = animals[index];
                      return GestureDetector(
                        onTap: () => _showAnimalDetails(context, animal),
                        child: _buildAnimalCard(animal),
                      );
                    }, childCount: animals.length > 5 ? 5 : animals.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: UnifiedBottomNav(
        currentIndex: _selectedNav,
        onTap: (index) {
          setState(() => _selectedNav = index);
          PageNavigator.navigateAndReplace(
            context,
            bottomNavItems[index].replaceAll('Home', 'Dashboard'),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF06402B), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF06402B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06402b), Color(0xFF002819)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9cd2b5),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF06402b).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFffdad6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFba1a1a).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber,
              color: Color(0xFFba1a1a),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['message'] ?? 'Alert',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFba1a1a),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert['animal'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF717973),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            alert['time'] ?? '',
            style: const TextStyle(color: Color(0xFF717973), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    final name = animal['name'] ?? animal['animal_id'] ?? 'Unknown';
    final species = animal['species'] ?? '';
    final breed = animal['breed'] ?? '';
    final hasDevice = animal['device_id'] != null;

    return GestureDetector(
      onTap: () => _showAnimalDetails(context, animal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFf4f4ef),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFe8e8e3),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  animal['identification_photo'] != null &&
                      (animal['identification_photo'] as String).isNotEmpty &&
                      (animal['identification_photo'] as String).startsWith(
                        'http',
                      )
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        animal['identification_photo'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.pets, color: Color(0xFF717973)),
                      ),
                    )
                  : const Icon(Icons.pets, color: Color(0xFF717973)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06402B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasDevice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFcfe5d6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B5D3B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Tracked',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B5D3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    species.isNotEmpty
                        ? '$species ${breed.isNotEmpty ? "- $breed" : ""}'
                        : 'No species',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF717973)),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search animals, devices, alerts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFf4f4ef),
                ),
                onChanged: (value) {},
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Start typing to search',
                  style: TextStyle(color: Color(0xFF717973)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnimalDetails(BuildContext context, Map<String, dynamic> animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    animal['animal_id'] ?? animal['name'] ?? 'Animal Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf4f4ef),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child:
                            animal['identification_photo'] != null &&
                                (animal['identification_photo'] as String)
                                    .isNotEmpty &&
                                (animal['identification_photo'] as String)
                                    .startsWith('http')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  animal['identification_photo'],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.pets,
                                size: 50,
                                color: Color(0xFF717973),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Name', animal['name'] ?? 'Unknown'),
                    _buildDetailRow('ID', animal['animal_id'] ?? 'N/A'),
                    _buildDetailRow('Species', animal['species'] ?? 'N/A'),
                    _buildDetailRow('Status', animal['status'] ?? 'Unknown'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              PageNavigator.navigateToPage(context, 'Map');
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06402B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF717973))),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF06402B),
            ),
          ),
        ],
      ),
    );
  }
}
