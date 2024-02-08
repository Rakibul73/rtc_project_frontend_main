import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';

class UserScreenDesktop extends StatefulWidget {
  const UserScreenDesktop({Key? key}) : super(key: key);

  @override
  UserScreenDesktopState createState() => UserScreenDesktopState();
}

class UserScreenDesktopState extends State<UserScreenDesktop> {
  late Future<List<Map<String, dynamic>>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = ApiService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['Username']),
                  subtitle: Text(user['Email']),
                  // Display other user details as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
