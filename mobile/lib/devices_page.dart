import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';
import 'api_service.dart';

class DevicesPage extends StatefulWidget {
  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final canEdit = userRole == 'Admin' || userRole == 'Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDeviceModal(context),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Device',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final devices = dataProvider.devices.isNotEmpty
              ? dataProvider.devices
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;

          final filteredDevices = devices.where((device) {
            final matchesSearch =
                _searchQuery.isEmpty ||
                (device['device_id'] ?? '').toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (device['name'] ?? '').toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
            final matchesStatus =
                _filterStatus == 'All' ||
                (_filterStatus == 'Online' &&
                    (device['status'] == 'online' ||
                        device['status'] == 'online')) ||
                (_filterStatus == 'Offline' &&
                    (device['status'] == 'offline' ||
                        device['status'] == 'offline')) ||
                (_filterStatus == 'Low Battery' &&
                    (device['battery_level'] ?? 100) < 20);
            return matchesSearch && matchesStatus;
          }).toList();

          final activeCount = devices
              .where((d) => d['status'] == 'online')
              .length;
          final lowBatteryCount = devices
              .where((d) => (d['battery_level'] ?? 100) < 20)
              .length;
          final offlineCount = devices
              .where((d) => d['status'] == 'offline')
              .length;

          return CustomScrollView(
            slivers: [
              UnifiedAppBar(
                title: 'Devices',
                showBackButton: true,
                onBack: () => Navigator.pop(context),
              ),
              // Search
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
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
                  ),
                ),
              ),
              // Status Filter
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Online', 'Offline', 'Low Battery'].map(
                        (s) {
                          return GestureDetector(
                            onTap: () => setState(() => _filterStatus = s),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _filterStatus == s
                                    ? const Color(0xFF06402B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF06402B),
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: _filterStatus == s
                                      ? Colors.white
                                      : const Color(0xFF06402B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Active',
                        '$activeCount',
                        const Color(0xFF0B5D3B),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Low Battery',
                        '$lowBatteryCount',
                        const Color(0xFF735c00),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Offline',
                        '$offlineCount',
                        const Color(0xFFba1a1a),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Device List
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  ),
                )
              else if (filteredDevices.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No devices found',
                      style: TextStyle(color: Color(0xFF717973)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildDeviceCard(filteredDevices[index], canEdit),
                      childCount: filteredDevices.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
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

  Widget _buildDeviceCard(Map<String, dynamic> device, bool canEdit) {
    final status = device['status'] ?? 'offline';
    final battery = device['battery_level'] ?? 0;
    final isOnline = status == 'online';
    final isLowBattery = battery < 20;

    Color statusColor;
    IconData statusIcon;
    if (isOnline && !isLowBattery) {
      statusColor = const Color(0xFF0B5D3B);
      statusIcon = Icons.check_circle;
    } else if (isLowBattery) {
      statusColor = const Color(0xFF735c00);
      statusIcon = Icons.battery_alert;
    } else {
      statusColor = const Color(0xFFba1a1a);
      statusIcon = Icons.error;
    }

    return GestureDetector(
      onTap: () => _showDeviceDetails(context, device, canEdit),
      child: Container(
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device['device_id'] ?? 'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF06402B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device['name'] ?? device['type'] ?? 'No name',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF717973),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 12,
                        color: const Color(0xFF717973),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device['animal_id'] ?? 'Unassigned',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      battery > 20 ? Icons.battery_full : Icons.battery_alert,
                      size: 16,
                      color: battery > 20
                          ? const Color(0xFF0B5D3B)
                          : const Color(0xFFba1a1a),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$battery%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: battery > 20
                            ? const Color(0xFF0B5D3B)
                            : const Color(0xFFba1a1a),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (device['gps_lat'] != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Color(0xFF06402B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'GPS',
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF06402B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetails(
    BuildContext context,
    Map<String, dynamic> device,
    bool canEdit,
  ) {
    final battery = device['battery_level'] ?? 0;
    final status = device['status'] ?? 'offline';

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device['device_id'] ?? 'Device Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06402B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.memory,
                        size: 40,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _detailRow('Device ID', device['device_id'] ?? 'N/A'),
                    _detailRow('Name', device['name'] ?? 'N/A'),
                    _detailRow('Type', device['type'] ?? 'N/A'),
                    _detailRow(
                      'Serial Number',
                      device['serial_number'] ?? 'N/A',
                    ),
                    _detailRow('Firmware', device['firmware_version'] ?? 'N/A'),
                    _detailRow('Status', status.toString().toUpperCase()),
                    _detailRow('Battery', '$battery%'),
                    _detailRow(
                      'Update Interval',
                      '${device['update_interval'] ?? 15} min',
                    ),
                    _detailRow(
                      'Assigned Animal',
                      device['animal_id'] ?? 'None',
                    ),
                    _detailRow(
                      'GPS Latitude',
                      device['gps_lat']?.toString() ?? 'N/A',
                    ),
                    _detailRow(
                      'GPS Longitude',
                      device['gps_lng']?.toString() ?? 'N/A',
                    ),
                    _detailRow(
                      'Last Ping',
                      device['last_ping']?.toString().split('.').first ?? 'N/A',
                    ),
                    const SizedBox(height: 24),
                    if (canEdit)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditDeviceModal(context, device);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFfbbf24),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () =>
                                _confirmDeleteDevice(context, device),
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFba1a1a),
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

  Widget _detailRow(String label, String value) {
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

  void _showAddDeviceModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final deviceIdController = TextEditingController();
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final serialController = TextEditingController();
    final firmwareController = TextEditingController(text: 'v2.4');
    final intervalController = TextEditingController(text: '15');
    final latController = TextEditingController(text: '24.31848');
    final lngController = TextEditingController(text: '54.46191');
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;
    String selectedAnimalId = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.9,
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
                    'Add Device',
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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: deviceIdController,
                        decoration: _inputDecoration(
                          'Device ID (e.g., IOT-001)',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration('Device Name'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: typeController,
                        decoration: _inputDecoration(
                          'Type (GPS Collar, Tag, etc.)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: serialController,
                        decoration: _inputDecoration('Serial Number'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: firmwareController,
                        decoration: _inputDecoration('Firmware Version'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: intervalController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Update Interval (minutes)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: latController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('GPS Latitude'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lngController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('GPS Longitude'),
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return FutureBuilder<List<dynamic>>(
                            future: ApiService.getAnimals(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final animals = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                value: selectedAnimalId.isEmpty
                                    ? null
                                    : selectedAnimalId,
                                decoration: _inputDecoration(
                                  'Select Animal (Optional)',
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('None'),
                                  ),
                                  ...animals.map(
                                    (a) => DropdownMenuItem(
                                      value: a['id'].toString(),
                                      child: Text(a['name'].toString()),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => selectedAnimalId = v ?? ''),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pickedImage != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(pickedImage!.path),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final img = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (img != null) {
                                    setState(() => pickedImage = img);
                                  }
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Add Photo'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final dataProvider = context.read<DataProvider>();
                              final deviceData = {
                                'device_id': deviceIdController.text,
                                'name': nameController.text,
                                'type': typeController.text,
                                'serial_number': serialController.text,
                                'firmware_version': firmwareController.text,
                                'update_interval':
                                    int.tryParse(intervalController.text) ?? 15,
                                'gps_lat': double.tryParse(latController.text),
                                'gps_lng': double.tryParse(lngController.text),
                                'status': 'online',
                              };
                              if (selectedAnimalId.isNotEmpty) {
                                deviceData['animal_id'] = selectedAnimalId;
                              }
                              if (pickedImage != null) {
                                final bytes = await pickedImage!.readAsBytes();
                                deviceData['image'] = base64Encode(bytes);
                              }
                              await dataProvider.createDevice(deviceData);
                              await dataProvider.loadDevices();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Device added successfully!'),
                                  ),
                                );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002819),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Device',
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
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeviceModal(BuildContext context, Map<String, dynamic> device) {
    final formKey = GlobalKey<FormState>();
    final deviceIdController = TextEditingController(
      text: device['device_id'] ?? '',
    );
    final nameController = TextEditingController(text: device['name'] ?? '');
    final typeController = TextEditingController(text: device['type'] ?? '');
    final serialController = TextEditingController(
      text: device['serial_number'] ?? '',
    );
    final firmwareController = TextEditingController(
      text: device['firmware_version'] ?? '',
    );
    final intervalController = TextEditingController(
      text: device['update_interval']?.toString() ?? '15',
    );
    final latController = TextEditingController(
      text: device['gps_lat']?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: device['gps_lng']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.9,
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
                    'Edit Device',
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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: deviceIdController,
                        decoration: _inputDecoration('Device ID'),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration('Device Name'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: typeController,
                        decoration: _inputDecoration('Type'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: serialController,
                        decoration: _inputDecoration('Serial Number'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: firmwareController,
                        decoration: _inputDecoration('Firmware Version'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: intervalController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Update Interval (minutes)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: latController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('GPS Latitude'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lngController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('GPS Longitude'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final dataProvider = context.read<DataProvider>();
                              await dataProvider.updateDevice(device['id'], {
                                'device_id': deviceIdController.text,
                                'name': nameController.text,
                                'type': typeController.text,
                                'serial_number': serialController.text,
                                'firmware_version': firmwareController.text,
                                'update_interval':
                                    int.tryParse(intervalController.text) ?? 15,
                                'gps_lat': double.tryParse(latController.text),
                                'gps_lng': double.tryParse(lngController.text),
                              });
                              await dataProvider.loadDevices();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Device updated successfully!',
                                    ),
                                  ),
                                );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002819),
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
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDevice(BuildContext context, Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text(
          'Are you sure you want to delete ${device['device_id']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final dataProvider = context.read<DataProvider>();
              await dataProvider.deleteDevice(device['id']);
              await dataProvider.loadDevices();
              if (context.mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device deleted!')),
                );
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFf4f4ef),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
