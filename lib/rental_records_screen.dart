import 'package:flutter/material.dart';
import 'api_service.dart';

class RentalRecordsScreen extends StatefulWidget {
  final String? guestId;
  const RentalRecordsScreen({super.key, this.guestId});

  @override
  State<RentalRecordsScreen> createState() => _RentalRecordsScreenState();
}

class _RentalRecordsScreenState extends State<RentalRecordsScreen> {
  List<dynamic> _records = [];
  List<dynamic> _guests = [];
  bool _isLoading = true;

  final List<String> _paymentStatuses = ['Paid', 'Partial', 'Pending'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final recordsResult = await ApiService.getRentalRecords(guestId: widget.guestId);
    
    // Fetch all guests for the add payment dialog
    final guestsResult = await ApiService.getGuests();

    if (recordsResult['status'] == 'success' && guestsResult['status'] == 'success') {
      setState(() {
        _records = recordsResult['data'];
        _guests = guestsResult['data'];
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

  void _showAddPaymentDialog() {
    final amountController = TextEditingController();
    final monthController = TextEditingController(text: _getCurrentMonth());
    DateTime selectedDate = DateTime.now();
    String? selectedGuestId = widget.guestId;
    String selectedStatus = 'Paid';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedGuestId,
                  hint: const Text('Select Guest'),
                  items: _guests.map((guest) {
                    return DropdownMenuItem<String>(
                      value: guest['id'].toString(),
                      child: Text('${guest['name']} (Flat ${guest['flat_number']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedGuestId = value),
                  decoration: const InputDecoration(labelText: 'Guest'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount Paid (AED)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: monthController,
                  decoration: const InputDecoration(labelText: 'Payment For (e.g. Jan 2026)'),
                ),
                ListTile(
                  title: Text('Payment Date: ${selectedDate.toString().split(' ')[0]}'),
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
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: _paymentStatuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedStatus = value!),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedGuestId == null || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select guest and enter amount')),
                  );
                  return;
                }
                final result = await ApiService.addRentalRecord(
                  guestId: selectedGuestId!,
                  amountPaid: amountController.text,
                  paymentDate: selectedDate.toString().split(' ')[0],
                  paymentMonth: monthController.text,
                  paymentStatus: selectedStatus,
                );
                if (result['status'] == 'success') {
                  Navigator.pop(context);
                  _fetchData();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid': return Colors.green;
      case 'Partial': return Colors.orange;
      case 'Pending': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guestId != null ? 'Guest Payments' : 'All Rental Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('No payment records found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: const Icon(Icons.receipt_long, color: Colors.indigo),
                        ),
                        title: Text(
                          'AED ${record['amount_paid']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Guest: ${record['guest_name']}'),
                            Text('For: ${record['payment_month']} | Date: ${record['payment_date']}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(record['payment_status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(record['payment_status'])),
                          ),
                          child: Text(
                            record['payment_status'],
                            style: TextStyle(
                              color: _getStatusColor(record['payment_status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
