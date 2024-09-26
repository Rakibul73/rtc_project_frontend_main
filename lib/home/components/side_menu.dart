import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_item.dart';

final Uri _url = Uri.parse('https://www.pstu.ac.bd');

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              NavItem(
                  title: 'Main Website',
                  tapEvent: () async {
                    await launchUrl(_url);
                  }),
              const SizedBox(height: 10),
              NavItem(
                title: 'Login',
                tapEvent: () => GoRouter.of(context).go(RouteUri.login),
              ),
              const SizedBox(height: 10),
              NavItem(
                title: 'Register',
                tapEvent: () => GoRouter.of(context).go(RouteUri.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
