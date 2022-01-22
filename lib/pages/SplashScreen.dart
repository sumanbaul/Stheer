import 'dart:collection';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'dart:async';

import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/apps.dart';
import 'package:notifoo/widgets/CustomBottomBar/navigator.dart';

final AppListHelper appListHelper = new AppListHelper();
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
    DatabaseHelper.instance.initializeDatabase();
    //apps = AppListHelper.getListOfApps(); //appListHelper.appsData;

    // @override
    //checkIfDataAvaiable();

    super.initState();
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
    if (_loading) {
      return CircularProgressIndicator();
    } else {
      return FutureBuilder<List<Apps>>(
          future: checkIfDataAvaiable(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // appListHelper.setStateAuthUrl(snapshot.data);
              Timer(
                  Duration(seconds: 0),
                  () => Navigator.of(context).pushNamedAndRemoveUntil(
                      '/app', (Route<dynamic> route) => false));
            } else if (snapshot.hasError) {
              // return Center(child: Text('Some error occured'));
              Future.microtask(() => Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                      '/app', (Route<dynamic> route) => false));
              //return Center();
            }

            // else {
            //   Timer(
            //       Duration(seconds: 0),
            //       () => Navigator.of(context).pushNamedAndRemoveUntil(
            //           '/app', (Route<dynamic> route) => false));
            // }
            return Center(
              child: Text('Empty'),
            );
          });

      // if (_apps.length > 0) {
      //   Future.microtask(() => Navigator.of(context)
      //       .pushNamedAndRemoveUntil('/app', (Route<dynamic> route) => false));
      //   return Center();
      // } else {
      //   Center(child: CircularProgressIndicator());
      // }
    }
  }

  Future<List<Apps>> checkIfDataAvaiable() async {
    List<Apps> result = await DatabaseHelper.instance.getInstalledApps();
//apps = AppListHelper.getListOfApps();
    if (result != null) {
      print("Apps already installed");

      // result.forEach(
      //   (element) {

      //     _apps.add(element.)
      //     _apps.add(element as Application);
      //   },
      // );

      //apps = _apps as Future<List<Application>>;
      // _apps = result as List<Application>;
      appListHelper.setStateAuthUrl(result);
      //super.initState();
      setState(() {
        _loading = false;
      });
    } else {
      _apps = await AppListHelper.getListOfApps();
      print("Adding apps to database");
      //apps = appListHelper.appsData;
      // List<Application> _appList;

      _apps.forEach(
        (element) {
          var app = new Apps(
            appName: element.appName,
            apkFilePath: element.apkFilePath,
            packageName: element.packageName,
            versionName: element.versionName,
            versionCode: element.versionCode.toString(),
            dataDir: element.dataDir,
            //systemApp: int.tryParse(element.systemApp.toString()),
            installTimeMillis: element.installTimeMillis,
            category: element.category.index.toString(),
            //enabled: int.tryParse(element.enabled.toString())
          );
          _appsListNew.add(app);
          print('app: $app');
        },
      );

      try {
        _appsListNew.forEach((element) {
          DatabaseHelper.instance.insertDeviceApps(element);
        });
      } catch (ex) {
        print(ex.toString());
      }
    }

    return result;
  }
}
