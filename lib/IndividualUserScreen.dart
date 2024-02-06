// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';

class IndividualUserScreen extends StatefulWidget {
  const IndividualUserScreen({Key? key}) : super(key: key);

  @override
  IndividualUserScreenState createState() => IndividualUserScreenState();
}

class IndividualUserScreenState extends State<IndividualUserScreen> {
  final TextEditingController _userIdController = TextEditingController();
  Future<Map<String, dynamic>>? _futureUser;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
  final int userId = int.tryParse(_userIdController.text) ?? 0;
  try {
    final dynamic responseData = await ApiService.getSpecificUser(userId);
    final Map<String, dynamic> userData = responseData['user'];
    setState(() {
      _futureUser = Future.value(userData);
    });
  } catch (e) {
    setState(() {
      _futureUser = Future.error(e.toString());
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Individual User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'Enter User ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserDetails,
              child: const Text('Fetch User'),
            ),
            const SizedBox(height: 16),
            if (_futureUser != null)
              FutureBuilder<Map<String, dynamic>>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final user = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text('Username'),
                          subtitle: Text(user['Username'] ?? ''),
                        ),
                        ListTile(
                          title: Text('Email'),
                          subtitle: Text(user['Email'] ?? ''),
                        ),
                        // Add more ListTile widgets to display other user details
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
