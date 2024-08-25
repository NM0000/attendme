import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = "http://192.168.1.2:8000";

  Future<List<dynamic>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<http.Response> addStudent(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/students/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
  }

  Future<http.Response> updateStudent(int id, Map<String, dynamic> data) async {
    return await http.put(
      Uri.parse('$baseUrl/students/$id/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
  }

  Future<http.Response> deleteStudent(int id) async {
    return await http.delete(
      Uri.parse('$baseUrl/students/$id/'),
    );
  }
}
