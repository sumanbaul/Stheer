import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubHeader extends StatelessWidget {
  const SubHeader({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 15.0),
      child: Center(
        child: Text(
          title!,
          style: GoogleFonts.barlowSemiCondensed(
            textStyle: TextStyle(
              letterSpacing: 1.5,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
