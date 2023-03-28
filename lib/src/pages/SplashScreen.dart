import 'dart:collection';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:stheer/src/helper/AppListHelper.dart';
import 'package:stheer/src/model/Notifications.dart';
import 'dart:async';

import 'package:stheer/src/model/apps.dart';
import 'package:stheer/src/services/installedApps.dart';

import '../helper/DatabaseHelper.dart';

Future<List<Application>>? apps;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    //DatabaseHelper.instance.initializeDatabase();
    //apps = AppListHelper.getListOfApps(); //appListHelper.appsData;

    // @override
    //checkIfDataAvaiable();

    super.initState();
    initializeData();
    getAppsData(context);
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (_apps.length > 0) {
  //     appListHelper.setStateAuthUrl(_apps);
  //     Timer(
  //         Duration(seconds: 0),
  //         () => Navigator.of(context).pushNamedAndRemoveUntil(
  //             '/app', (Route<dynamic> route) => false));
  //   } else {
  //     return Center(child: CircularProgressIndicator());
  //   }
  //   return Center(child: CircularProgressIndicator());
  // }

  @override
  Widget build(BuildContext context) {
    //getAppsData(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
      // future: _appsListNew,
      // builder: (context, snapshot) {
      //   if (snapshot.hasData) {
      //     // appListHelper.setStateAuthUrl(snapshot.data);
      //     Timer(
      //         Duration(seconds: 0),
      //         () => Navigator.of(context).pushNamedAndRemoveUntil(
      //             '/app', (Route<dynamic> route) => false));
      //   } else if (snapshot.hasError) {
      //     // return Center(child: Text('Some error occured'));
      //     Future.microtask(() => Navigator.of(context)
      //         .pushNamedAndRemoveUntil(
      //             '/app', (Route<dynamic> route) => false));
      //     //return Center();
      //   }

      // else {
      //   Timer(
      //       Duration(seconds: 0),
      //       () => Navigator.of(context).pushNamedAndRemoveUntil(
      //           '/app', (Route<dynamic> route) => false));
      // }
      //   return Center(
      //     child: Text('Empty'),
      //   );
      // });

      // if (_apps.length > 0) {
      //   Future.microtask(() => Navigator.of(context)
      //       .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false));
      //   return Center();
      // } else {
      //   Center(child: CircularProgressIndicator());
      // }
    );
  }

  Future<List<Notifications>> initializeData() async {
    DatabaseHelper.instance.initializeDatabase();
    var notificationFromDatabase =
        await DatabaseHelper.instance.getNotifications(0);
    return notificationFromDatabase;
  }

  //Get set apps data
  Future<void> getAppsData(BuildContext context) async {
    //InstalledApps _installedApps = new InstalledApps();
    //await _installedApps.getAppsList();
    // _appsListNew = _installedApps.listOfApps;

    //sets app data to singleton object
    //  _appsListNew ?? setAppData(_installedApps.listOfApps);

    Timer(
        Duration(seconds: 2),
        () => Navigator.of(context)
            .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false));

    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false);
    //return _appsListNew;
  }

  loadAndRedirectToApp(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false);
  }

  void setAppData(List<Apps> apps) {
    AppListHelper().setStateAuthUrl(apps);
  }
}
