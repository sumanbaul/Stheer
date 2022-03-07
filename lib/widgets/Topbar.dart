import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';

class Topbar extends StatefulWidget {
  Topbar({Key? key, this.title, this.onClicked}) : super(key: key);
  final String? title;
  final VoidCallback? onClicked;
  @override
  _TopbarState createState() => new _TopbarState();
}

class _TopbarState extends State<Topbar> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(left: 7.0),
            // child: IconButton(
            //   icon: Icon(Icons.menu),
            //   onPressed: () => {Scaffold.of(context).openDrawer()},
            // ),
            child: InkWell(
              onTap: widget.onClicked,
              child: Icon(
                Icons.menu,
                size: 24.0,
              ),
            ),
          ),
          Text(
            widget.title!,
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 26,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 7.0),
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
