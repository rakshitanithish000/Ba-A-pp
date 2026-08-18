import 'package:flutter/material.dart';
import 'api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _stats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getStats();
    if (result['status'] == 'success') {
      setState(() {
        _stats = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load stats')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.clearSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _stats.length,
                  itemBuilder: (context, index) {
                    final item = _stats[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['title'] == 'RE owners') {
                          Navigator.pushNamed(context, '/re_owners');
                        } else if (item['title'] == 'Lease Owners') {
                          Navigator.pushNamed(context, '/lease_owners');
                        } else if (item['title'] == 'Flats') {
                          Navigator.pushNamed(context, '/flats');
                        } else if (item['title'] == 'Rooms') {
                          Navigator.pushNamed(context, '/rooms');
                        } else if (item['title'] == 'Bed-spaces') {
                          Navigator.pushNamed(context, '/bed_spaces');
                        } else if (item['title'] == 'Guests') {
                          Navigator.pushNamed(context, '/guests');
                        } else if (item['title'] == 'Rental-Records') {
                          Navigator.pushNamed(context, '/rental_records');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item['title']} module coming soon!')),
                          );
                        }
                      },
                      child: _buildStatCard(
                        item['title'],
                        item['count'].toString(),
                        _getIconForTitle(item['title']),
                        _getColorForTitle(item['title']),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'RE owners': return Icons.business;
      case 'Lease Owners': return Icons.vpn_key;
      case 'Flats': return Icons.apartment;
      case 'Rooms': return Icons.meeting_room;
      case 'Bed-spaces': return Icons.bed;
      case 'Guests': return Icons.people;
      case 'Rental-Records': return Icons.receipt_long;
      default: return Icons.info;
    }
  }

  Color _getColorForTitle(String title) {
    switch (title) {
      case 'RE owners': return Colors.blue;
      case 'Lease Owners': return Colors.green;
      case 'Flats': return Colors.orange;
      case 'Rooms': return Colors.purple;
      case 'Bed-spaces': return Colors.teal;
      case 'Guests': return Colors.pink;
      case 'Rental-Records': return Colors.indigo;
      default: return Colors.grey;
    }
  }
}
