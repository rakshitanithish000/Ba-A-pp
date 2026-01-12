import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your Hostinger domain URL
  static const String baseUrl = 'https://app.efficientgroupdubai.com';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_dashboard_stats.php'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  // --- NEW: Owners Management ---

  static Future<Map<String, dynamic>> getREOwners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/manage_owners.php?action=get_re_owners'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addREOwner({
    required String reId,
    required String name,
    required String city,
    required String phone,
    required String contactPerson,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=add_re_owner'),
        body: {
            're_id': reId,
            'name': name,
            'city': city,
            'phone': phone,
            'contact_person': contactPerson,
            'status': status,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
           return {'status': 'error', 'message': 'The server returned an empty response.'};
        }
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'status': 'error', 'message': 'Invalid JSON: ${response.body}'};
        }
      } else {
        return {'status': 'error', 'message': 'Server Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateREOwner({
    required String id,
    required String reId,
    required String name,
    required String city,
    required String phone,
    required String contactPerson,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=update_re_owner'),
        body: {
          'id': id,
          're_id': reId,
          'name': name,
          'city': city,
          'phone': phone,
          'contact_person': contactPerson,
          'status': status,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Connection Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteREOwner(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=delete_re_owner'),
        body: {'id': id},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Connection Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getLeaseOwners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/manage_owners.php?action=get_lease_owners'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addLeaseOwner({
    required String name,
    required String phone,
    required String company,
    required String reOwnerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=add_lease_owner'),
        body: {
          'name': name,
          'phone': phone,
          'company_name': company,
          're_owner_id': reOwnerId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> updateLeaseOwner({
    required String id,
    required String name,
    required String phone,
    required String company,
    required String reOwnerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=update_lease_owner'),
        body: {
          'id': id,
          'name': name,
          'phone': phone,
          'company_name': company,
          're_owner_id': reOwnerId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> deleteLeaseOwner(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_owners.php?action=delete_lease_owner'),
        body: {'id': id},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // --- NEW: Flats Management ---

  static Future<Map<String, dynamic>> getFlats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/manage_flats.php?action=get_flats'));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addFlat({
    required String flatNumber,
    required String bhkType,
    required String leaseOwnerId,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_flats.php?action=add_flat'),
        body: {
          'flat_number': flatNumber,
          'bhk_type': bhkType,
          'lease_owner_id': leaseOwnerId,
          'address': address,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // --- NEW: Rooms Management ---

  static Future<Map<String, dynamic>> getRooms({String? flatId}) async {
    try {
      final url = flatId != null 
          ? '$baseUrl/api/manage_rooms.php?action=get_rooms&flat_id=$flatId'
          : '$baseUrl/api/manage_rooms.php?action=get_rooms';
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addRoom({
    required String roomNumber,
    required String maxOccupancy,
    required String flatId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_rooms.php?action=add_room'),
        body: {
          'room_number': roomNumber,
          'max_occupancy': maxOccupancy,
          'flat_id': flatId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // --- NEW: Bed-Spaces Management ---

  static Future<Map<String, dynamic>> getBedSpaces({String? roomId}) async {
    try {
      final url = roomId != null 
          ? '$baseUrl/api/manage_bed_spaces.php?action=get_bed_spaces&room_id=$roomId'
          : '$baseUrl/api/manage_bed_spaces.php?action=get_bed_spaces';
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addBedSpace({
    required String bedName,
    required String monthlyRent,
    required String status,
    required String roomId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_bed_spaces.php?action=add_bed_space'),
        body: {
          'bed_name': bedName,
          'monthly_rent': monthlyRent,
          'status': status,
          'room_id': roomId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // --- NEW: Guest Management ---

  static Future<Map<String, dynamic>> getGuests({String? bedSpaceId}) async {
    try {
      final url = bedSpaceId != null 
          ? '$baseUrl/api/manage_guests.php?action=get_guests&bed_space_id=$bedSpaceId'
          : '$baseUrl/api/manage_guests.php?action=get_guests';
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addGuest({
    required String name,
    required String phone,
    required String idProof,
    required String checkInDate,
    required String bedSpaceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_guests.php?action=add_guest'),
        body: {
          'name': name,
          'phone': phone,
          'id_proof_number': idProof,
          'check_in_date': checkInDate,
          'bed_space_id': bedSpaceId,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // --- NEW: Rental Records Management ---

  static Future<Map<String, dynamic>> getRentalRecords({String? guestId}) async {
    try {
      final url = guestId != null 
          ? '$baseUrl/api/manage_rental_records.php?action=get_rental_records&guest_id=$guestId'
          : '$baseUrl/api/manage_rental_records.php?action=get_rental_records';
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> addRentalRecord({
    required String guestId,
    required String amountPaid,
    required String paymentDate,
    required String paymentMonth,
    required String paymentStatus,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/manage_rental_records.php?action=add_rental_record'),
        body: {
          'guest_id': guestId,
          'amount_paid': amountPaid,
          'payment_date': paymentDate,
          'payment_month': paymentMonth,
          'payment_status': paymentStatus,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }
}
