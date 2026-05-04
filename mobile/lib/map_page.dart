import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'navigation.dart';

class MapPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPage({Key? key, this.initialLat, this.initialLng}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  int _selectedNav = 1;
  Map<String, dynamic>? _selectedAnimal;
  bool _showGeofences = true;
  bool _showAnimals = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadMapData();
      context.read<DataProvider>().loadGeofences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final canEdit = userRole == 'Admin' || userRole == 'Owner';

    return Scaffold(
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final animals = dataProvider.mapData.isNotEmpty
              ? dataProvider.mapData
              : <Map<String, dynamic>>[];
          final geofences = dataProvider.geofences.isNotEmpty
              ? dataProvider.geofences
              : <Map<String, dynamic>>[];

          final centerLat =
              widget.initialLat ??
              (animals.isNotEmpty && animals.first['latitude'] != null
                  ? animals.first['latitude']
                  : 24.31848);
          final centerLng =
              widget.initialLng ??
              (animals.isNotEmpty && animals.first['longitude'] != null
                  ? animals.first['longitude']
                  : 54.46191);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(centerLat, centerLng),
                  initialZoom: 14.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.oasis.tracking',
                  ),

                  if (_showGeofences && geofences.isNotEmpty)
                    PolygonLayer(
                      polygons: geofences
                          .map((g) {
                            var coordsRaw = g['coordinates'];
                            List<dynamic>? coords;

                            if (coordsRaw is String) {
                              coords = coordsRaw.isNotEmpty
                                  ? List<dynamic>.from(
                                      (coordsRaw.startsWith('[')
                                          ? _parseJsonCoords(coordsRaw)
                                          : []),
                                    )
                                  : null;
                            } else if (coordsRaw is List) {
                              coords = coordsRaw;
                            }

                            if (coords == null || coords.isEmpty) return null;

                            final points = <LatLng>[];
                            for (final c in coords) {
                              if (c is Map) {
                                final lat = (c['lat'] ?? c['latitude'] ?? 0)
                                    .toDouble();
                                final lng = (c['lng'] ?? c['longitude'] ?? 0)
                                    .toDouble();
                                if (lat != 0 || lng != 0)
                                  points.add(LatLng(lat, lng));
                              } else if (c is List) {
                                points.add(
                                  LatLng(
                                    (c[0] ?? 0).toDouble(),
                                    (c[1] ?? 0).toDouble(),
                                  ),
                                );
                              }
                            }
                            if (points.isEmpty) return null;

                            final colorStr =
                                g['color']?.replaceFirst('#', '0xFF') ??
                                '0xFF4CAF50';
                            return Polygon(
                              points: points,
                              color: Color(
                                int.parse(colorStr),
                              ).withValues(alpha: 0.2),
                              borderColor: Color(int.parse(colorStr)),
                              borderStrokeWidth: 2,
                            );
                          })
                          .whereType<Polygon>()
                          .toList(),
                    ),

                  if (_showAnimals && animals.isNotEmpty)
                    MarkerLayer(
                      markers: animals.asMap().entries.map((entry) {
                        final index = entry.key;
                        final animal = entry.value as Map<String, dynamic>;
                        final isSelected =
                            _selectedAnimal?['id'] == animal['id'];
                        final battery = animal['battery_level'] ?? 100;
                        final isLowBattery = battery < 20;
                        final status = animal['status'] ?? 'online';
                        final isOffline = status == 'offline';

                        return Marker(
                          point: LatLng(
                            (animal['latitude'] ?? centerLat).toDouble(),
                            (animal['longitude'] ?? centerLng).toDouble(),
                          ),
                          width: isOffline ? 50 : 40,
                          height: isOffline ? 50 : 40,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAnimal = animal),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isLowBattery)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0x4d735c00),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (isOffline)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0x4dba1a1a),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isOffline
                                        ? const Color(0xFFba1a1a)
                                        : isLowBattery
                                        ? const Color(0xFF735c00)
                                        : isSelected
                                        ? const Color(0xFF06402B)
                                        : const Color(
                                            0xFF06402B,
                                          ).withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFfbbf24)
                                          : isOffline
                                          ? const Color(0xFFba1a1a)
                                          : Colors.white.withOpacity(0.3),
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    color: isSelected
                                        ? const Color(0xFFfbbf24)
                                        : Colors.white.withOpacity(0.6),
                                    size: isOffline ? 24 : 18,
                                  ),
                                ),
                                if (battery < 100)
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${battery.toInt()}%',
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
                      }).toList(),
                    ),
                ],
              ),

              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002819).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06402B).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                auth.user?['name'] ?? 'The Oasis',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFfbbf24),
                                ),
                              ),
                              Text(
                                '${animals.length} Animals tracked',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildNavButton(Icons.home, 0, false),
                        const SizedBox(width: 8),
                        _buildNavButton(Icons.map, 1, true),
                        const SizedBox(width: 8),
                        _buildNavButton(Icons.pets, 2, false),
                        const SizedBox(width: 8),
                        _buildNavButton(Icons.notifications_active, 3, false),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 16,
                top: 140,
                child: Column(
                  children: [
                    _buildMapControlButton(Icons.add, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      width: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    _buildMapControlButton(Icons.remove, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildMapControlButton(Icons.my_location, () {
                      _mapController.move(LatLng(centerLat, centerLng), 14.0);
                    }),
                    const SizedBox(height: 8),
                    _buildMapControlButton(
                      _showGeofences ? Icons.fence : Icons.fence_outlined,
                      () {
                        setState(() => _showGeofences = !_showGeofences);
                      },
                      isActive: _showGeofences,
                    ),
                  ],
                ),
              ),

              if (canEdit)
                Positioned(
                  right: 16,
                  top: 140,
                  child: Column(
                    children: [
                      _buildMapControlButton(Icons.add_location, () {
                        _showAddGeofenceDialog(context);
                      }),
                    ],
                  ),
                ),

              if (_selectedAnimal != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: _buildSelectedAnimalCard(_selectedAnimal!, canEdit),
                ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: UnifiedBottomNav(
                  currentIndex: _selectedNav,
                  onTap: _onNavTap,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavButton(IconData icon, int index, bool isActive) {
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFfbbf24).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive
              ? const Color(0xFFfbbf24)
              : Colors.white.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMapControlButton(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFfbbf24)
              : const Color(0xFF002819).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive
              ? const Color(0xFF002819)
              : Colors.white.withOpacity(0.9),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSelectedAnimalCard(Map<String, dynamic> animal, bool canEdit) {
    final battery = animal['battery_level'] ?? 0;
    final status = animal['status'] ?? 'online';
    final isOffline = status == 'offline';
    final isLowBattery = battery < 20;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF002819).withOpacity(0.98),
            const Color(0xFF06402B).withOpacity(0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF06402B).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFfbbf24).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFFfbbf24),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal['name'] ?? animal['device_id'] ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFfbbf24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isOffline
                              ? Icons.error
                              : isLowBattery
                              ? Icons.battery_alert
                              : Icons.check_circle,
                          color: isOffline
                              ? const Color(0xFFba1a1a)
                              : isLowBattery
                              ? const Color(0xFF735c00)
                              : const Color(0xFF9cd2b5),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOffline
                              ? 'Offline'
                              : isLowBattery
                              ? 'Low Battery'
                              : 'Online',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOffline
                                ? const Color(0xFFba1a1a)
                                : isLowBattery
                                ? const Color(0xFF735c00)
                                : const Color(0xFF9cd2b5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedAnimal = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.battery_full,
                  'Battery',
                  '$battery%',
                  const Color(0xFFfbbf24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.location_on,
                  'GPS',
                  'Active',
                  const Color(0xFFfbbf24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (animal['animal_name'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pets, color: Color(0xFFfbbf24), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned: ${animal['animal_name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final lat = animal['latitude'] ?? 24.31848;
                final lng = animal['longitude'] ?? 54.46191;
                _mapController.move(LatLng(lat, lng), 16.0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfbbf24),
                foregroundColor: const Color(0xFF002819),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Live Tracking',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
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

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddGeofenceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#06402B');
    final alertTypeController = TextEditingController(text: 'exit');

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
                    'Add Geofence',
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
                        labelText: 'Geofence Name',
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
                        labelText: 'Alert Type (enter/exit)',
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
                        onPressed: () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name is required')),
                            );
                            return;
                          }
                          try {
                            final coordinates = jsonEncode([
                              {'lat': 21.4858, 'lng': 55.5134},
                              {'lat': 21.4958, 'lng': 55.5234},
                              {'lat': 21.4858, 'lng': 55.5334},
                              {'lat': 21.4758, 'lng': 55.5234},
                            ]);
                            await ApiService.createGeofence(
                              name: nameController.text,
                              coordinates: coordinates,
                              color: colorController.text,
                              alertType: alertTypeController.text,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Geofence created!'),
                              ),
                            );
                            if (context.mounted) {
                              context.read<DataProvider>().loadGeofences();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
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
                        child: const Text(
                          'Create Geofence',
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

  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
    switch (index) {
      case 0:
        PageNavigator.navigateAndReplace(context, 'Dashboard');
        break;
      case 2:
        PageNavigator.navigateAndReplace(context, 'Animals');
        break;
      case 3:
        PageNavigator.navigateAndReplace(context, 'Alerts');
        break;
      case 4:
        PageNavigator.navigateAndReplace(context, 'Profile');
        break;
    }
  }

  List<dynamic> _parseJsonCoords(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded;
      }
    } catch (e) {
      // Invalid JSON
    }
    return [];
  }
}
