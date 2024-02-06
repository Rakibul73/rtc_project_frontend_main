import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import the package

const storage = FlutterSecureStorage(); // Define the storage variable

void logout(BuildContext context) async {
  // Clear the JWT token stored locally
  await storage.delete(key: 'jwt_token');
  await storage.delete(key: 'userId');
  
  // Redirect the user to the login page
  Navigator.pushReplacementNamed(context, '/login');
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        logout(context);
      },
      child: const Text('Logout'),
    );
  }
}
