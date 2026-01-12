import 'package:flutter/material.dart';
import 'api_service.dart';
import 'guests_screen.dart';

class BedSpacesScreen extends StatefulWidget {
  final String? roomId;
  const BedSpacesScreen({super.key, this.roomId});

  @override
  State<BedSpacesScreen> createState() => _BedSpacesScreenState();
}

class _BedSpacesScreenState extends State<BedSpacesScreen> {
  List<dynamic> _beds = [];
  List<dynamic> _rooms = [];
  bool _isLoading = true;

  final List<String> _statusOptions = ['Available', 'Occupied', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        ApiService.getBedSpaces(roomId: widget.roomId),
        ApiService.getRooms(),
      ]);

      final bedsResult = results[0];
      final roomsResult = results[1];

      setState(() {
        if (bedsResult['status'] == 'success') {
          _beds = bedsResult['data'];
        } else {
          _showError('Failed to load bed-spaces: ${bedsResult['message']}');
        }

        if (roomsResult['status'] == 'success') {
          _rooms = roomsResult['data'];
        } else {
          _showError('Failed to load rooms: ${roomsResult['message']}');
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

  void _showAddBedDialog() {
    final bedNameController = TextEditingController();
    final rentController = TextEditingController();
    String? selectedRoomId = widget.roomId;
    String selectedStatus = 'Available';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Bed-Space'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  hint: const Text('Select Room'),
                  items: _rooms.map((room) {
                    return DropdownMenuItem<String>(
                      value: room['id'].toString(),
                      child: Text('Room ${room['room_number']} (Flat ${room['flat_number']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedRoomId = value),
                  decoration: const InputDecoration(labelText: 'Room'),
                ),
                TextField(
                  controller: bedNameController,
                  decoration: const InputDecoration(labelText: 'Bed Name / Number (e.g. Bed A)'),
                ),
                TextField(
                  controller: rentController,
                  decoration: const InputDecoration(labelText: 'Monthly Rent'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedStatus = value!),
                  decoration: const InputDecoration(labelText: 'Initial Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedRoomId == null || bedNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final result = await ApiService.addBedSpace(
                  bedName: bedNameController.text,
                  monthlyRent: rentController.text,
                  status: selectedStatus,
                  roomId: selectedRoomId!,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Add Bed'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Occupied': return Colors.red;
      case 'Maintenance': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomId != null ? 'Beds in Room' : 'All Bed-Spaces'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _beds.isEmpty
              ? const Center(child: Text('No bed-spaces found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _beds.length,
                  itemBuilder: (context, index) {
                    final bed = _beds[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(bed['status']).withOpacity(0.1),
                          child: Icon(Icons.bed, color: _getStatusColor(bed['status'])),
                        ),
                        title: Text(bed['bed_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Flat: ${bed['flat_number']} | Room: ${bed['room_number']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AED ${bed['monthly_rent']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(bed['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                bed['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getStatusColor(bed['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuestsScreen(bedSpaceId: bed['id'].toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBedDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
