import 'package:flutter/material.dart';

import '../theme/pallete.dart';

class RoundedSmallButton extends StatelessWidget {
  const RoundedSmallButton({
    super.key,
    this.bgColor = Pallete.whiteColor,
    this.textColor = Pallete.backgroundColor,
    required this.labeltext,
    required this.onTap,
  });

  final String labeltext;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const StadiumBorder(),
        backgroundColor: bgColor,
        label: Text(
          labeltext,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}
