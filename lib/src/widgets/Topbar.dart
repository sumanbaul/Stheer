import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Topbar extends StatelessWidget {
  const Topbar({Key? key, this.title, this.onClicked}) : super(key: key);
  final String? title;
  final VoidCallback? onClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: InkWell(
              onTap: onClicked,
              child: Icon(
                Icons.menu,
                size: 24.0,
              ),
            ),
          ),
          Text(
            title!,
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 26,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: InkWell(
              onTap: () => {},
              child: Icon(
                Icons.more_vert,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
