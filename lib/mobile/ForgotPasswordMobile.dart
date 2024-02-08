// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'dart:async';

class ForgotPasswordMobile extends StatefulWidget {
  const ForgotPasswordMobile({Key? key}) : super(key: key);

  @override
  ForgotPasswordMobileState createState() => ForgotPasswordMobileState();
}

class ForgotPasswordMobileState extends State<ForgotPasswordMobile> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoadingResetPassword = false;
  bool _isLoadingSendPasswordToEmail = false;
  // Method to send password to email
  Future<void> _sendPasswordToEmail() async {
    setState(() {
      _isLoadingSendPasswordToEmail = true;
    });
    try {
      // Call the API service to send the password to the email
      await ApiService.sendPasswordToEmail(_emailController.text);
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password sent to ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password to email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingSendPasswordToEmail = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoadingResetPassword = true;
    });
    try {
      // Call the API service to reset the password
      await ApiService.resetPasswordRequest(_emailController.text);
      // Show a success message or navigate to a success screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingResetPassword = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 59, 66, 72),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SizedBox(
                width: 300,
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
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          'Forgot Password ?',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Reset or View Password',
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
          controller: _emailController,
          decoration: InputDecoration(
              hintText: "email@gmail.com",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.3),
              filled: true,
              prefixIcon: const Icon(Icons.account_circle)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoadingResetPassword ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.6),
          ),
          child: _isLoadingResetPassword
              ? const CircularProgressIndicator()
              : const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoadingSendPasswordToEmail ? null : _sendPasswordToEmail,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: const Color.fromARGB(255, 3, 123, 236).withOpacity(0.6),
          ),
          child: _isLoadingSendPasswordToEmail
              ? const CircularProgressIndicator()
              : const Text(
                  "Send Password to Email",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
        )
      ],
    );
  }

  _login(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Remember your password? ", style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromARGB(255, 26, 22, 20))),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("Login", style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 3, 123, 236))))
      ],
    );
  }
}
