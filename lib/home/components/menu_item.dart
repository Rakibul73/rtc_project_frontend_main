import 'package:flutter/material.dart';

import '../constants.dart';

class NavItem extends StatelessWidget {
  const NavItem({Key? key, required this.title, required this.tapEvent, this.style}) : super(key: key);

  final String title;
  final GestureTapCallback tapEvent;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tapEvent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          title,
          style: style ?? const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
