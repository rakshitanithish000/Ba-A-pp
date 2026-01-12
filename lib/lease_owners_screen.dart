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
  final TextEditingController _leaseOwnerIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _eidRefController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _selectedREOwnerId;
  String _selectedStatus = 'Active';

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
    _leaseOwnerIdController.clear();
    _nameController.clear();
    _nationalityController.clear();
    _eidRefController.clear();
    _expiryDateController.clear();
    _phoneController.clear();
    _remarksController.clear();
    _selectedREOwnerId = null;
    _selectedStatus = 'Active';

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
                  controller: _leaseOwnerIdController,
                  decoration: const InputDecoration(labelText: 'Lease Owner ID (e.g. TN001)'),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Lease-owner Name'),
                ),
                TextField(
                  controller: _nationalityController,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                ),
                TextField(
                  controller: _eidRefController,
                  decoration: const InputDecoration(labelText: 'EID Ref'),
                ),
                TextField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'YYYY-MM-DD',
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        _expiryDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (val) => setDialogState(() => _selectedStatus = val!),
                ),
                TextField(
                  controller: _remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                  maxLines: 2,
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
                  reOwnerId: _selectedREOwnerId!,
                  leaseOwnerIdText: _leaseOwnerIdController.text,
                  name: _nameController.text,
                  nationality: _nationalityController.text,
                  eidRef: _eidRefController.text,
                  expiryDate: _expiryDateController.text,
                  phone: _phoneController.text,
                  status: _selectedStatus,
                  remarks: _remarksController.text,
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
    _leaseOwnerIdController.text = owner['lease_owner_id_text'] ?? '';
    _nameController.text = owner['name'] ?? '';
    _nationalityController.text = owner['nationality'] ?? '';
    _eidRefController.text = owner['eid_ref'] ?? '';
    _expiryDateController.text = owner['expiry_date'] ?? '';
    _phoneController.text = owner['phone'] ?? '';
    _remarksController.text = owner['remarks'] ?? '';
    _selectedREOwnerId = owner['re_owner_id']?.toString();
    _selectedStatus = owner['status'] ?? 'Active';

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
                  controller: _leaseOwnerIdController,
                  decoration: const InputDecoration(labelText: 'Lease Owner ID (e.g. TN001)'),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Lease-owner Name'),
                ),
                TextField(
                  controller: _nationalityController,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                ),
                TextField(
                  controller: _eidRefController,
                  decoration: const InputDecoration(labelText: 'EID Ref'),
                ),
                TextField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'YYYY-MM-DD',
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        _expiryDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (val) => setDialogState(() => _selectedStatus = val!),
                ),
                TextField(
                  controller: _remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                  maxLines: 2,
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
                  reOwnerId: _selectedREOwnerId!,
                  leaseOwnerIdText: _leaseOwnerIdController.text,
                  name: _nameController.text,
                  nationality: _nationalityController.text,
                  eidRef: _eidRefController.text,
                  expiryDate: _expiryDateController.text,
                  phone: _phoneController.text,
                  status: _selectedStatus,
                  remarks: _remarksController.text,
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
                    title: Text('${owner['lease_owner_id_text'] ?? ''} - ${owner['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nationality: ${owner['nationality'] ?? ''}'),
                        Text('EID Ref: ${owner['eid_ref'] ?? ''}'),
                        Text('Expiry: ${owner['expiry_date'] ?? ''}'),
                        Text('Phone: ${owner['phone']}'),
                        Text('Status: ${owner['status']}'),
                        Text('RE Owner: ${owner['re_owner_name'] ?? 'N/A'}'),
                        if (owner['remarks'] != null && owner['remarks'].isNotEmpty)
                          Text('Remarks: ${owner['remarks']}'),
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
