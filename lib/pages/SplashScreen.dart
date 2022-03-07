import 'dart:collection';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'dart:async';

import 'package:notifoo/model/apps.dart';
import 'package:notifoo/services/installedApps.dart';

Future<List<Application>>? apps;
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
    //apps = AppListHelper.getListOfApps(); //appListHelper.appsData;

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

  //Get set apps data
  Future<void> getAppsData() async {
    InstalledApps _installedApps = new InstalledApps();
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
