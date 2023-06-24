import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/pallete.dart';

class TweetCardIconButton extends StatelessWidget {
  const TweetCardIconButton({
    super.key,
    required this.pathName,
    required this.text,
    required this.ontap,
  });

  final String pathName;
  final String text;
  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        children: [
          SvgPicture.asset(
            pathName,
            colorFilter:
                const ColorFilter.mode(Pallete.greyColor, BlendMode.srcIn),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
