import 'package:flutter/material.dart';
import 'package:notifoo/src/widgets/Topbar.dart';

import 'notifications_banner_counter.dart';

class NotificationsBanner extends StatelessWidget {
  final String? notificationBannerTitle;
  final VoidCallback? onClicked;
  final int? notificationCount;

  NotificationsBanner({
    Key? key,
    required this.notificationBannerTitle,
    required this.notificationCount,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: buildBanner(320.0, notificationCount!));
  }

  Widget buildBanner(double height, int nCount) {
    List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];
    List<double> _stopsCircle = [0.0, 0.7];
    Color? gradientStart = Colors.transparent;
    Color? gradientEnd = Colors.black;

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
      height: height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(
                title: notificationBannerTitle,
                onClicked: onClicked,
              ),
              Container(
                height: 148,
                color: Colors.transparent,
                child: Center(
                  child: NotificationsBannerCounter(
                    notificationCount: nCount,
                    colorStops: _stopsCircle,
                    gradient: _colors,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _getbox1,
                    _getbox1,
                    _getbox1,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getbox1 = Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.ac_unit,
          color: Colors.white,
        ),
        Text('amc'),
      ],
    ),
  );
}
