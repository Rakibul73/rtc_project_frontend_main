// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'dart:async';

class SignupTablet extends StatefulWidget {
  const SignupTablet({Key? key}) : super(key: key);

  @override
  SignupTabletState createState() => SignupTabletState();
}

class SignupTabletState extends State<SignupTablet> {
  // input Controllers
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;

  String selectedRole = 'Teacher'; // Default to 'Admin'

  Future<void> registerUser() async {
    try {
      print("role name: $selectedRole");
      final roleId = getRoleId(selectedRole); // Map role name to role ID
      // Use ApiService to register user
      print("role id: $roleId");
      final response = await ApiService.registerUser(
        username: usernameController.text,
        password: passwordController.text,
        email: emailController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        roleID: roleId,
      );

      print(response);

      if (response['statuscode'] == 201) {
        // User registered successfully
        print('User registered successfully');
      } else if (response['statuscode'] == 409) {
        // User or email already exists
        print('User or email already exists');
      } else {
        // Handle registration failure
        print('Registration failed: ${response['message']}');
      }
    } catch (e) {
      // Handle exception
      print('Exception during registration: $e');
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
    emailController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();

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
                      const SizedBox(height: 30),
                      _login(context),
                      const SizedBox(height: 30),
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
          'Create your account',
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
          obscureText: true,
          decoration: InputDecoration(
              hintText: "password",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
              filled: true,
              prefixIcon: const Icon(Icons.account_circle)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
              hintText: "email@gmail.com",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
              filled: true,
              prefixIcon: const Icon(Icons.account_circle)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: "FirstName",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
            filled: true,
            prefixIcon: const Icon(Icons.password_outlined),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: "LastName",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
            filled: true,
            prefixIcon: const Icon(Icons.password_outlined),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: "Phone",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
            filled: true,
            prefixIcon: const Icon(Icons.password_outlined),
          ),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
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
          onPressed: registerUser,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.6),
          ),
          child: const Text(
            "Sign Up",
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

  _login(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            )),
        Expanded(
            child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login", style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 3, 123, 236)))))
      ],
    );
  }
}
