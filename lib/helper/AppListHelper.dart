import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  Future<List<Application>> _apps;
  List<Application> _appList;

  Future<List<Application>> get appsData => _apps;
  List<Application> get appListData => _appList;

  void setStateAuthUrl(List<Application> _newapplist) {
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
  }

  static Future<List<Application>> getListOfApps() async {
    return await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
        includeSystemApps: true);
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
