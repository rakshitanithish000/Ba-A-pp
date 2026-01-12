import 'package:flutter/material.dart';
import 'api_service.dart';

class REOwnersScreen extends StatefulWidget {
  const REOwnersScreen({super.key});

  @override
  State<REOwnersScreen> createState() => _REOwnersScreenState();
}

class _REOwnersScreenState extends State<REOwnersScreen> {
  List<dynamic> _owners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  Future<void> _fetchOwners() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getREOwners();
    if (result['status'] == 'success') {
      setState(() {
        _owners = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load owners')),
        );
      }
    }
  }

  void _showAddOwnerDialog() {
    final reIdController = TextEditingController();
    final nameController = TextEditingController(); 
    final cityController = TextEditingController();
    final phoneController = TextEditingController();
    final contactPersonController = TextEditingController();
    String status = 'Active';
    String? idError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isDuplicate = _owners.any((o) => o['re_id'] != null && o['re_id'].toString().toUpperCase() == reIdController.text.toUpperCase());

          return AlertDialog(
            title: const Text('Add RE Owner'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reIdController, 
                    decoration: InputDecoration(
                      labelText: 'ID (e.g., SH01)',
                      errorText: isDuplicate ? 'This ID already exists' : null,
                      suffixIcon: isDuplicate ? const Icon(Icons.warning, color: Colors.orange) : null,
                    ),
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'RE Owner Name')),
                  TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Contact Number')),
                  TextField(controller: contactPersonController, decoration: const InputDecoration(labelText: 'Contact Person Name')),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => status = val!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isDuplicate ? null : () async {
                  final result = await ApiService.addREOwner(
                    reId: reIdController.text,
                    name: nameController.text,
                    city: cityController.text,
                    phone: phoneController.text,
                    contactPerson: contactPersonController.text,
                    status: status,
                  );
                  if (result['status'] == 'success') {
                    if (context.mounted) {
                       Navigator.pop(context);
                       _fetchOwners();
                    }
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message']), backgroundColor: result['status'] == 'success' ? Colors.green : Colors.red),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditOwnerDialog(Map<String, dynamic> owner) {
    final reIdController = TextEditingController(text: owner['re_id']);
    final nameController = TextEditingController(text: owner['name']);
    final cityController = TextEditingController(text: owner['city']);
    final phoneController = TextEditingController(text: owner['phone']);
    final contactPersonController = TextEditingController(text: owner['contact_person']);
    String status = owner['status'] ?? 'Active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isDuplicate = _owners.any((o) => 
            o['id'].toString() != owner['id'].toString() && 
            o['re_id'] != null && 
            o['re_id'].toString().toUpperCase() == reIdController.text.toUpperCase()
          );

          return AlertDialog(
            title: const Text('Edit RE Owner'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reIdController, 
                    decoration: InputDecoration(
                      labelText: 'ID (e.g., SH01)',
                      errorText: isDuplicate ? 'This ID already exists' : null,
                      suffixIcon: isDuplicate ? const Icon(Icons.warning, color: Colors.orange) : null,
                    ),
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'RE Owner Name')),
                  TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Contact Number')),
                  TextField(controller: contactPersonController, decoration: const InputDecoration(labelText: 'Contact Person Name')),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => status = val!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isDuplicate ? null : () async {
                  final result = await ApiService.updateREOwner(
                    id: owner['id'].toString(),
                    reId: reIdController.text,
                    name: nameController.text,
                    city: cityController.text,
                    phone: phoneController.text,
                    contactPerson: contactPersonController.text,
                    status: status,
                  );
                  if (result['status'] == 'success') {
                    if (mounted) {
                       Navigator.pop(context);
                       _fetchOwners();
                    }
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message']), backgroundColor: result['status'] == 'success' ? Colors.green : Colors.red),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _deleteOwner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Owner'),
        content: const Text('Are you sure you want to delete this owner?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteREOwner(id);
      if (result['status'] == 'success') {
        _fetchOwners();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RE Owners')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _owners.isEmpty
              ? const Center(child: Text('No owners found'))
              : ListView.builder(
                  itemCount: _owners.length,
                  itemBuilder: (context, index) {
                    final owner = _owners[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      owner['re_id'] ?? '-', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (owner['status'] == 'Active') ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        owner['status'] ?? 'Active',
                                        style: TextStyle(
                                          color: (owner['status'] == 'Active') ? Colors.green : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      onPressed: () => _showEditOwnerDialog(owner),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _deleteOwner(owner['id'].toString()),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(owner['name'], style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('${owner['city'] ?? ''}'),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(owner['phone'] ?? '-'),
                                const SizedBox(width: 16),
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(child: Text(owner['contact_person'] ?? '-')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOwnerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
