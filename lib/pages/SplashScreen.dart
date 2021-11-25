import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'dart:async';

final AppListHelper appListHelper = new AppListHelper();
Future<List<Application>> apps;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    apps = appListHelper.appsData;
    // Timer(
    //     Duration(seconds: 3),
    //     () => Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (context) => NotificationsLog())));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Application>>(
        future: apps,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            appListHelper.setStateAuthUrl(snapshot.data);
            Timer(
                Duration(seconds: 0),
                () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/app', (Route<dynamic> route) => false));
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => NotificationsLog(title: 'Notifoo'),
            //   ),
            // );
            //return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  //   Container(
  //       color: Colors.white,
  //       child: FlutterLogo(size: MediaQuery.of(context).size.height));
  // }
}
