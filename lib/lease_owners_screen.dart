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

  void _showAddLeaseOwnerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final companyController = TextEditingController();
    String? selectedREOwnerId;

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
                  value: selectedREOwnerId,
                  hint: const Text('Select RE Owner'),
                  items: _reOwners.map((owner) {
                    return DropdownMenuItem<String>(
                      value: owner['id'].toString(),
                      child: Text(owner['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedREOwnerId = value),
                  decoration: const InputDecoration(labelText: 'RE Owner'),
                ),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company Name')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedREOwnerId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an RE Owner')),
                  );
                  return;
                }
                final result = await ApiService.addLeaseOwner(
                  name: nameController.text,
                  phone: phoneController.text,
                  company: companyController.text,
                  reOwnerId: selectedREOwnerId!,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lease Owners')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaseOwners.isEmpty
              ? const Center(child: Text('No lease owners found'))
              : ListView.builder(
                  itemCount: _leaseOwners.length,
                  itemBuilder: (context, index) {
                    final owner = _leaseOwners[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(Icons.vpn_key, color: Colors.green),
                        ),
                        title: Text(owner['name']),
                        subtitle: Text(
                          'Company: ${owner['company_name']}\n'
                          'Leased From: ${owner['re_owner_name'] ?? 'N/A'}\n'
                          'Phone: ${owner['phone']}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLeaseOwnerDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
