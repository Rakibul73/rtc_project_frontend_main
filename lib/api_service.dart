// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://localhost:5000';
const storage = FlutterSecureStorage();

class ApiService {
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'jwt_token');
  }

  static Future<void> sendPasswordToEmail(String email) async {
    const String apiUrl = '$baseUrl/send_password'; // Replace with your actual backend URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Password sent successfully
        print('Password sent to $email successfully');
        return;
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to send password to email');
      }
    } catch (e) {
      // If an error occurs, throw an exception
      throw Exception('Failed to send password to email: $e');
    }
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset_password/$token'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Password reset successfully: $responseBody for email ${responseBody['email']}');
      } else {
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<void> resetPasswordRequest(String email) async {
    final Uri url = Uri.parse('$baseUrl/reset_password_request');
    print("apiservice url: $url");

    final Map<String, dynamic> data = {
      "email": email,
    };

    print("data: $data");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Password reset link sent successfully
        print('Password reset link sent to $email successfully');
      } else {
        // Handle failure
        throw Exception('Failed to reset password: ${responseBody['message']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return {'message': 'User deleted successfully'};
    } else {
      throw Exception('Failed to delete user. errors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getSpecificUser(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load user details. Error: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_all_users'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['users'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users. errors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
    required int roleID,
  }) async {
    final Uri url = Uri.parse('$baseUrl/login');
    print("apiservice url: $url");

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "RoleID": roleID,
    };

    print("data: $data");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      return responseBody;
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required int roleID,
  }) async {
    final Uri url = Uri.parse('$baseUrl/register');
    print("apiservice url: $url");

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "email": email,
      "FirstName": firstName,
      "LastName": lastName,
      "Phone": phone,
      "RoleID": roleID,
    };

    print("sssssssssssssssss");
    print(jsonEncode(data));

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Add this line
        },
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      return responseBody;
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }
}
