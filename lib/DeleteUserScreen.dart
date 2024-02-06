import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({Key? key}) : super(key: key);

  @override
  _DeleteUserScreenState createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final TextEditingController _userIdController = TextEditingController();
  late Future<Map<String, dynamic>> _futureDeleteUser;
  
  @override
  void initState() {
    super.initState();
    _futureDeleteUser = Future.value({});
  }

  Future<void> _deleteUser() async {
    final int userId = int.tryParse(_userIdController.text) ?? 0;
    try {
      final response = await ApiService.deleteUser(userId);
      setState(() {
        _futureDeleteUser = Future.value(response);
      });
    } catch (e) {
      setState(() {
        _futureDeleteUser = Future.error(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _deleteUser,
              child: const Text('Delete User'),
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<Map<String, dynamic>>(
              future: _futureDeleteUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Center(child: Text('User deleted successfully'));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
}
