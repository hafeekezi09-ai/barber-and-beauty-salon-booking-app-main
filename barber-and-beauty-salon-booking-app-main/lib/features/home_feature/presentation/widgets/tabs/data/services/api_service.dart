import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final storage = FlutterSecureStorage();

  // Example: fetch all salons (protected API)
  Future<http.Response> fetchAllSalons() async {
    final token = await storage.read(key: 'token');

    return await http.get(
      Uri.parse('https://yourapi.com/all-salons'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Example: fetch dashboard data
  Future<http.Response> fetchDashboardData() async {
    final token = await storage.read(key: 'token');

    return await http.get(
      Uri.parse('https://yourapi.com/dashboard-data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
