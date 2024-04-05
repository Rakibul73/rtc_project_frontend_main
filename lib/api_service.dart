// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// const String baseUrl = 'http://192.168.1.188:5000';
const String baseUrl = 'http://localhost:5000';
// const String baseUrl = 'https://rakib73.pythonanywhere.com';
const storage = FlutterSecureStorage();

class ApiService {
  static Future<String?> getAccessToken() async {
    print("getAccessToken called");
    return await storage.read(key: 'jwt_token');
    // await userDataProvider.loadAsync();
  }

  static Future<List<dynamic>> fetchAdminFundConfirmList() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_admin_fund_confirm_list');
    print("fetchAdminFundConfirmList url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['projects_fund_confirm'];
      } else {
        print("fetchAdminFundConfirmList = Failed to load fetchAdminFundConfirmList : ${response.statusCode}");
        throw Exception('Failed to load fetchAdminFundConfirmList: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load fetchAdminFundConfirmList : $e');
    }
  }

  static Future<Map<String, dynamic>> updateFundSendValue(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_fund_send/$projectID');
    print("updateFundSendValue url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update updateFundSendValue : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> checkProjectFundSendOrNot(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/check_a_project_fund_send_or_not/$projectID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    final data = json.decode(response.body);

    print("checkProjectFundSendOrNot: ${data['ProjectFundSendCheck']}");

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to check project fund send or not. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchAdminFundQueueList() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_admin_fund_queue_list');
    print("fetchAdminFundQueueList url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['projects_fund_queue'];
      } else {
        print("fetchAdminFundQueueList = Failed to load fetchAdminFundQueueList : ${response.statusCode}");
        throw Exception('Failed to load fetchAdminFundQueueList: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load fetchAdminFundQueueList : $e');
    }
  }

  static Future<Map<String, dynamic>> getAdminFundDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_admin_fund_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getAdminFundDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getAdminFundDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getAdminFundDashboard: $e');
    }
  }

  static Future<Map<String, dynamic>> updateConfirmFundRecieved(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_confirm_fund_recieved/$projectID');
    print("updateConfirmFundRecieved url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update updateConfirmFundRecieved : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> checkProjectFundConfirmedOrNot(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/check_a_project_fund_confirmation_send_or_not/$projectID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    final data = json.decode(response.body);

    print("checkProjectFundConfirmedOrNot: ${data['ProjectConfirmFundCheck']}");

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to check project confirmed or not. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchMyFundedProject() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_my_funded_projects');
    print("fetchMyFundedProject url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['projects'];
      } else {
        print("fetchMyFundedProject = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<Map<String, dynamic>> getFundDetailsForSpecificProject(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_fund_details_for_specific_project/$projectID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
      throw Exception('Failed to load getFundDetailsForSpecificProject. Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createFundRequestForSpecificProject(Map<String, dynamic> fundRequestData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/create_fund_request_for_specific_project');
    print("createFundRequestForSpecificProject url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(fundRequestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to createFundRequestForSpecificProject: ${responseBody['error']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSpecificUserDetailsForFundApply(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<Map<String, dynamic>> getSpecificProjectForFundSelf(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    print("getSpecificProjectForFundSelf $projectId");

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_project_for_fund_self/$projectId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<Map<String, dynamic>> checkProjectFundAppliedOrNot(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/check_a_project_fund_applied_or_not/$projectID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    final data = json.decode(response.body);

    print("checkProjectFundAppliedOrNot: ${data['ProjectRequestFundCheck']}");

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to check project reviewed or not. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchMyProjectsICanApplyFund() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_myprojects_can_apply_fund');
    print("fetchMyProjectsICanApplyFund url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['projects'];
      } else {
        print("fetchMyProjectsICanApplyFund = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<Map<String, dynamic>> getMyFundDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_my_fund_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getMyFundDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getMyFundDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getMyFundDashboard: $e');
    }
  }

  static Future<List<dynamic>> fetchAllBudgetOfAProjectReview(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_review_project_budget/$projectId');
    print("fetchAllBudgetOfAProjectReview url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['budget_list'];
      } else {
        print("fetchAllBudgetOfAProjectReview = Failed to load projects budget: ${response.statusCode}");
        throw Exception('Failed to load projects budget: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects budget: $e');
    }
  }

  static Future<List<dynamic>> fetchAllGanttOfAProjectReview(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_review_project_gantt/$projectId');
    print("fetchAllGanttOfAProjectReview url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['gantt_list'];
      } else {
        print("fetchAllGanttOfAProjectReview = Failed to load projects gantt: ${response.statusCode}");
        throw Exception('Failed to load projects gantt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects gantt: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProjectBudgetDetails(int projectID, List<dynamic> budgetFormDataForUpload) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_project_budget/$projectID');
    print("updateProjectBudgetDetails url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(budgetFormDataForUpload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update project budget : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<List<dynamic>> fetchAllBudgetOfAProject(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_self_project_budget/$projectId');
    print("fetchAllBudgetOfAProject url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['budget_list'];
      } else {
        print("fetchAllBudgetOfAProject = Failed to load projects budget: ${response.statusCode}");
        throw Exception('Failed to load projects budget: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects budget: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProjectGanttDetails(int projectID, List<dynamic> ganttFormDataForUpload) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_project_gantt/$projectID');
    print("updateProjectGanttDetails url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(ganttFormDataForUpload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update project gantt : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<List<dynamic>> fetchAllGanttOfAProject(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_self_project_gantt/$projectId');
    print("fetchAllGanttOfAProject url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['gantt_list'];
      } else {
        print("fetchAllGanttOfAProject = Failed to load projects gantt: ${response.statusCode}");
        throw Exception('Failed to load projects gantt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects gantt: $e');
    }
  }

  static Future<Map<String, dynamic>> createprojectBudget(int projectId, Map<String, dynamic> projectBudgetData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/create_project_budget/$projectId');
    print("createprojectBudget url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(projectBudgetData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Project created successfully
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to create project Budget: ${responseBody['error']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createProjectGantt(int projectId, Map<String, dynamic> projectGanttData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/create_project_gantt/$projectId');
    print("createProjectGantt url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(projectGanttData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Project created successfully
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to create project Gantt: ${responseBody['error']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchProjectsUnassignedReviewer() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_projects_have_to_set_reviewer');
    print("fetchProjectsUnassignedReviewer url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ProjectHaveToSetReviewerList'];
      } else {
        print("fetchProjectsUnassignedReviewer = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<List<dynamic>> fetchAllProjectPiCanView() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_projects_pi_can_view_review');
    print("fetchAllProjectPiCanView url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ProjectsPiCanViewReview'];
      } else {
        print("fetchAllProjectPiCanView = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<Map<String, dynamic>> updatePiCanViewOrNot(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_picanviewornot/$projectID');
    print("updatePiCanViewOrNot url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update PiCanViewOrNot : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> updateProjectStatusAndPoints(int projectID, Map<String, dynamic> projectData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/update_projectstatus_point/$projectID');
    print("updateProjectStatusAndPoints url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(projectData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to update ProjectStatus : ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> getProjectStatusSpecificProject(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_project_status_specific_project/$projectID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
      throw Exception('Failed to load ProjectStatus. Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getSpecificUserMinimum(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_user_minimum/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<List<dynamic>> fetchAllReviewForSpecificProject(int projectID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_reviews_for_specific_project/$projectID');
    print("fetchAllReviewForSpecificProject url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reviews'];
      } else {
        print("fetchAllReviewForSpecificProject = Failed to load Reviews: ${response.statusCode}");
        throw Exception('Failed to load Reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load Reviews : $e');
    }
  }

  static Future<List<dynamic>> fetchAllProjectsReviewerGivenReview() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_projects_reviewer_given_review');
    print("fetchAllProjectsReviewerGivenReview url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['projects'];
      } else {
        print("fetchAllProjectsReviewerGivenReview = Failed to load projects: ${response.statusCode}");
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load projects : $e');
    }
  }

  static Future<Map<String, dynamic>> getReviewPanelOverview() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/review_panel_overview');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getReviewPanelOverview = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getReviewPanelOverview = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getReviewPanelOverview: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllReviewsForSpecificReviewer(Map<String, dynamic> projectIDAndReviewerUserID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_reviews_for_specific_reviewer');
    print("getAllReviewsForSpecificReviewer url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(projectIDAndReviewerUserID),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to getAllReviewsForSpecificReviewer: ${responseBody['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createReviewSpecificProject(Map<String, dynamic> reviewData) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/create_reviews_specific_project');
    print("createReviewSpecificProject url: $url");

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(reviewData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Project created successfully
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to createReviewSpecificProject: ${responseBody['error']}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> checkProjectReviewedOrNot(int projectID, int userID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/check_a_project_reviewed_or_not/$projectID/$userID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    final data = json.decode(response.body);

    print("checkProjectReviewedOrNot: ${data['ProjectReviewCheck']}");

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to check project reviewed or not. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchAllProjectHaveToReviewList() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_projects_have_to_review');
    print("fetchAllProjectHaveToReviewList url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data['ProjectHaveToReviewList']);
        return data['ProjectHaveToReviewList'];
      } else {
        print("fetchAllProjectHaveToReviewList = Failed to load Project Have To Review: ${response.statusCode}");
        throw Exception('Failed to load Project Have To Review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load Project Have To Review : $e');
    }
  }

  static Future<Map<String, dynamic>> getReviewDashboard() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/review_dashboard');
    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("getReviewDashboard = responseBody: $responseBody");
        return responseBody;
      } else if (response.statusCode == 401) {
        print("getReviewDashboard = Token expired");
        return {'statuscode': 401}; // Return status code as a map
      } else {
        return {'statuscode': response.statusCode}; // Return status code as a map
      }
    } catch (e) {
      throw Exception('Failed to fetch getReviewDashboard: $e');
    }
  }

  static Future<Map<String, dynamic>> getReviewerUserId(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    print("getSpecificNotification $projectId");

    final response = await http.get(
      Uri.parse('$baseUrl/get_revieweruserid_for_specific_project/$projectId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
      throw Exception('Failed to load notification details. Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> setReviewer(Map<String, dynamic> reviewer1, Map<String, dynamic> reviewer2, Map<String, dynamic> reviewer3) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/set_reviewer_for_specific_project');
    print("setReviewer url: $url");

    try {
      final http.Response response1 = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(reviewer1),
      );
      final http.Response response2 = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(reviewer2),
      );
      final http.Response response3 = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
        body: jsonEncode(reviewer3),
      );

      print('Response status: ${response1.statusCode}');
      print('Response body: ${response1.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response1.body);

      if (response1.statusCode == 201 && response2.statusCode == 201 && response3.statusCode == 201) {
        // reviewer set successfully
        return responseBody;
      } else {
        // Failed to create project
        throw Exception('Failed to set reviewer: ${responseBody['error']} | ${jsonDecode(response2.body)} | ${jsonDecode(response3.body)} ');
      }
    } catch (e) {
      // Rethrow the exception to propagate it up the call stack.
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSpecificNotification(int notificationID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    print("getSpecificNotification $notificationID");

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_notification/$notificationID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
      throw Exception('Failed to load notification details. Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> requestProjectDeletionToAdmin(int projectId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/request_project_deletion_to_admin/$projectId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    print("requestProjectDeletionToAdmin response: ${response.statusCode}");

    if (response.statusCode == 200) {
      return {'message': 'Project with id $projectId requested for deletion', 'statusCode': 200};
    } else if (response.statusCode == 403) {
      return {'message': 'Unauthorized access', 'statusCode': 403};
    } else {
      throw Exception('Failed to request project deletion. errors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> markAllAsRead() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/mark_all_as_read');
    print("markAllAsRead url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to mark all as read: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<List<dynamic>> fetchAllNotifications() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_all_notification');
    print("fetchAllNotifications url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['AllNotifications'];
      } else {
        print("fetchAllNotifications = Failed to load All Notifications: ${response.statusCode}");
        throw Exception('Failed to load All Notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load All Notifications : $e');
    }
  }

  static Future<Map<String, dynamic>> markAsUnread(int notificationID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/mark_as_unread/$notificationID');
    print("updateTempUserDetails url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
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

  static Future<Map<String, dynamic>> markAsRead(int notificationID) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/mark_as_read/$notificationID');
    print("markAsRead url: $url");

    try {
      final http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception('Failed to mark as read: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to propagate it up the call stack.
    }
  }

  static Future<Map<String, dynamic>> getUsernameFromUserId(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_user_name_of_specific_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
      },
    );

    final data = json.decode(response.body);

    print("getUsernameFromUserId: ${data['Username']}");

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load user name. Error: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchMyNotifications() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final Uri url = Uri.parse('$baseUrl/get_self_notification');
    print("fetchMyNotifications url: $url");

    try {
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data['MyNotifications']);
        return data['MyNotifications'];
      } else {
        print("fetchMyNotifications = Failed to load My Notifications: ${response.statusCode}");
        throw Exception('Failed to load My Notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load My Notifications : $e');
    }
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<Map<String, dynamic>> approvePendingUser(int userID, String username) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/approve_temp_user/$userID'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<int> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset_password/$token'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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

  static Future<Map<String, dynamic>> getSpecificUser(int userId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_specific_user/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
    required String facultyName,
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
      "FacultyName": facultyName,
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
          'Accept-Encoding': 'gzip, deflate, br', // Specify the supported compression types
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
  final String profilePicLocation;

  User({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.signatureLocation,
    required this.sealLocation,
    required this.profilePicLocation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['Userid'],
      username: json['Username'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      signatureLocation: json['SignatureLocation'] ?? '',
      sealLocation: json['SealLocation'] ?? '',
      profilePicLocation: json['ProfilePicLocation'] ?? '',
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
