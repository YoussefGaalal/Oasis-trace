import 'package:flutter/material.dart';
import 'api_service.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _translations = [];
  bool _isLoading = false;
  String _selectedLang = 'en';
  String _selectedGroup = 'common';

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _nativeNameController = TextEditingController();
  String _direction = 'ltr';
  String? _editingCode;

  final List<String> _groups = ['common', 'dashboard', 'animals', 'devices', 'geofences', 'alerts', 'tasks', 'auctions', 'profile', 'settings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _loadLanguages();
      } else {
        _loadTranslations();
      }
    });
    _loadLanguages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _nativeNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguages() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getLanguages();
      setState(() {
        _languages = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getTranslations(group: _selectedGroup, lang: _selectedLang);
      setState(() {
        _translations = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveLanguage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'code': _codeController.text.toLowerCase(),
        'name': _nameController.text,
        'native_name': _nativeNameController.text,
        'direction': _direction,
      };

      if (_editingCode != null) {
        await ApiService.updateLanguage(_editingCode!, data);
      } else {
        await ApiService.createLanguage(data);
      }

      _clearForm();
      _loadLanguages();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteLanguage(String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Language'),
        content: Text('Delete $code? This will also delete all translations.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteLanguage(code);
        _loadLanguages();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _setDefault(String code) async {
    try {
      await ApiService.setDefaultLanguage(code);
      _loadLanguages();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> lang) async {
    try {
      await ApiService.updateLanguage(lang['code'], {'is_active': !(lang['is_active'] == 1)});
      _loadLanguages();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveTranslation(int id, String value) async {
    try {
      await ApiService.updateTranslation(id, {'value': value});
      _loadTranslations();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  void _clearForm() {
    setState(() {
      _editingCode = null;
      _codeController.clear();
      _nameController.clear();
      _nativeNameController.clear();
      _direction = 'ltr';
    });
  }

  void _editLanguage(Map<String, dynamic> lang) {
    setState(() {
      _editingCode = lang['code'];
      _codeController.text = lang['code'];
      _nameController.text = lang['name'];
      _nativeNameController.text = lang['native_name'];
      _direction = lang['direction'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Languages'),
            Tab(text: 'Translations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLanguagesTab(),
          _buildTranslationsTab(),
        ],
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_editingCode != null ? 'Edit Language' : 'Add Language', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          enabled: _editingCode == null,
                          decoration: const InputDecoration(labelText: 'Code', hintText: 'e.g. en'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nativeNameController,
                          decoration: const InputDecoration(labelText: 'Native Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _direction,
                          decoration: const InputDecoration(labelText: 'Direction'),
                          items: const [
                            DropdownMenuItem(value: 'ltr', child: Text('LTR')),
                            DropdownMenuItem(value: 'rtl', child: Text('RTL')),
                          ],
                          onChanged: (v) => setState(() => _direction = v ?? 'ltr'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveLanguage,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06402B)),
                        child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_editingCode != null ? 'Update' : 'Add Language'),
                      ),
                      if (_editingCode != null) ...[
                        const SizedBox(width: 16),
                        TextButton(onPressed: _clearForm, child: const Text('Cancel')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ..._languages.map((lang) => _buildLanguageCard(lang)),
      ],
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> lang) {
    final isActive = lang['is_active'] == 1;
    final isDefault = lang['is_default'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? const Color(0xFF06402B) : Colors.grey,
          child: Text(lang['code'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(lang['name']),
        subtitle: Text('${lang['native_name']} • ${lang['direction'].toString().toUpperCase()}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Chip(
                          label: const Text('Active', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.green)
            else
              Chip(
                      label: const Text('Inactive', style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.red),
            if (isDefault)
              Chip(
                label: const Text('Default', style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue),
            PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'edit': _editLanguage(lang); break;
                  case 'toggle': _toggleActive(lang); break;
                  case 'default': _setDefault(lang['code']); break;
                  case 'delete': _deleteLanguage(lang['code']); break;
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
                PopupMenuItem(value: 'toggle', child: Row(children: [Icon(Icons.toggle_on), SizedBox(width: 8), Text(isActive ? 'Disable' : 'Enable')])),
                if (!isDefault) const PopupMenuItem(value: 'default', child: Row(children: [Icon(Icons.star), SizedBox(width: 8), Text('Set Default')])),
                if (!isDefault) const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLang,
                decoration: const InputDecoration(labelText: 'Language'),
                items: _languages.map((l) => DropdownMenuItem<String>(value: l['code'] as String, child: Text(l['name'] as String))).toList(),
                onChanged: (v) => setState(() { _selectedLang = v ?? 'en'; _loadTranslations(); }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Group'),
                items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() { _selectedGroup = v ?? 'common'; _loadTranslations(); }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ...(_translations.map((t) => ListTile(
            title: Text(t['key'], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            subtitle: TextFormField(
              initialValue: t['value'],
              decoration: const InputDecoration(labelText: 'Translation'),
              onFieldSubmitted: (value) => _saveTranslation(t['id'], value),
            ),
          ))),
      ],
    );
  }
}