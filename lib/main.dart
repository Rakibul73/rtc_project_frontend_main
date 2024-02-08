import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/desktop/DeleteUserScreenDesktop.dart';
import 'package:rtc_project_fronend/desktop/ForgotPasswordDesktop.dart';
import 'package:rtc_project_fronend/desktop/HomeDesktop.dart';
import 'package:rtc_project_fronend/desktop/IndividualUserScreenDesktop.dart';
import 'package:rtc_project_fronend/desktop/LoginDesktop.dart';
import 'package:rtc_project_fronend/mobile/ForgotPasswordMobile.dart';
import 'package:rtc_project_fronend/mobile/LoginMobile.dart';
import 'package:rtc_project_fronend/tablet/ForgotPasswordTablet.dart';
import 'package:rtc_project_fronend/tablet/LoginTablet.dart';
import 'package:rtc_project_fronend/desktop/ResetPasswordScreenDesktop.dart';
import 'package:rtc_project_fronend/desktop/SignupDesktop.dart';
import 'package:rtc_project_fronend/mobile/SignupMobile.dart';
import 'package:rtc_project_fronend/tablet/SignupTablet.dart';
import 'dart:io';

import 'package:rtc_project_fronend/desktop/UserScreenDesktop.dart';

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
        '/ResetPasswordScreen': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const ResetPasswordScreenDesktop(token: '',);
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
class DeleteUserScreen extends StatelessWidget {
  const DeleteUserScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const DeleteUserScreenDesktop();
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
class IndividualUserScreen extends StatelessWidget {
  const IndividualUserScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const IndividualUserScreenDesktop();
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
class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const UserScreenDesktop();
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
          if (constraints.maxWidth < 600) {
            return const ForgotPasswordMobile();
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const ForgotPasswordTablet();
          } else {
            return const ForgotPasswordDesktop();
          }
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

