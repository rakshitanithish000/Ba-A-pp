import 'package:flutter/material.dart';
import 'api_service.dart';
import 'bed_spaces_screen.dart';

class RoomsScreen extends StatefulWidget {
  final String? flatId;
  const RoomsScreen({super.key, this.flatId});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<dynamic> _rooms = [];
  List<dynamic> _flats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final roomsResult = await ApiService.getRooms(flatId: widget.flatId);
    final flatsResult = await ApiService.getFlats();

    if (roomsResult['status'] == 'success' && flatsResult['status'] == 'success') {
      setState(() {
        _rooms = roomsResult['data'];
        _flats = flatsResult['data'];
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

  void _showAddRoomDialog() {
    final roomNumberController = TextEditingController();
    final occupancyController = TextEditingController(text: '1');
    String? selectedFlatId = widget.flatId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Room'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedFlatId,
                  hint: const Text('Select Flat'),
                  items: _flats.map((flat) {
                    return DropdownMenuItem<String>(
                      value: flat['id'].toString(),
                      child: Text('Flat ${flat['flat_number']}'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedFlatId = value),
                  decoration: const InputDecoration(labelText: 'Flat'),
                ),
                TextField(
                  controller: roomNumberController,
                  decoration: const InputDecoration(labelText: 'Room Number / Name'),
                ),
                TextField(
                  controller: occupancyController,
                  decoration: const InputDecoration(labelText: 'Max Occupancy'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedFlatId == null || roomNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final result = await ApiService.addRoom(
                  roomNumber: roomNumberController.text,
                  maxOccupancy: occupancyController.text,
                  flatId: selectedFlatId!,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Add Room'),
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
        title: Text(widget.flatId != null ? 'Rooms in Flat' : 'All Rooms'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('No rooms found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.meeting_room, color: Colors.purple),
                        ),
                        title: Text('Room ${room['room_number']}'),
                        subtitle: Text('In Flat: ${room['flat_number']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Capacity: ${room['max_occupancy']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BedSpacesScreen(roomId: room['id'].toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
