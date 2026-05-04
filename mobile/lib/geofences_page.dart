import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';

class GeofencesPage extends StatefulWidget {
  @override
  State<GeofencesPage> createState() => _GeofencesPageState();
}

class _GeofencesPageState extends State<GeofencesPage> {
  int _selectedNav = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadGeofences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final canEdit = userRole == 'Admin' || userRole == 'Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final geofences = dataProvider.geofences.isNotEmpty
              ? dataProvider.geofences
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;

          return CustomScrollView(
            slivers: [
              UnifiedAppBar(
                title: 'Geofences',
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
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Total Zones',
                          '${geofences.length}',
                          const Color(0xFF06402B),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Active',
                          '${geofences.where((g) => g['is_active'] == true).length}',
                          const Color(0xFF0B5D3B),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Alerts',
                          'Entry/Exit',
                          const Color(0xFF735c00),
                        ),
                      ],
                    ),
                  ),
                ),
                if (geofences.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fence, size: 64, color: Color(0xFF717973)),
                          SizedBox(height: 16),
                          Text(
                            'No geofences',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF717973),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create a geofence to start tracking',
                            style: TextStyle(color: Color(0xFF717973)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildGeofenceCard(geofences[index], canEdit),
                        childCount: geofences.length,
                      ),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateGeofenceDialog(context),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Zone',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
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
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF717973)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceCard(Map<String, dynamic> geofence, bool canEdit) {
    final colorStr = geofence['color'] ?? '#06402B';
    final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    final alertType = geofence['alert_type'] ?? 'both';
    final isActive = geofence['is_active'] ?? true;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fence, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      geofence['name'] ?? 'Geofence',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0B5D3B).withOpacity(0.1)
                                : const Color(0xFF735c00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFF0B5D3B)
                                  : const Color(0xFF735c00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alert: $alertType',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF717973),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (canEdit)
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF717973)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showEditGeofenceDialog(context, geofence),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _confirmDeleteGeofence(context, geofence),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: Color(0xFFba1a1a),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Color(0xFFba1a1a)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF717973)),
              const SizedBox(width: 4),
              Text(
                geofence['coordinates'] != null
                    ? 'Polygon defined'
                    : 'No coordinates',
                style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateGeofenceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#06402B');
    final alertTypeController = TextEditingController(text: 'both');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.6,
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
                  const Text(
                    'Create Geofence',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                      controller: colorController,
                      decoration: InputDecoration(
                        labelText: 'Color (hex)',
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
                      controller: alertTypeController,
                      decoration: InputDecoration(
                        labelText: 'Alert Type (entry/exit/both)',
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
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Use map to draw polygon'),
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06402B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Draw on Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  void _showEditGeofenceDialog(
    BuildContext context,
    Map<String, dynamic> geofence,
  ) {
    final nameController = TextEditingController(text: geofence['name'] ?? '');
    final colorController = TextEditingController(
      text: geofence['color'] ?? '#06402B',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.5,
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
                  const Text(
                    'Edit Geofence',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                      controller: colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
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
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Geofence updated')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06402B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  void _confirmDeleteGeofence(
    BuildContext context,
    Map<String, dynamic> geofence,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text('Delete ${geofence['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Geofence deleted')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFba1a1a),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
