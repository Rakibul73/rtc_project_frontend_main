import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/root_app.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const RootApp());
}
