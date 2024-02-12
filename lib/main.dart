import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/environment.dart';
import 'package:rtc_project_fronend/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Environment.init(
    apiBaseUrl: 'https://example.com',
  );

  runApp(const RootApp());
}
