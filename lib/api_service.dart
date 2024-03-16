// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// const String baseUrl = 'http://192.168.1.188:5000';
const String baseUrl = 'http://localhost:5000';
const storage = FlutterSecureStorage();

class ApiService {
  static Future<String?> getAccessToken() async {
    print("getAccessToken called");
    return await storage.read(key: 'jwt_token');
    // await userDataProvider.loadAsync();
  }

  static Future<Map<String, dynamic>> getSelfProjectDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_self_project_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getSelfProjectDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getSelfProjectDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getSelfProjectDashboard: $e');
    }
  }

  static Future<Map<String, dynamic>> updateTempUserDetails(int userId, Map<String, dynamic> userData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_pending_user/$userId');
    print("updateTempUserDetails url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update Temp user: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> getSpecificPendingUser(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_pending_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 401) {
      print("token expired");
      return {'statuscode': 401};
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load user details. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchAllPendingUsers() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_pending_users');
    print("fetchAllPendingUsers url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data['TempUsers']);
        return data['TempUsers'];
      } else {
        print("fetchAllPendingUsers = Failed to load pending users: ${response.statusCode}");
        throw Exception('Failed to load pending users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load pending users : $e');
    }
  }

static Future<Map<String, dynamic>> approvePendingUser(int userID , String username) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/approve_temp_user/$userID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("approvePendingUser response: ${response.statusCode}");

    if (response.statusCode == 200) {
      return {'message': 'Username: $username approved successfully', 'statusCode': 200};
    } else if (response.statusCode == 403) {
      return {'message': 'Unauthorized access', 'statusCode': 403};
    } else {
      throw Exception('Failed to delete pending user. errors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deletePendingUser(int userID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_temp_user/$userID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("deletePendingUser response: ${response.statusCode}");

    if (response.statusCode == 200) {
      return {'message': 'Pending User with id $userID deleted successfully', 'statusCode': 200};
    } else if (response.statusCode == 403) {
      return {'message': 'Unauthorized access', 'statusCode': 403};
    } else {
      throw Exception('Failed to delete pending user. errors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getUserManagementOverview() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/user_management_overview');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getUserManagementOverview = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getUserManagementOverview = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getUserManagementOverview: $e');
    }
  }

  static Future<Map<String, Object>> downloadProjectSoftCopy(String endpoint, String filename) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }
    final String downloadUrl = '$baseUrl/$endpoint/$filename';
    try {
      // Create an anchor element to trigger the download
      final html.AnchorElement anchor = html.AnchorElement(href: downloadUrl);
      // Set the authorization header with the access token
      // anchor.headers['Authorization'] = 'Bearer $accessToken';
      anchor.download = filename; // Specify the filename for the downloaded file
      anchor.click(); // Trigger the download

      print("ooooooooooooooooooooooooooooo");

      // Wait for the download to complete
      // await Future.delayed(const Duration(seconds: 10));
      return {
        'statuscode': 200,
        'message': 'File downloaded successfully',
      };

      // Note: This approach works for web, but does not save the file locally on the device.
      // The file is downloaded by the browser and saved in the user's Downloads folder.
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProjectDetails(int projectId, Map<String, dynamic> updateProjectData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_project/$projectId');
    print("apiservice url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updateProjectData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update project: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> getSpecificProject(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    print("getSpecificProject $projectId");

    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 401) {
      print("token expired");
      return {'statuscode': 401};
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load project details. Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteProject(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("deleteProject response: ${response.statusCode}");

    if (response.statusCode == 200) {
      return {'message': 'Project with id $projectId deleted successfully', 'statusCode': 200};
    } else if (response.statusCode == 403) {
      return {'message': 'Unauthorized access', 'statusCode': 403};
    } else {
      throw Exception('Failed to delete user. errors: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchAllProjects() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/projects');
    print("fetchAllProjects url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data['projects']);
        return data['projects'];
      } else {
        print("fetchAllProjects = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<List<dynamic>> fetchMyProjects() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }
    final userId = await storage.read(key: 'user_id');

    final Uri url = Uri.parse('$baseUrl/myprojects/user/$userId');
    print("fetchMyProjects url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data['projects']);
        return data['projects'];
      } else {
        print("fetchMyProjects = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<String> fetchPicFile(String endpoint, String filename) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/$endpoint/$filename');
    print("fetchPicFile url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes); // Convert image bytes to base64 string
      } else {
        print("fetchPicFile = Failed to fetch $endpoint: ${response.statusCode} $filename");
        throw Exception('Failed to fetch $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch $endpoint: $e');
    }
  }

  static Future<Map<String, dynamic>> getAdminProjectDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_admin_project_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getProjectDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getProjectDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getProjectDashboard: $e');
    }
  }

  static Future<List<User>> getOnlyStudentUser() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_only_student_users');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<User> users = [];
        for (var item in jsonData['users']) {
          users.add(User.fromJson(item));
        }
        return users;
      } else {
        throw Exception('Failed to load get_only_student_users');
      }
    } catch (e) {
      throw Exception('Failed to fetch get_only_student_users: $e');
    }
  }

  static Future<List<User>> getAllUsersExceptStudents() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_users_except_students');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<User> users = [];
        for (var item in jsonData['users']) {
          users.add(User.fromJson(item));
        }
        return users;
      } else {
        throw Exception('Failed to load get_all_users_except_students');
      }
    } catch (e) {
      throw Exception('Failed to fetch get_all_users_except_students: $e');
    }
  }

  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/create_projects');
    print("createProject url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(projectData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Project created successfully
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to create project: ${responseBody['error']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String endpoint, file, fileBytes, fileName) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    print("uploadFile accessToken: $accessToken");

    final Uri url = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

    // print("uploadFile request: $request");

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTotalNumberOfAllDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_total_number_of_all_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getTotalNumberOfAllDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getTotalNumberOfAllDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch total number of users: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUserDetails(int userId, Map<String, dynamic> userData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_user/$userId');
    print("apiservice url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update user: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
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

  static Future<int> resetPassword(String token, String newPassword) async {
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
        return 200;
      } else if (response.statusCode == 400) {
        return 400;
      } else if (response.statusCode == 404) {
        return 404;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<int> resetPasswordRequest(String email) async {
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

      // final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Password reset link sent successfully
        print('Password reset link sent to $email successfully');
        return 200;
      } else if (response.statusCode == 404) {
        // Handle failure
        return 404;
      } else {
        return response.statusCode;
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

    print(response.statusCode);
    if (response.statusCode == 401) {
      print("token expired");
      return {'statuscode': 401};
    }
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

class User {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final String signatureLocation;
  final String sealLocation;

  User({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.signatureLocation,
    required this.sealLocation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['Userid'],
      username: json['Username'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      signatureLocation: json['SignatureLocation'] ?? '',
      sealLocation: json['SealLocation'] ?? '',
    );
  }

  String getDisplayName() {
    return '$firstName $lastName -- Username: $username';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
