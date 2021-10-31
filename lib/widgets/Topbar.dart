import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Topbar {
  static getTopbar(String title) {
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color(0xffeeaeca),
      title: Text(
        title,
        style: GoogleFonts.barlowSemiCondensed(
          fontSize: 24,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );

    return topAppBar;
  }
}
