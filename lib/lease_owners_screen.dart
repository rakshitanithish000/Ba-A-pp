import 'package:flutter/material.dart';
import 'api_service.dart';

class LeaseOwnersScreen extends StatefulWidget {
  const LeaseOwnersScreen({super.key});

  @override
  State<LeaseOwnersScreen> createState() => _LeaseOwnersScreenState();
}

class _LeaseOwnersScreenState extends State<LeaseOwnersScreen> {
  List<dynamic> _leaseOwners = [];
  List<dynamic> _reOwners = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedREOwnerId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final leaseResult = await ApiService.getLeaseOwners();
    final reResult = await ApiService.getREOwners();

    if (leaseResult['status'] == 'success' && reResult['status'] == 'success') {
      setState(() {
        _leaseOwners = leaseResult['data'];
        _reOwners = reResult['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    }
  }

  void _showAddDialog() {
    _nameController.clear();
    _phoneController.clear();
    _companyController.clear();
    _selectedREOwnerId = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Lease Owner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedREOwnerId,
                  decoration: const InputDecoration(labelText: 'Select RE Owner'),
                  items: _reOwners.map((owner) {
                    return DropdownMenuItem<String>(
                      value: owner['id'].toString(),
                      child: Text(owner['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => _selectedREOwnerId = val),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedREOwnerId == null || _nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final result = await ApiService.addLeaseOwner(
                  name: _nameController.text,
                  phone: _phoneController.text,
                  company: _companyController.text,
                  reOwnerId: _selectedREOwnerId!,
                );

                if (result['status'] == 'success') {
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> owner) {
    _nameController.text = owner['name'] ?? '';
    _phoneController.text = owner['phone'] ?? '';
    _companyController.text = owner['company_name'] ?? '';
    _selectedREOwnerId = owner['re_owner_id']?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Lease Owner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedREOwnerId,
                  decoration: const InputDecoration(labelText: 'Select RE Owner'),
                  items: _reOwners.map((owner) {
                    return DropdownMenuItem<String>(
                      value: owner['id'].toString(),
                      child: Text(owner['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => _selectedREOwnerId = val),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedREOwnerId == null || _nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final result = await ApiService.updateLeaseOwner(
                  id: owner['id'].toString(),
                  name: _nameController.text,
                  phone: _phoneController.text,
                  company: _companyController.text,
                  reOwnerId: _selectedREOwnerId!,
                );

                if (result['status'] == 'success') {
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteOwner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lease Owner'),
        content: const Text('Are you sure you want to delete this lease owner?'),
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
      final result = await ApiService.deleteLeaseOwner(id);
      if (result['status'] == 'success') {
        _fetchData();
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
      appBar: AppBar(title: const Text('Lease Owners')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _leaseOwners.length,
              itemBuilder: (context, index) {
                final owner = _leaseOwners[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(owner['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${owner['phone']}'),
                        Text('Company: ${owner['company_name']}'),
                        Text('RE Owner: ${owner['re_owner_name'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(owner),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOwner(owner['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
