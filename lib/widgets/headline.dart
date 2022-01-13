import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Headline extends StatelessWidget {
  const Headline({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 30),
      height: 30,
      child: Text(title,
          textAlign: TextAlign.left,
          style: GoogleFonts.barlowSemiCondensed(
            textStyle: TextStyle(
              letterSpacing: 1.5,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Color(0xffe2adc4),
                  offset: Offset(-1.0, 1.0),
                ),
              ],
            ),
          )),
    );
  }
}
