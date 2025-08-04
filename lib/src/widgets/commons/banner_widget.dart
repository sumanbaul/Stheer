import 'package:flutter/material.dart';

class CommonBannerWidget extends StatelessWidget {
  CommonBannerWidget({Key? key, this.title, this.onClicked}) : super(key: key);

  final String? title;
  final VoidCallback? onClicked;
  final List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildBanner(11.2, "1"),
    );
  }

  Widget buildBanner(double height, String nCount) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          boxShadow: [
            //color: Colors.white, //background color of box
            BoxShadow(
              color: Colors.black38,
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 3.0, //extend the shadow
              offset: Offset(
                5.0, // Move to right 10  horizontally
                5.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          gradient: LinearGradient(
            colors: _colors,

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            //stops: _stops
          ),
          color: Colors.orange,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          )),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
      height: height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topbar(
              //   title: "Notifoo",
              //   onClicked: widget.onClicked,
              // ),
              Container(
                height: 148,
                color: Colors.transparent,
                // padding: EdgeInsets.only(
                //   left: 15,
                //   right: 15,
                //   bottom: 20,
                // ),
                child: Center(child: Text('11') //_getReadNotifications(nCount),
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // _getbox1,
                    // _getbox1,
                    // _getbox1,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
