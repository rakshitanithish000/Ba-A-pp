import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 're_owners_screen.dart';
import 'lease_owners_screen.dart';
import 'flats_screen.dart';
import 'rooms_screen.dart';
import 'bed_spaces_screen.dart';
import 'guests_screen.dart';
import 'rental_records_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/re_owners': (context) => const REOwnersScreen(),
        '/lease_owners': (context) => const LeaseOwnersScreen(),
        '/flats': (context) => const FlatsScreen(),
        '/rooms': (context) => const RoomsScreen(),
        '/bed_spaces': (context) => const BedSpacesScreen(),
        '/guests': (context) => const GuestsScreen(),
        '/rental_records': (context) => const RentalRecordsScreen(),
      },
    );
  }
}
