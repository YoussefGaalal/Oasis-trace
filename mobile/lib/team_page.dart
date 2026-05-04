import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';
import 'api_service.dart';

class TeamPage extends StatefulWidget {
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _usersScrollController = ScrollController();
  String _searchQuery = '';
  String _roleFilter = '';
  final Map<int, bool> _expandedOwners = {};
  List<dynamic> _subscriptionTiers = [];
  bool _isLoadingTiers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _usersScrollController.addListener(_onUsersScroll);
    _loadSubscriptionTiers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadUsers();
    });
  }

  Future<void> _loadSubscriptionTiers() async {
    setState(() => _isLoadingTiers = true);
    try {
      final tiers = await ApiService.getSubscriptionTiers();
      setState(() {
        _subscriptionTiers = tiers.cast<Map<String, dynamic>>();
        _isLoadingTiers = false;
      });
    } catch (e) {
      setState(() => _isLoadingTiers = false);
    }
  }

  void _onUsersScroll() {
    if (_usersScrollController.position.pixels >= _usersScrollController.position.maxScrollExtent - 200) {
      context.read<DataProvider>().loadMoreUsers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usersScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final canEdit = userRole == 'Admin' || userRole == 'Owner';
    final isAdmin = userRole == 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final users = dataProvider.users.isNotEmpty ? dataProvider.users : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoadingUsers;
          final owners = users.where((u) => u['role'] == 'Owner').toList();

          log('TeamPage: users.length=${users.length}, isLoading=$isLoading');

          return CustomScrollView(
            slivers: [
              UnifiedAppBar(title: 'Team', showBackButton: true, onBack: () => Navigator.pop(context)),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF06402B),
                    unselectedLabelColor: const Color(0xFF717973),
                    indicatorColor: const Color(0xFF06402B),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'All Users (${users.length})'),
                      if (isAdmin) Tab(text: 'Teams (${owners.length})'),
                      if (!isAdmin) Tab(text: 'My Team'),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _roleFilter,
                              isExpanded: true,
                              hint: const Text('All', style: TextStyle(fontSize: 14)),
                              items: () {
                                final dataProvider = context.read<DataProvider>();
                                final roles = dataProvider.roleNames;
                                final items = <DropdownMenuItem<String>>[
                                  const DropdownMenuItem(value: '', child: Text('All', style: TextStyle(fontSize: 14))),
                                ];
                                for (final r in roles) {
                                  items.add(DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))));
                                }
                                return items;
                              }(),
                              onChanged: (value) => setState(() => _roleFilter = value ?? ''),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Color(0xFF06402B)))
                    : users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text('No users found (API returned: ${users.length})', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => context.read<DataProvider>().loadUsers(),
                                  child: Text('Reload'),
                                ),
                              ],
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUsersTab(users, auth, canEdit, dataProvider.isLoadingUsers),
                              isAdmin ? _buildTeamsTab(users, auth) : _buildMyTeamTab(users, auth, canEdit),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberDialog(context, context.read<DataProvider>().users, userRole, canEdit, auth),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Add Member', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildUsersTab(List<dynamic> users, AuthProvider auth, bool canEdit, bool isLoadingMore) {
    final filtered = _filterUsers(users);
    if (filtered.isEmpty && !isLoadingMore) return _buildEmptyState();

    return ListView.builder(
      controller: _usersScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= filtered.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF06402B)),
            ),
          );
        }
        return _buildUserCard(filtered[index], auth, canEdit);
      },
    );
  }

  Widget _buildTeamsTab(List<dynamic> users, AuthProvider auth) {
    final owners = users.where((u) => u['role'] == 'Owner').toList();
    if (owners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No owners found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: owners.length,
      itemBuilder: (context, index) => _buildOwnerSection(owners[index], users, auth),
    );
  }

  Widget _buildMyTeamTab(List<dynamic> users, AuthProvider auth, bool canEdit) {
    final myId = auth.user?['id'];
    final myTeam = users.where((u) => u['managed_by'] == myId).toList();
    final filtered = _filterUsers(myTeam);
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No team members yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildUserCard(filtered[index], auth, canEdit),
    );
  }

  Widget _buildOwnerSection(Map<String, dynamic> owner, List<dynamic> allUsers, AuthProvider auth) {
    final ownerMembers = allUsers.where((u) => u['managed_by'] == owner['id']).toList();
    final filteredMembers = _filterUsers(ownerMembers);
    final isExpanded = _expandedOwners[owner['id']] ?? true;
    final isOwnTeam = owner['id'] == auth.user?['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOwnTeam ? Border.all(color: const Color(0xFF735c00), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedOwners[owner['id']] = !isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isOwnTeam ? const Color(0xFF735c00) : const Color(0xFF06402B),
                    child: Text((owner['name'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(owner['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF06402B))),
                            if (isOwnTeam) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF0B5D3B), borderRadius: BorderRadius.circular(8)),
                                child: const Text('Your Account', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        Text(owner['email'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF717973))),
                        Text('${filteredMembers.length} members', style: const TextStyle(fontSize: 11, color: Color(0xFF717973))),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF717973)),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            if (filteredMembers.isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text('No team members', style: TextStyle(color: Color(0xFF717973))))
            else
              ...filteredMembers.map((m) => _buildTeamMemberRow(m)),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamMemberRow(Map<String, dynamic> member) {
    final roleColor = _getRoleColor(member['role'] ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: roleColor, child: Icon(Icons.person, size: 16, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Text(member['name'] ?? '', style: const TextStyle(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(member['role'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor)),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    return users.where((u) {
      final matchesSearch = _searchQuery.isEmpty || (u['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter.isEmpty || u['role'] == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Widget _buildUserCard(Map<String, dynamic> user, AuthProvider auth, bool canEdit) {
    final roleColor = _getRoleColor(user['role'] ?? '');
    final isActive = user['is_active'] == true || user['is_active'] == 1;
    final isOwn = user['id'] == auth.user?['id'];
    final showActions = canEdit && !isOwn;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: roleColor, radius: 20, child: Text((user['name'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(user['email'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF717973))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(user['role'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor)),
          ),
          const SizedBox(width: 8),
          if (showActions)
            Switch(
              value: isActive,
              activeColor: const Color(0xFF06402B),
              onChanged: (value) async {
                try {
                  final result = await ApiService.toggleUserStatus(user['id']);
                  if (result['user'] != null && context.mounted) {
                    context.read<DataProvider>().updateUser(result['user']);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to toggle status: $e')));
                  }
                }
              },
            ),
          if (showActions)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF717973)),
              onSelected: (value) async {
                if (value == 'edit') {
                  _showEditMemberDialog(context, user, context.read<DataProvider>().users, auth.user?['role'] ?? '', canEdit, auth);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, user);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(_searchQuery.isNotEmpty ? 'No matching users' : 'No users found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, List<dynamic> users, String userRole, bool canEdit, AuthProvider auth) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: 'Welcome123');
    String selectedRole = 'Shepherd';
    int? selectedOwnerId;
    int? selectedTierId;
    final owners = users.where((u) => u['role'] == 'Owner').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('Add Team Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF06402B)))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: _inputDecoration('Name')),
              const SizedBox(height: 12),
              TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Email')),
              const SizedBox(height: 12),
              TextField(controller: passwordController, obscureText: true, decoration: _inputDecoration('Password')),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: selectedRole,
                decoration: _inputDecoration('Role'),
                items: _getAvailableRoles(userRole),
                onChanged: canEdit ? (value) {
                  final newRole = (value as String?) ?? 'Shepherd';
                  setSheetState(() {
                    selectedRole = newRole;
                    if (newRole == 'Admin' || newRole == 'Owner') selectedOwnerId = null;
                  });
                } : null,
              ),
              if (owners.isNotEmpty && selectedRole != 'Admin' && selectedRole != 'Owner') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedOwnerId,
                  decoration: _inputDecoration('Assign to Owner'),
                  items: owners.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['name'] ?? ''))).toList(),
                  onChanged: canEdit ? (value) => setSheetState(() => selectedOwnerId = value as int?) : null,
                ),
              ],
              if (userRole == 'Admin' && selectedRole == 'Owner' && _subscriptionTiers.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedTierId,
                  decoration: _inputDecoration('Current Plan'),
                  items: _subscriptionTiers.map((t) => DropdownMenuItem(
                    value: t['id'] as int,
                    child: Text(t['name'] ?? 'Unknown'),
                  )).toList(),
                  onChanged: canEdit ? (value) => setSheetState(() => selectedTierId = value as int?) : null,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canEdit ? () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email are required')));
                      return;
                    }
                    try {
                      int? managedBy;
                      if (userRole == 'Owner' || userRole == 'Admin') {
                        managedBy = selectedOwnerId ?? auth.user?['id'] as int?;
                      } else {
                        managedBy = selectedOwnerId;
                      }
                      final userData = {
                        'name': nameController.text,
                        'email': emailController.text,
                        'role': selectedRole,
                        'password': passwordController.text,
                        'managed_by': managedBy,
                      };
                      if (userRole == 'Admin' && selectedRole == 'Owner' && selectedTierId != null) {
                        userData['subscription_tier_id'] = selectedTierId;
                      }
                      await ApiService.createUser(userData);
                      if (context.mounted) {
                        context.read<DataProvider>().loadUsers();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team member added!')));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: canEdit ? const Color(0xFF06402B) : Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(canEdit ? 'Send Invitation' : 'Access Denied'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFf4f4ef),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  void _showEditMemberDialog(BuildContext context, Map<String, dynamic> user, List<dynamic> users, String userRole, bool canEdit, AuthProvider auth) {
    final nameController = TextEditingController(text: user['name'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    String selectedRole = user['role'] ?? 'Shepherd';
    int? selectedOwnerId = user['managed_by'];
    int? selectedTierId = user['subscription_tier_id'];
    final owners = users.where((u) => u['role'] == 'Owner').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('Edit Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF06402B)))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: _inputDecoration('Name')),
              const SizedBox(height: 12),
              TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Email')),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: selectedRole,
                decoration: _inputDecoration('Role'),
                items: _getAvailableRoles(userRole),
                onChanged: canEdit ? (value) => setSheetState(() {
                  selectedRole = value as String;
                  if (selectedRole == 'Admin' || selectedRole == 'Owner') selectedOwnerId = null;
                }) : null,
              ),
              if (userRole == 'Admin' && owners.isNotEmpty && selectedRole != 'Admin' && selectedRole != 'Owner') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedOwnerId,
                  decoration: _inputDecoration('Assign to Owner'),
                  items: owners.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['name'] ?? ''))).toList(),
                  onChanged: canEdit ? (value) => setSheetState(() => selectedOwnerId = value as int?) : null,
                ),
              ],
              if (userRole == 'Admin' && selectedRole == 'Owner' && _subscriptionTiers.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedTierId,
                  decoration: _inputDecoration('Current Plan'),
                  items: _subscriptionTiers.map((t) => DropdownMenuItem(
                    value: t['id'] as int,
                    child: Text(t['name'] ?? 'Unknown'),
                  )).toList(),
                  onChanged: canEdit ? (value) => setSheetState(() => selectedTierId = value as int?) : null,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canEdit ? () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email are required')));
                      return;
                    }
                    try {
                      final userData = {
                        'name': nameController.text,
                        'email': emailController.text,
                        'role': selectedRole,
                        'managed_by': selectedOwnerId,
                      };
                      if (userRole == 'Admin' && selectedRole == 'Owner' && selectedTierId != null) {
                        userData['subscription_tier_id'] = selectedTierId;
                      }
                      await ApiService.updateUser(user['id'], userData);
                      if (context.mounted) {
                        context.read<DataProvider>().loadUsers();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member updated!')));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06402B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteUser(user['id']);
                if (context.mounted) {
                  context.read<DataProvider>().loadUsers();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getAvailableRoles(String userRole) {
    final dataProvider = context.read<DataProvider>();
    final roles = dataProvider.getAssignableRoles(userRole);
    if (roles.isEmpty) {
      return [const DropdownMenuItem(value: 'Employee', child: Text('Employee'))];
    }
    return roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Owner':
        return const Color(0xFF735c00);
      case 'Admin':
        return Colors.red;
      case 'Doctor':
        return Colors.purple;
      case 'Manager':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
