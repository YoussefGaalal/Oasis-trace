import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'navigation.dart';
import 'map_page.dart';
import 'animals_page.dart';
import 'reports_page.dart';
import 'profile_page.dart';
import 'unified_header.dart';

class AlertsPage extends StatefulWidget {
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selectedNav = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final alerts = dataProvider.alerts.isNotEmpty
              ? dataProvider.alerts
              : [];

          if (dataProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF06402B)),
            );
          }

          if (alerts.isEmpty) {
            return CustomScrollView(
              slivers: [
                const UnifiedAppBar(title: 'Alerts', showBackButton: false),
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Color(0xFF0B5D3B),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No alerts',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF717973),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              const UnifiedAppBar(title: 'Alerts', showBackButton: false),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildAlertCard(alerts[index], dataProvider),
                    childCount: alerts.length,
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

  Widget _buildAlertCard(
    Map<String, dynamic> alert,
    DataProvider dataProvider,
  ) {
    final type = alert['type'] ?? '';
    final isAcknowledged = alert['is_acknowledged'] ?? false;
    Color alertColor;
    IconData alertIcon;
    String alertTitle;

    switch (type) {
      case 'entry':
        alertColor = const Color(0xFFba1a1a);
        alertIcon = Icons.login;
        alertTitle = 'Entered Geofence';
        break;
      case 'exit':
        alertColor = const Color(0xFFba1a1a);
        alertIcon = Icons.logout;
        alertTitle = 'Left Geofence';
        break;
      case 'low_battery':
        alertColor = const Color(0xFF735c00);
        alertIcon = Icons.battery_alert;
        alertTitle = 'Low Battery';
        break;
      default:
        alertColor = const Color(0xFF4f6357);
        alertIcon = Icons.warning;
        alertTitle = 'Alert';
    }

    final animal = alert['animal'];
    final geofence = alert['geofence'];
    final animalName =
        animal?['name'] ?? animal?['animal_id'] ?? 'Unknown Animal';
    final geofenceName = geofence?['name'] ?? 'Unknown Zone';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alertColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(alertIcon, color: alertColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: alertColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        alertTitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: alertColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animalName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAcknowledged)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFba1a1a),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: const Color(0xFF717973)),
              const SizedBox(width: 8),
              Text(
                geofenceName,
                style: const TextStyle(fontSize: 13, color: Color(0xFF717973)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: const Color(0xFF717973)),
              const SizedBox(width: 8),
              Text(
                alert['triggered_at']?.toString().split('.').first ?? 'Unknown',
                style: const TextStyle(fontSize: 13, color: Color(0xFF717973)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (alert['id'] != null && !isAcknowledged)
                      dataProvider.acknowledgeAlert(alert['id']);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF06402B),
                    side: const BorderSide(color: Color(0xFF06402B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isAcknowledged ? 'Acknowledged' : 'Acknowledge'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final lat = alert['latitude'];
                    final lng = alert['longitude'];
                    if (lat != null && lng != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            initialLat: lat.toDouble(),
                            initialLng: lng.toDouble(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06402B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Location'),
                ),
              ),
            ],
          ),
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
