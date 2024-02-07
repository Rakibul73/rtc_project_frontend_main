// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(); // Define the storage variable

class LoginTablet extends StatefulWidget {
  const LoginTablet({Key? key}) : super(key: key);

  @override
  LoginTabletState createState() => LoginTabletState();
}

class LoginTabletState extends State<LoginTablet> {
  // input Controllers
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  String selectedRole = 'Teacher'; // Default to 'Admin'

  Future<void> loginUser() async {
    try {
      print("role name: $selectedRole");
      final roleId = getRoleId(selectedRole); // Map role name to role ID
      // Use ApiService to register user
      print("role id: $roleId");
      final response = await ApiService.loginUser(
        username: usernameController.text,
        password: passwordController.text,
        roleID: roleId,
      );

      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print(response);
      print("=========================================");


      if (response['statuscode'] == 200) {
        // User logged in successfully
        print('User logged in successfully');
        // Store token securely (e.g., SharedPreferences)
        await storage.write(key: 'jwt_token', value: (response['access_token']).toString());
        // store user_id in secure storage
        await storage.write(key: 'user_id', value: (response['user_id']).toString());
        // store statuscode in secure storage
        await storage.write(key: 'statuscode', value: response['statuscode'].toString());
        // Redirect to home page or perform any other necessary actions
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle login failure
        print('Login failed: ${response['message']}');
      }
    } catch (e) {
      // Handle exception
      print('Exception during login: $e');
    }
  }

  // Function to map role name to role ID
  int getRoleId(String roleName) {
    switch (roleName) {
      case 'Admin':
        return 1;
      case 'Teacher':
        return 4;
      case 'Student':
        return 5;
      case 'Reviewer':
        return 3;
      case 'Researcher':
        return 2;
      default:
        // Default to 1 (Admin) if not found
        return 1;
    }
  }

  // Controllers
  late ScrollController _scrollController;

  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();
    // initialize input controllers
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 59, 66, 72),
      child: Row(
        children: [
          Expanded(
              //<-- Expanded widget
              child: Image.asset(
            'assets/image.jpg',
            fit: BoxFit.cover,
          )),
          Expanded(
            //<-- Expanded widget
            child: WebSmoothScroll(
              controller: _scrollController,
              scrollOffset: 100,
              animationDuration: 600,
              curve: Curves.easeInOutCirc,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 21),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      _header(context),
                      _inputField(context),
                      const SizedBox(height: 25),
                      _forgotPassword(context),
                      const SizedBox(height: 30),
                      _signup(context),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Login to your account',
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 35),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
              filled: true,
              prefixIcon: const Icon(Icons.account_circle)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
            filled: true,
            prefixIcon: const Icon(Icons.password_outlined),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: selectedRole,
          onChanged: (String? value) {
            setState(() {
              selectedRole = value!;
            });
          },
          decoration: InputDecoration(
            hintText: "RoleID",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
            filled: true,
            prefixIcon: const Icon(Icons.password_outlined),
          ),
          items: ['Admin', 'Teacher', 'Student', 'Reviewer', 'Researcher'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: loginUser,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.6),
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Color.fromARGB(255, 3, 123, 236), fontSize: 16),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have an account? "),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: const Text("Sign Up", style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 3, 123, 236))))
      ],
    );
  }
}
