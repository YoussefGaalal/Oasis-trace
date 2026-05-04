import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'navigation.dart';
import 'unified_header.dart';
import 'package:image_picker/image_picker.dart';

class AnimalsPage extends StatefulWidget {
  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  int _selectedNav = 2;
  String _searchQuery = '';
  String _filterSpecies = 'All';
  String _sortBy = 'name';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAnimals();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final role = user?['role']?.toString() ?? 'user';
    final canEdit =
        role == 'admin' ||
        role == 'manager' ||
        role == 'Admin' ||
        role == 'Manager' ||
        role == 'Owner';
    print('Current user role: $role, canEdit: $canEdit');
    final showBack = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Column(
        children: [
          UnifiedHeader(
            title: 'Animals',
            showBackButton: showBack,
            onBack: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                PageNavigator.navigateToPage(context, 'Dashboard');
              }
            },
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.sort, color: Color(0xFF06402B)),
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: 'animal_id',
                    child: Text('Sort by ID'),
                  ),
                  const PopupMenuItem(
                    value: 'species',
                    child: Text('Sort by Species'),
                  ),
                ],
              ),
              if (canEdit)
                GestureDetector(
                  onTap: () => _showAddAnimalModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search animals...',
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Camel'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Goat'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Sheep'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Cow'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Other'),
                        ],
                      ),
                    ),
                  ),
                ),
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    var animals = dataProvider.animals;

                    if (animals.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('No animals found')),
                      );
                    }

                    if (_searchQuery.isNotEmpty) {
                      animals = animals.where((a) {
                        final name = (a['name'] ?? '').toString().toLowerCase();
                        final id = (a['animal_id'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery.toLowerCase()) ||
                            id.contains(_searchQuery.toLowerCase());
                      }).toList();
                    }

                    if (_filterSpecies != 'All') {
                      animals = animals.where((a) {
                        return a['species'] == _filterSpecies;
                      }).toList();
                    }

                    if (_sortBy == 'name') {
                      animals.sort(
                        (a, b) => (a['name'] ?? '').toString().compareTo(
                          b['name'] ?? '',
                        ),
                      );
                    } else if (_sortBy == 'animal_id') {
                      animals.sort(
                        (a, b) => (a['animal_id'] ?? '').toString().compareTo(
                          b['animal_id'] ?? '',
                        ),
                      );
                    } else if (_sortBy == 'species') {
                      animals.sort(
                        (a, b) => (a['species'] ?? '').toString().compareTo(
                          b['species'] ?? '',
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final animal = animals[index];
                        return _buildAnimalCard(context, animal, canEdit);
                      }, childCount: animals.length),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: UnifiedBottomNav(
        currentIndex: 2,
        onTap: (index) {
          final pages = ['Dashboard', 'Map', 'Animals', 'Alerts', 'Profile'];
          PageNavigator.navigateToPage(context, pages[index]);
        },
      ),
    );
  }

  Widget _buildFilterChip(String species) {
    final isSelected = _filterSpecies == species;
    return GestureDetector(
      onTap: () => setState(() => _filterSpecies = species),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06402B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF06402B) : const Color(0xFFddd),
          ),
        ),
        child: Text(
          species,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF06402B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalCard(
    BuildContext context,
    Map<String, dynamic> animal,
    bool canEdit,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: ListTile(
        onTap: () => _showAnimalDetails(context, animal, canEdit),
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFFf4f4ef),
          backgroundImage:
              animal['identification_photo'] != null &&
                  !animal['identification_photo'].toString().startsWith('data:')
              ? NetworkImage(
                  'http://localhost:8050${animal['identification_photo']}',
                )
              : null,
          child: animal['identification_photo'] == null
              ? const Icon(Icons.pets, color: Color(0xFF06402B))
              : null,
        ),
        title: Text(
          animal['name'] ?? animal['animal_id'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'ID: ${animal['animal_id'] ?? 'N/A'}',
              style: const TextStyle(color: Color(0xFF717973), fontSize: 12),
            ),
            Text(
              '${animal['species'] ?? 'N/A'} - ${animal['breed'] ?? 'N/A'}',
              style: const TextStyle(color: Color(0xFF717973), fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22c55e).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: const TextStyle(
                  color: Color(0xFF22c55e),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFfbbf24)),
                onPressed: () => _showEditAnimalModal(context, animal),
              ),
          ],
        ),
      ),
    );
  }

  void _showAnimalDetails(
    BuildContext context,
    Map<String, dynamic> animal,
    bool canEdit,
  ) {
    final ctx = context;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    animal['name'] ?? animal['animal_id'] ?? 'Unknown',
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
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFf4f4ef),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          animal['identification_photo'] != null &&
                              !animal['identification_photo']
                                  .toString()
                                  .startsWith('data:')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                'http://localhost:8050${animal['identification_photo']}',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.pets,
                                  size: 40,
                                  color: Color(0xFF06402B),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.pets,
                              size: 40,
                              color: Color(0xFF06402B),
                            ),
                    ),
                    const SizedBox(height: 24),
                    _detailRow('Animal ID', animal['animal_id'] ?? 'N/A'),
                    _detailRow('Species', animal['species'] ?? 'N/A'),
                    _detailRow('Breed', animal['breed'] ?? 'N/A'),
                    _detailRow('Gender', animal['gender'] ?? 'N/A'),
                    _detailRow(
                      'Color/Markings',
                      animal['color_markings'] ?? 'N/A',
                    ),
                    _detailRow(
                      'Date of Birth',
                      animal['date_of_birth'] ?? 'N/A',
                    ),
                    _detailRow('Weight', '${animal['weight'] ?? 0} kg'),
                    _detailRow('Status', animal['status'] ?? 'N/A'),
                    _detailRow('Location', animal['location'] ?? 'N/A'),
                    _detailRow(
                      'Normal Heart Rate',
                      '${animal['normal_heart_rate'] ?? 0} BPM',
                    ),
                    _detailRow('Device ID', animal['device_id'] ?? 'N/A'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              PageNavigator.navigateToPage(ctx, 'Map');
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('View Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06402B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (canEdit) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFfbbf24),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showEditAnimalModal(ctx, animal);
                            },
                          ),
                        ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF717973))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAddAnimalModal(BuildContext context) async {
    final ctx = context;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final tagIdController = TextEditingController();
    final colorController = TextEditingController();
    String selectedSpecies = 'Camel';

    final speciesOptions = ['Camel', 'Goat', 'Sheep', 'Cow', 'Other'];
    final breedOptions = [
      'Majaheem',
      'Wadhah',
      'Suhail',
      'Boer',
      'Awassi',
      'Other',
    ];
    final genderOptions = ['Male', 'Female'];
    String selectedBreed = 'Majaheem';
    String selectedGender = 'Male';
    String selectedDevice = '';
    List<dynamic> deviceOptions = [];
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;
    try {
      deviceOptions = await ApiService.getDevices();
    } catch (e) {
      print('Error: $e');
    }
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Animal',
                      style: TextStyle(
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedDevice.isEmpty ? null : selectedDevice,
                          decoration: InputDecoration(
                            labelText: 'Device (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: deviceOptions.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                    value: '',
                                    child: Text('No devices'),
                                  ),
                                ]
                              : deviceOptions
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d['device_id']?.toString(),
                                        child: Text(
                                          d['device_id']?.toString() ?? '',
                                        ),
                                      ),
                                    )
                                    .toList(),
                          onChanged: (v) =>
                              setModalState(() => selectedDevice = v ?? ''),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: genderOptions
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedGender = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: colorController,
                          decoration: InputDecoration(
                            labelText: 'Color/Markings',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf4f4ef),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF06402B)),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    pickedImage!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      size: 40,
                                      color: Color(0xFF06402B),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: Color(0xFF06402B),
                                  ),
                                ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 80,
                            );
                            if (img != null) {
                              setModalState(() => pickedImage = img);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF06402B),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: const Color(0xFF06402B),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pickedImage != null
                                      ? 'Image Selected'
                                      : 'Add Photo',
                                  style: const TextStyle(
                                    color: Color(0xFF06402B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  final dataProvider = context
                                      .read<DataProvider>();

                                  final animalData = {
                                    'name': nameController.text,
                                    'animal_id': tagIdController.text.isNotEmpty
                                        ? tagIdController.text
                                        : 'OA-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch}',
                                    'species': selectedSpecies,
                                    'breed': selectedBreed,
                                    'gender': selectedGender,
                                    'color_markings':
                                        colorController.text.isNotEmpty
                                        ? colorController.text
                                        : '',
                                    'status': 'active',
                                  };

                                  if (selectedDevice.isNotEmpty) {
                                    animalData['device_id'] = selectedDevice;
                                  }
                                  if (pickedImage != null) {
                                    final bytes = await pickedImage!
                                        .readAsBytes();
                                    animalData['identification_photo'] =
                                        'data:image/png;base64,${base64Encode(bytes)}';
                                  }

                                  print('Creating animal: $animalData');

                                  await dataProvider.createAnimal(animalData);

                                  Navigator.pop(ctx);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Animal added successfully!',
                                      ),
                                      backgroundColor: Color(0xFF0B5D3B),
                                    ),
                                  );
                                } catch (e) {
                                  print('Error: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: const Color(0xFFba1a1a),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06402B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Add Animal'),
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
      ),
    );
  }

  void _showEditAnimalModal(
    BuildContext context,
    Map<String, dynamic> animal,
  ) async {
    final ctx = context;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: animal['name'] ?? animal['animal_id'] ?? '',
    );
    final tagIdController = TextEditingController(
      text: animal['animal_id'] ?? '',
    );
    final colorController = TextEditingController(
      text: animal['color_markings'] ?? '',
    );

    String selectedSpecies = animal['species']?.toString() ?? 'Camel';
    String selectedBreed = animal['breed']?.toString() ?? 'Majaheem';
    String selectedGender = animal['gender']?.toString() ?? 'Male';

    final speciesOptions = ['Camel', 'Goat', 'Sheep', 'Cow', 'Other'];
    final breedOptions = [
      'Majaheem',
      'Wadhah',
      'Suhail',
      'Boer',
      'Awassi',
      'Other',
    ];
    final genderOptions = ['Male', 'Female'];

    if (!breedOptions.contains(selectedBreed)) selectedBreed = 'Other';
    if (!speciesOptions.contains(selectedSpecies)) selectedSpecies = 'Camel';
    if (!genderOptions.contains(selectedGender)) selectedGender = 'Male';

    String selectedDevice = animal['device_id']?.toString() ?? '';
    List<dynamic> deviceOptions = [];
    try {
      deviceOptions = await ApiService.getDevices();
    } catch (e) {
      print('Error: $e');
    }
    deviceOptions.add({'device_id': null, 'name': 'No Device'});
    final currentDeviceId = animal['device_id']?.toString();
    if (currentDeviceId != null && currentDeviceId.isNotEmpty) {
      final exists = deviceOptions.any(
        (d) => d['device_id']?.toString() == currentDeviceId,
      );
      if (!exists) {
        deviceOptions.insert(0, {
          'device_id': currentDeviceId,
          'name': currentDeviceId,
        });
      }
    }

    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Animal',
                      style: TextStyle(
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedDevice.isEmpty ? null : selectedDevice,
                          decoration: InputDecoration(
                            labelText: 'Device',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: deviceOptions
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d['device_id']?.toString(),
                                  child: Text(
                                    d['device_id']?.toString() ?? 'No Device',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => selectedDevice = v ?? ''),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField(
                          value: selectedSpecies,
                          decoration: InputDecoration(
                            labelText: 'Species',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: speciesOptions
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) {},
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedBreed,
                          decoration: InputDecoration(
                            labelText: 'Breed',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: breedOptions
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedBreed = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: genderOptions
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (v) {},
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: colorController,
                          decoration: InputDecoration(
                            labelText: 'Color/Markings',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf4f4ef),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF06402B)),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    pickedImage!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      size: 40,
                                      color: Color(0xFF06402B),
                                    ),
                                  ),
                                )
                              : animal['identification_photo'] != null &&
                                    animal['identification_photo']
                                        .toString()
                                        .isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'http://localhost:8050${animal['identification_photo']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      size: 40,
                                      color: Color(0xFF06402B),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: Color(0xFF06402B),
                                  ),
                                ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 80,
                            );
                            if (img != null) {
                              setModalState(() => pickedImage = img);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF06402B),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: const Color(0xFF06402B),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pickedImage != null
                                      ? 'Image Selected'
                                      : 'Add Photo',
                                  style: const TextStyle(
                                    color: Color(0xFF06402B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final dataProvider = context
                                    .read<DataProvider>();
                                final Map<String, dynamic> updateData = {
                                  'name': nameController.text,
                                  'species': selectedSpecies,
                                  'breed': selectedBreed,
                                  'gender': selectedGender,
                                  'color_markings':
                                      colorController.text.isNotEmpty
                                      ? colorController.text
                                      : '',
                                };
                                print('Sending update: $updateData');
                                if (selectedDevice.isNotEmpty) {
                                  updateData['device_id'] = selectedDevice;
                                }
                                if (pickedImage != null) {
                                  final bytes = await pickedImage!
                                      .readAsBytes();
                                  updateData['identification_photo'] =
                                      'data:image/png;base64,${base64Encode(bytes)}';
                                }
                                await dataProvider.updateAnimal(
                                  animal['id'],
                                  updateData,
                                );

                                Navigator.pop(ctx);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Animal updated!'),
                                    backgroundColor: Color(0xFF0B5D3B),
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
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              _showDeleteConfirmation(context, animal);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFba1a1a),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Delete Animal'),
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
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> animal,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text(
          'Are you sure you want to delete ${animal['name'] ?? animal['animal_id'] ?? 'this animal'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final dataProvider = context.read<DataProvider>();
              await dataProvider.deleteAnimal(animal['id']);

              Navigator.pop(ctx);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Animal deleted!'),
                  backgroundColor: Color(0xFF0B5D3B),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
