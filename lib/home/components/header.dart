import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/home/constants.dart';
import 'package:rtc_project_fronend/home/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_item.dart';

final Uri _url = Uri.parse('https://www.pstu.ac.bd');

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/app_logo.png',
            width: 50,
          ),
          const SizedBox(width: 10),
          const Text(
            "PSTU RTC Project Management",
            style: TextStyle(fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (!isMobile(context))
            Row(
              children: [
                NavItem(
                    title: 'Main Website',
                    tapEvent: () async {
                      await launchUrl(_url);
                    }),
                NavItem(
                  title: 'Login',
                  tapEvent: () => GoRouter.of(context).go(RouteUri.login),
                ),
              ],
            ),
          if (isMobile(context))
            IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                })
        ],
      ),
    );
  }
}
