import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';

class VaccinationPage extends StatefulWidget {
  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadVaccinations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          final vaccinations = dataProvider.vaccinations.isNotEmpty
              ? dataProvider.vaccinations.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;
          final scheduledVaccinations = vaccinations
              .where((v) => v['status'] == 'scheduled')
              .toList();
          final administeredVaccinations = vaccinations
              .where((v) => v['status'] == 'administered')
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
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
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vaccinations',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF06402B),
                                  ),
                                ),
                                Text(
                                  '${vaccinations.length} records',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF717973),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF06402B),
                  unselectedLabelColor: const Color(0xFF717973),
                  indicatorColor: const Color(0xFF06402B),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Scheduled'),
                    Tab(text: 'Done'),
                  ],
                ),
              ),
            ],
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVaccinationList(vaccinations),
                      _buildVaccinationList(scheduledVaccinations),
                      _buildVaccinationList(administeredVaccinations),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showAddVaccinationModal(context),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Vaccine',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildVaccinationList(List<Map<String, dynamic>> vaccinations) {
    if (vaccinations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines, size: 64, color: Color(0xFF717973)),
            SizedBox(height: 16),
            Text(
              'No vaccinations',
              style: TextStyle(fontSize: 18, color: Color(0xFF717973)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinations.length,
      itemBuilder: (context, index) =>
          _buildVaccinationCard(vaccinations[index]),
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    final status = vaccination['status'] ?? 'scheduled';
    final statusColor = status == 'administered'
        ? const Color(0xFF0B5D3B)
        : const Color(0xFF735c00);
    final animalName = vaccination['animal_name'] ?? 'Unknown';
    final vaccineName = vaccination['vaccine_name'] ?? 'Vaccine';
    final scheduledDate =
        vaccination['scheduled_date']?.toString().split(' ').first ?? '';
    final administeredDate =
        vaccination['administered_date']?.toString().split(' ').first ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.vaccines,
                  color: Color(0xFF06402B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccineName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    Text(
                      animalName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status == 'administered' ? 'Done' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (vaccination['vaccination_type'] != null) ...[
                const Icon(Icons.science, size: 14, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  vaccination['vaccination_type'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717973),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF717973),
              ),
              const SizedBox(width: 4),
              Text(
                status == 'administered' ? administeredDate : scheduledDate,
                style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
              ),
              if (vaccination['dose_number'] != null) ...[
                const SizedBox(width: 16),
                const Icon(
                  Icons.format_list_numbered,
                  size: 14,
                  color: Color(0xFF717973),
                ),
                const SizedBox(width: 4),
                Text(
                  'Dose ${vaccination['dose_number']}/${vaccination['total_doses'] ?? 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717973),
                  ),
                ),
              ],
            ],
          ),
          if (vaccination['veterinarian'] != null ||
              vaccination['clinic'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  vaccination['veterinarian'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717973),
                  ),
                ),
                if (vaccination['clinic'] != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.local_hospital,
                    size: 14,
                    color: Color(0xFF717973),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vaccination['clinic'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF717973),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddVaccinationModal(BuildContext context) {
    final animalController = TextEditingController();
    final vaccineController = TextEditingController();
    final typeController = TextEditingController(text: 'initial');
    final doseController = TextEditingController(text: '1');
    final totalDosesController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
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
                    'Add Vaccination',
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
                      controller: animalController,
                      decoration: InputDecoration(
                        labelText: 'Animal ID',
                        filled: true,
                        fillColor: const Color(0xFFf4f4ef),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vaccineController,
                      decoration: InputDecoration(
                        labelText: 'Vaccine Name',
                        filled: true,
                        fillColor: const Color(0xFFf4f4ef),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'Type (initial/booster)',
                        filled: true,
                        fillColor: const Color(0xFFf4f4ef),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: doseController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Dose #',
                              filled: true,
                              fillColor: const Color(0xFFf4f4ef),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: totalDosesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total Doses',
                              filled: true,
                              fillColor: const Color(0xFFf4f4ef),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
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
                          final dataProvider = context.read<DataProvider>();
                          await dataProvider.createVaccination({
                            'animal_id':
                                int.tryParse(animalController.text) ?? 1,
                            'vaccine_name': vaccineController.text,
                            'vaccination_type': typeController.text,
                            'dose_number':
                                int.tryParse(doseController.text) ?? 1,
                            'total_doses':
                                int.tryParse(totalDosesController.text) ?? 1,
                            'notes': notesController.text,
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06402B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Vaccination'),
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
}
