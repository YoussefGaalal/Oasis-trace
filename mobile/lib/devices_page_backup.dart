import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'navigation.dart';
import 'unified_header.dart';
import 'dashboard_page.dart';
import 'map_page.dart';
import 'animals_page.dart';
import 'alerts_page.dart';

class DevicesPage extends StatefulWidget {
  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  int _selectedNav = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadDevices();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?['role']?.toString() ?? '';
    final canEdit = role == 'Admin' || role == 'Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final devices = dataProvider.devices;
          final isLoading = dataProvider.isLoading;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              UnifiedAppBar(
                title: 'Devices',
                showBackButton: true,
                onBack: () => Navigator.pop(context),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search devices...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Online', 'online'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Offline', 'offline'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Low Battery', 'low_signal'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (devices.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.device_unknown, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matching devices' : 'No devices found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final filteredDevices = _getFilteredDevices(devices);
                        if (index >= filteredDevices.length) return null;
                        final device = filteredDevices[index];
                        return _buildDeviceCard(device, canEdit);
                      },
                      childCount: _getFilteredDevices(devices).length,
                    ),
                  ),
                ),
            ],
          );
        },
),
        floatingActionButton: canEdit
            ? FloatingActionButton.extended(
                onPressed: () => _showAddDeviceModal(context),
                backgroundColor: const Color(0xFF06402B),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Device', style: TextStyle(color: Colors.white)),
              )
            : null,
        bottomNavigationBar: UnifiedBottomNav(
          currentIndex: _selectedNav,
          onTap: _onNavTap,
        ),
      );
  }

  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
  }

  List<dynamic> _getFilteredDevices(List<dynamic> devices) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Delete ${device['name']}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteDevice(device['id']);
                if (ctx.mounted) {
                  context.read<DataProvider>().loadDevices();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device deleted')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}