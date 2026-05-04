import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'navigation.dart';
import 'unified_header.dart';

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFfafaf5), child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class TasksPage extends StatefulWidget {
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadTasks();
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
          final tasks = dataProvider.tasks.isNotEmpty
              ? dataProvider.tasks.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;

          final pendingTasks = tasks
              .where((t) => t['status'] == 'pending')
              .cast<Map<String, dynamic>>()
              .toList();
          final completedTasks = tasks
              .where((t) => t['status'] == 'completed')
              .cast<Map<String, dynamic>>()
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              UnifiedAppBar(
                title: 'Tasks',
                showBackButton: true,
                onBack: () {
                  print('Back button pressed');
                  Navigator.pop(context);
                },
              ),
              SliverPersistentHeader(
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF06402B),
                    unselectedLabelColor: const Color(0xFF717973),
                    indicatorColor: const Color(0xFF06402B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    tabs: [
                      Tab(text: 'Pending (${pendingTasks.length})'),
                      Tab(text: 'Completed (${completedTasks.length})'),
                      Tab(text: 'All (${tasks.length})'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ],
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(pendingTasks),
                      _buildTaskList(completedTasks),
                      _buildTaskList(tasks),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () {
                print('FAB pressed - opening create task dialog');
                _showCreateTaskDialog(context);
              },
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Task',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Color(0xFF717973)),
            SizedBox(height: 16),
            Text(
              'No tasks',
              style: TextStyle(fontSize: 18, color: Color(0xFF717973)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final priority = task['priority'] ?? 'medium';
    final status = task['status'] ?? 'pending';
    Color priorityColor;
    IconData priorityIcon;

    switch (priority) {
      case 'urgent':
        priorityColor = const Color(0xFFba1a1a);
        priorityIcon = Icons.priority_high;
        break;
      case 'high':
        priorityColor = const Color(0xFF735c00);
        priorityIcon = Icons.arrow_upward;
        break;
      case 'low':
        priorityColor = const Color(0xFF0B5D3B);
        priorityIcon = Icons.arrow_downward;
        break;
      default:
        priorityColor = const Color(0xFF717973);
        priorityIcon = Icons.remove;
    }

    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';

    String statusText;
    Color statusColor;
    if (isCompleted) {
      statusText = 'Completed';
      statusColor = const Color(0xFF0B5D3B);
    } else if (isInProgress) {
      statusText = 'In Progress';
      statusColor = const Color(0xFF1976D2);
    } else {
      statusText = 'Pending';
      statusColor = const Color(0xFF735c00);
    }

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(priorityIcon, color: priorityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] ?? 'Task',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? const Color(0xFF717973)
                            : const Color(0xFF06402B),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task['description'] != null)
                      Text(
                        task['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF717973),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
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
              const Icon(Icons.person, size: 14, color: Color(0xFF717973)),
              const SizedBox(width: 4),
              Text(
                task['assignee_name'] ??
                    task['assigned_to']?.toString() ??
                    'Unassigned',
                style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
              ),
              if (task['animal_name'] != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.pets, size: 14, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  task['animal_name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717973),
                  ),
                ),
              ],
              const SizedBox(width: 16),
              const Icon(Icons.schedule, size: 14, color: Color(0xFF717973)),
              const SizedBox(width: 4),
              Text(
                task['due_date']?.toString().split(' ').first ?? 'No due date',
                style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'medium';
    String? selectedAnimalId;
    String? selectedTaskType;
    String? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
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
                      'Create Task',
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
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
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
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ['low', 'medium', 'high', 'urgent']
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => priority = v ?? 'medium'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedTaskType,
                        decoration: InputDecoration(
                          labelText: 'Task Type',
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'feeding',
                            child: Text('Feeding'),
                          ),
                          DropdownMenuItem(
                            value: 'medical',
                            child: Text('Medical'),
                          ),
                          DropdownMenuItem(
                            value: 'movement',
                            child: Text('Movement'),
                          ),
                          DropdownMenuItem(
                            value: 'inspection',
                            child: Text('Inspection'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (v) =>
                            setModalState(() => selectedTaskType = v),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<dynamic>>(
                        future: ApiService.getAnimals(),
                        builder: (ctx, snapshot) {
                          final animals = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: selectedAnimalId,
                            decoration: InputDecoration(
                              labelText: 'Assign to Animal',
                              filled: true,
                              fillColor: const Color(0xFFf4f4ef),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('No Animal'),
                              ),
                              ...animals.map(
                                (a) => DropdownMenuItem(
                                  value: a['id']?.toString(),
                                  child: Text(
                                    '${a['animal_id']} - ${a['name'] ?? a['animal_id']}',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) =>
                                setModalState(() => selectedAnimalId = v),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Title is required'),
                                ),
                              );
                              return;
                            }
                            try {
                              final Map<String, dynamic> taskData = {
                                'title': titleController.text,
                                'description': descController.text.isNotEmpty
                                    ? descController.text
                                    : null,
                                'priority': priority,
                                'status': 'pending',
                              };
                              if (selectedTaskType != null)
                                taskData['task_type'] = selectedTaskType;
                              if (selectedAnimalId != null) {
                                final animalIdInt = int.tryParse(
                                  selectedAnimalId!,
                                );
                                if (animalIdInt != null) {
                                  taskData['animal_id'] = animalIdInt;
                                }
                              }

                              await ApiService.createTask(taskData);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task created')),
                              );
                              final dataProvider = context.read<DataProvider>();
                              await dataProvider.loadTasks();
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
                            'Create Task',
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
      ),
    );
  }
}
