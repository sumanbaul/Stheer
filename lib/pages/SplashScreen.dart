import 'dart:collection';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'dart:async';

import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/apps.dart';
import 'package:notifoo/services/installedApps.dart';
import 'package:notifoo/widgets/CustomBottomBar/navigator.dart';

Future<List<Application>> apps;
List<Application> _apps = [];
List<Apps> _appsListNew = [];

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    //DatabaseHelper.instance.initializeDatabase();
    apps = AppListHelper.getListOfApps(); //appListHelper.appsData;

    // @override
    //checkIfDataAvaiable();

    super.initState();
    getAppsData();
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

  //Get set apps data
  Future<void> getAppsData() async {
    InstalledApps _installedApps = new InstalledApps();
    await _installedApps.getAppsList();
    _appsListNew = _installedApps.listOfApps;

    //sets app data to singleton object
    setAppData(_installedApps.listOfApps);

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false);
    //return _appsListNew;
  }

  void setAppData(List<Apps> apps) {
    AppListHelper().setStateAuthUrl(apps);
  }
}
