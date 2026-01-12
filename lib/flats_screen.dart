import 'package:flutter/material.dart';
import 'api_service.dart';
import 'rooms_screen.dart';

class FlatsScreen extends StatefulWidget {
  const FlatsScreen({super.key});

  @override
  State<FlatsScreen> createState() => _FlatsScreenState();
}

class _FlatsScreenState extends State<FlatsScreen> {
  List<dynamic> _flats = [];
  List<dynamic> _leaseOwners = [];
  bool _isLoading = true;

  final List<String> _bhkTypes = ['Studio', '1BHK', '2BHK', '3BHK', '4BHK', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        ApiService.getFlats(),
        ApiService.getLeaseOwners(),
      ]);

      final flatsResult = results[0];
      final ownersResult = results[1];

      setState(() {
        if (flatsResult['status'] == 'success') {
          _flats = flatsResult['data'];
        } else {
          _showError('Failed to load flats: ${flatsResult['message']}');
        }

        if (ownersResult['status'] == 'success') {
          _leaseOwners = ownersResult['data'];
        } else {
          _showError('Failed to load lease owners: ${ownersResult['message']}');
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

  void _showAddFlatDialog() {
    final flatNumberController = TextEditingController();
    final addressController = TextEditingController();
    String? selectedLeaseOwnerId;
    String selectedBhkType = '1BHK';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Flat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLeaseOwnerId,
                  hint: const Text('Select Lease Owner'),
                  items: _leaseOwners.map((owner) {
                    return DropdownMenuItem<String>(
                      value: owner['id'].toString(),
                      child: Text(owner['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedLeaseOwnerId = value),
                  decoration: const InputDecoration(labelText: 'Lease Owner'),
                ),
                TextField(
                  controller: flatNumberController,
                  decoration: const InputDecoration(labelText: 'Flat Number / Name'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedBhkType,
                  items: _bhkTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedBhkType = value!),
                  decoration: const InputDecoration(labelText: 'BHK Type'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Full Address'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedLeaseOwnerId == null || flatNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final result = await ApiService.addFlat(
                  flatNumber: flatNumberController.text,
                  bhkType: selectedBhkType,
                  leaseOwnerId: selectedLeaseOwnerId!,
                  address: addressController.text,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Add Flat'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flats Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flats.isEmpty
              ? const Center(child: Text('No flats found'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _flats.length,
                    itemBuilder: (context, index) {
                      final flat = _flats[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  flat['bhk_type'],
                                  style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Flat ${flat['flat_number']}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Owner: ${flat['lease_owner_name']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.meeting_room, size: 16, color: Colors.purple),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RoomsScreen(flatId: flat['id'].toString()),
                                        ),
                                      );
                                    },
                                    child: const Text('View Rooms', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFlatDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
