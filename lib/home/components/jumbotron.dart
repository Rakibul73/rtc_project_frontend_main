import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/home/components/main_button.dart';
import 'package:rtc_project_fronend/home/responsive.dart';

import '../constants.dart';

class Jumbotron extends StatelessWidget {
  const Jumbotron({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(right: !isMobile(context) ? 40 : 0),
              child: Column(
                mainAxisAlignment: !isMobile(context) ? MainAxisAlignment.start : MainAxisAlignment.center,
                crossAxisAlignment: !isMobile(context) ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: <Widget>[
                  if (isMobile(context))
                    Image.asset(
                      'assets/images/app_logo_2.png',
                      height: size.height * 0.3,
                    ),
                  RichText(
                      textAlign: !isMobile(context) ? TextAlign.start : TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(text: 'Welcome To\n', style: TextStyle(fontSize: isDesktop(context) ? 40 : 20, fontWeight: FontWeight.w800, color: kTextColor)),
                        TextSpan(text: 'RTC', style: TextStyle(fontSize: isDesktop(context) ? 64 : 32, fontWeight: FontWeight.w800, color: kPrimaryColor)),
                      ])),
                  Text(
                    'Project Management System',
                    textAlign: !isMobile(context) ? TextAlign.start : TextAlign.center,
                    style: TextStyle(fontSize: isDesktop(context) ? 40 : 20, fontWeight: FontWeight.w800, color: kTextColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'With the goal of improving research and training initiatives at PSTU, the "PSTU RTC Project Management" is a ground-breaking project that has a following features. Administrators have full authority over the system, including monitoring, modifying, and managing research projects, while researchers can submit, manage, and update their project ideas. The Reviewer Panel, which enables designated reviewers to assess and offer input on research project proposals, is one of this system\'s key components.',
                    textAlign: TextAlign.justify,
                    // textAlign: isMobile(context) ? TextAlign.center : TextAlign.justify,
                    style: TextStyle(fontSize: isDesktop(context) ? 16 : 16, fontWeight: FontWeight.w300, color: kTextColor),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      MainButton(
                        title: 'GET STARTED',
                        color: kPrimaryColor,
                        tapEvent: () => GoRouter.of(context).go(RouteUri.register),
                        // style: const TextStyle(color: Color(0xFF343A40), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      MainButton(
                        title: 'Login',
                        color: kSecondaryColor,
                        tapEvent: () => GoRouter.of(context).go(RouteUri.login),
                      )
                    ],
                  )
                ],
              ),
            )),
            if (isDesktop(context) || isTab(context))
              Expanded(
                  child: Image.asset(
                'assets/images/app_logo_2.png',
                height: size.height * 0.7,
              ))
          ],
        ));
  }
}
