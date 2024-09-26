import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/home/components/footer.dart';
import 'package:rtc_project_fronend/home/components/header.dart';
import 'package:rtc_project_fronend/home/components/side_menu.dart';
import '../../components/jumbotron.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: const SideMenu(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: size.width,
            constraints: BoxConstraints(minHeight: size.height),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Header(), Jumbotron(), Footer()],
            ),
          ),
        ),
      ),
    );
  }
}
