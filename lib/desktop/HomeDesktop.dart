// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(); // Define the storage variable

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({Key? key}) : super(key: key);

  @override
  HomeDesktopState createState() => HomeDesktopState();
}

class HomeDesktopState extends State<HomeDesktop> {
  String? userId;
  String? accessToken;
  String? statuscode;

  Future<void> getUserIdAndAccessToken() async {
    final storedUserId = await storage.read(key: 'user_id');
    final storedAccessToken = await storage.read(key: 'jwt_token');
    final storedStatuscode = await storage.read(key: 'statuscode');
    setState(() {
      userId = storedUserId;
      accessToken = storedAccessToken;
      statuscode = storedStatuscode;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserIdAndAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder(
        future: _getUserDetails(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userId = snapshot.data?['userId'] ?? 'Unknown';
            final accessToken = snapshot.data?['accessToken'] ?? 'Unknown';
            final statuscode = snapshot.data?['statuscode'] ?? 'Unknown';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('User ID: $userId'),
                  const SizedBox(height: 20),
                  Text('Access Token: $accessToken'),
                  const SizedBox(height: 20),
                  Text('statuscode: $statuscode'),
                  // make a logout button
                  ElevatedButton(
                    onPressed: () {
                      storage.delete(key: 'jwt_token');
                      storage.delete(key: 'user_id');
                      storage.delete(key: 'statuscode');

                      // wait for 3 seconds
                      Future.delayed(const Duration(seconds: 3), () {
                        // redirect to login page
                        Navigator.pushReplacementNamed(context, '/login');
                      });
                    },
                    child: const Text('Logout'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/users');
                      },
                      child: const Text('View All Users')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/individualuser');
                      },
                      child: const Text('View individual User')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/deleteuser');
                      },
                      child: const Text('delet User')),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final userId = await storage.read(key: 'user_id') ?? 'Unknown';
    final accessToken = await storage.read(key: 'jwt_token') ?? 'Unknown';
    final statuscode = await storage.read(key: 'statuscode') ?? 'Unknown';
    return {
      'userId': userId,
      'accessToken': accessToken,
      'statuscode': statuscode,
    };
  }
}
