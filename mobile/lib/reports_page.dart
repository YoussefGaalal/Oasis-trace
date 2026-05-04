import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';

class ReportsPage extends StatefulWidget {
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedNav = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final dashboard = dataProvider.dashboardData;
          final animals = dataProvider.animals;
          final devices = dataProvider.devices;
          final isLoading = dataProvider.isLoading;

          final totalAnimals =
              dashboard?['total_animals'] ?? animals.length ?? 0;
          final totalDevices =
              dashboard?['total_devices'] ?? devices.length ?? 0;

          return CustomScrollView(
            slivers: [
              UnifiedAppBar(
                title: 'Reports',
                showBackButton: true,
                onBack: () => Navigator.pop(context),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Animals',
                                '$totalAnimals',
                                Icons.pets,
                                const Color(0xFF06402B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Devices',
                                '$totalDevices',
                                Icons.memory,
                                const Color(0xFF0B5D3B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Active Alerts',
                                '${dashboard?['active_alerts'] ?? 0}',
                                Icons.warning,
                                const Color(0xFFba1a1a),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Geofences',
                                '${dashboard?['total_geofences'] ?? 0}',
                                Icons.fence,
                                const Color(0xFF735c00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Healthy',
                                '${dashboard?['healthy_count'] ?? 0}',
                                Icons.health_and_safety,
                                const Color(0xFF0B5D3B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Grazing Zones',
                                '${dashboard?['grazing_zones'] ?? 0}',
                                Icons.grass,
                                const Color(0xFF06402B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Quick Reports',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF06402B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReportItem(
                          'Health Summary',
                          'Overview of animal health status across all zones',
                          Icons.medical_services,
                          const Color(0xFF0B5D3B),
                        ),
                        _buildReportItem(
                          'Movement History',
                          'Track animal movement patterns and behaviors',
                          Icons.route,
                          const Color(0xFF06402B),
                        ),
                        _buildReportItem(
                          'Geofence Activity',
                          'Zone violations and entry/exit events',
                          Icons.fence,
                          const Color(0xFF735c00),
                        ),
                        _buildReportItem(
                          'Device Status',
                          'Battery levels and signal strength overview',
                          Icons.sensors,
                          const Color(0xFF4f6357),
                        ),
                        _buildReportItem(
                          'Temperature Analytics',
                          'Temperature trends and anomaly detection',
                          Icons.thermostat,
                          const Color(0xFFba1a1a),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Analytics',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF06402B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 48,
                                  color: Color(0xFF717973),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Activity Chart',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF717973),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: UnifiedBottomNav(
        currentIndex: _selectedNav,
        onTap: _onNavTap,
        showAuctions: true,
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF717973)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF06402B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF06402B),
                  ),
                ),
                Text(
                  subtitle,
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
        PageNavigator.navigateAndReplace(context, 'Animals');
        break;
      case 3:
        break;
      case 4:
        PageNavigator.navigateAndReplace(context, 'Profile');
        break;
    }
  }
}
