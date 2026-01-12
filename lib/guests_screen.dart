import 'package:flutter/material.dart';
import 'api_service.dart';

import 'rental_records_screen.dart';

class GuestsScreen extends StatefulWidget {
  final String? bedSpaceId;
  const GuestsScreen({super.key, this.bedSpaceId});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  List<dynamic> _guests = [];
  List<dynamic> _availableBeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        ApiService.getGuests(bedSpaceId: widget.bedSpaceId),
        ApiService.getBedSpaces(),
      ]);

      final guestsResult = results[0];
      final bedsResult = results[1];

      setState(() {
        if (guestsResult['status'] == 'success') {
          _guests = guestsResult['data'];
        } else {
          _showError('Failed to load guests: ${guestsResult['message']}');
        }

        if (bedsResult['status'] == 'success') {
          _availableBeds = (bedsResult['data'] as List)
              .where((bed) => bed['status'] == 'Available')
              .toList();
        } else {
          _showError('Failed to load bed-spaces: ${bedsResult['message']}');
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showAddGuestDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final idProofController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedBedId = widget.bedSpaceId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register New Guest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBedId,
                  hint: const Text('Select Available Bed'),
                  items: _availableBeds.map((bed) {
                    return DropdownMenuItem<String>(
                      value: bed['id'].toString(),
                      child: Text('${bed['bed_name']} (Flat ${bed['flat_number']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedBedId = value),
                  decoration: const InputDecoration(labelText: 'Bed Space'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Guest Full Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: idProofController,
                  decoration: const InputDecoration(labelText: 'ID / Passport Number'),
                ),
                ListTile(
                  title: Text('Check-in Date: ${selectedDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedBedId == null || nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill name and select a bed')),
                  );
                  return;
                }
                final result = await ApiService.addGuest(
                  name: nameController.text,
                  phone: phoneController.text,
                  idProof: idProofController.text,
                  checkInDate: selectedDate.toString().split(' ')[0],
                  bedSpaceId: selectedBedId!,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bedSpaceId != null ? 'Current Guest' : 'All Guests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guests.isEmpty
              ? const Center(child: Text('No guests registered'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _guests.length,
                  itemBuilder: (context, index) {
                    final guest = _guests[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(guest['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bed: ${guest['bed_name']} | Room: ${guest['room_number']}'),
                            Text('ID: ${guest['id_proof_number'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'In: ${guest['check_in_date']}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RentalRecordsScreen(guestId: guest['id'].toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuestDialog,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
