import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';

class MedicalRecordsPage extends StatefulWidget {
  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadMedicalRecords();
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
          final records = dataProvider.medicalRecords.isNotEmpty
              ? dataProvider.medicalRecords.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;

          final checkups = records
              .where((r) => r['record_type'] == 'Checkup')
              .toList();
          final treatments = records
              .where((r) => r['record_type'] == 'Treatment')
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
                                  'Medical Records',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF06402B),
                                  ),
                                ),
                                Text(
                                  '${records.length} records',
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
                    Tab(text: 'Treatments'),
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
                      _buildRecordList(records),
                      _buildRecordList(treatments),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showAddRecordModal(context),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Record',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildRecordList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 64, color: Color(0xFF717973)),
            SizedBox(height: 16),
            Text(
              'No medical records',
              style: TextStyle(fontSize: 18, color: Color(0xFF717973)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) => _buildRecordCard(records[index]),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final recordType = record['record_type'] ?? 'Checkup';
    final animalName = record['animal_name'] ?? 'Unknown';
    final recordDate = record['record_date']?.toString().split(' ').first ?? '';
    final diagnosis = record['description'] ?? '';
    final treatment = record['description'] ?? '';
    final medication = record['medication'] ?? '';

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
                  color: const Color(0xFFba1a1a).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFFba1a1a),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animalName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    Text(
                      recordType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                recordDate,
                style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
              ),
            ],
          ),
          if (diagnosis.isNotEmpty) ...[
            const SizedBox(height: 12),
            _detailRow('Diagnosis', diagnosis),
          ],
          if (treatment.isNotEmpty) ...[_detailRow('Treatment', treatment)],
          if (medication.isNotEmpty) ...[_detailRow('Medication', medication)],
          if (record['vet_name'] != null) ...[
            _detailRow('Veterinarian', record['vet_name']),
          ],
          if (record['clinic'] != null) ...[
            _detailRow('Clinic', record['clinic']),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF06402B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordModal(BuildContext context) {
    final animalController = TextEditingController();
    final typeController = TextEditingController(text: 'Checkup');
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    final medicationController = TextEditingController();
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
                    'Add Medical Record',
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
                      keyboardType: TextInputType.number,
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
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'Record Type (Checkup/Treatment)',
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
                      controller: diagnosisController,
                      decoration: InputDecoration(
                        labelText: 'Diagnosis',
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
                      controller: treatmentController,
                      decoration: InputDecoration(
                        labelText: 'Treatment',
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
                      controller: medicationController,
                      decoration: InputDecoration(
                        labelText: 'Medication',
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
                          await dataProvider.createMedicalRecord({
                            'animal_id':
                                int.tryParse(animalController.text) ?? 1,
                            'record_type': typeController.text,
                            'title': diagnosisController.text,
                            'description': treatmentController.text,
                            'medication': medicationController.text,
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
                        child: const Text('Save Record'),
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
