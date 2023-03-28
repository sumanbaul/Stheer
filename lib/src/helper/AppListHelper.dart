import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:stheer/src/helper/DatabaseHelper.dart';
import 'dart:async';

import 'package:stheer/src/model/apps.dart';

// class AppsList {
//   static List<Application> _apps;

//   static Future<List<Application>> getListOfApps() async {
//     _apps = await DeviceApps.getInstalledApplications(
//         onlyAppsWithLaunchIntent: true,
//         includeAppIcons: true,
//         includeSystemApps: true);
//     return _apps;
//   }
// }

abstract class AppsListBase {
  @protected
  Future<List<Application>>? _apps;

  Future<List<Apps>>? _appsFromDB;
  List<Apps>? _appList;

  // Future<List<Application>> get appsData => _apps;
  // Future<List<Apps>> get appsDataFromDB => _appsFromDB;
  List<Apps>? get appListData => _appList;

  void setStateAuthUrl(List<Apps> _newapplist) {
    //_apps = _appsList;
    _appList = _newapplist;
  }
}

class AppListHelper extends AppsListBase {
  static final AppListHelper _instance = AppListHelper._internal();
  factory AppListHelper() {
    return _instance;
  }

  AppListHelper._internal() {
    //default fallback
    _apps = getListOfApps();
    _appsFromDB = getApps();
  }

  static Future<List<Application>> getListOfApps() async {
    return await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
        includeSystemApps: true);
  }

  static Future<List<Apps>> getApps() async {
    return DatabaseHelper.instance.getInstalledApps();
  }

  // Future<List<Application>> toList() {
  //   List<Application> result = <Application>[];
  //   _Future<List<Application>> future = new _Future<List<Application>>();
  //   this.listen(
  //       (Application data) {
  //         result.add(data);
  //       },
  //       onError: future._completeError,
  //       onDone: () {
  //         future._complete(result);
  //       },
  //       cancelOnError: true);
  //   return future;
  // }
}
