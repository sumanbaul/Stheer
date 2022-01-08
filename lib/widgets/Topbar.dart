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

    final newTopBar = Container(
      height: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(left: 7.0),
            child: Icon(Icons.menu),
          ),
          Text(
            title,
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 26,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 7.0),
            child: Icon(Icons.menu_open),
          ),
        ],
      ),
    );

    return newTopBar;
  }
}
