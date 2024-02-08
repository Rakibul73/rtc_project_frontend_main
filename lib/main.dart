import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/DeleteUserScreen.dart';
import 'package:rtc_project_fronend/ForgotPasswordScreen.dart';
import 'package:rtc_project_fronend/HomeDesktop.dart';
import 'package:rtc_project_fronend/IndividualUserScreen.dart';
import 'package:rtc_project_fronend/LoginDesktop.dart';
import 'package:rtc_project_fronend/LoginMobile.dart';
import 'package:rtc_project_fronend/LoginTablet.dart';
import 'package:rtc_project_fronend/ResetPasswordRequest.dart';
import 'package:rtc_project_fronend/SignupDesktop.dart';
import 'package:rtc_project_fronend/SignupMobile.dart';
import 'package:rtc_project_fronend/SignupTablet.dart';
import 'dart:io';

import 'package:rtc_project_fronend/UserScreen.dart';

class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = new PostHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTC WEBSITE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/users': (context) => const UserScreen(), // view all users
        '/individualuser': (context) => const IndividualUserScreen(), // view individual user
        '/deleteuser': (context) => const DeleteUserScreen(), // delete user
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/ResetPasswordScreen': (context) => const ResetPasswordScreen(token: '',),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const HomeDesktop();
          // if (constraints.maxWidth < 600) {
          //   return const HomeMobile();
          // } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
          //   return const HomeTablet();
          // } else {
          //   return const HomeDesktop();
          // }
        },
      ),
    );
  }
}
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const ForgotPasswordDesktop();
          // if (constraints.maxWidth < 600) {
          //   return const HomeMobile();
          // } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
          //   return const HomeTablet();
          // } else {
          //   return const HomeDesktop();
          // }
        },
      ),
    );
  }
}


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const LoginMobile();
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const LoginTablet();
          } else {
            return const LoginDesktop();
          }
        },
      ),
    );
  }
}
class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const SignupMobile();
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const SignupTablet();
          } else {
            return const SignupDesktop();
          }
        },
      ),
    );
  }
}

