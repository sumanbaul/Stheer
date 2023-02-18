import 'package:device_apps/device_apps.dart';

class InstalledAppsHelper {
  //static Future<Application> _apps;
  //create private constructor
  // InstalledAppsHelper() {
  //   getListOfApps();
  // }
  static ApplicationWithIcon? _currentApp;
  static late List<Application> _apps;

  static Future<List<Application>> getListOfApps() async {
    return await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
        includeSystemApps: true);
    //print(_apps);
  }

  static Application? getCurrentApp(String packageName) {
    getListOfApps();
    for (var app in _apps) {
      if (app.packageName == packageName) {
        _currentApp = app as ApplicationWithIcon?;
      }
    }
    return _currentApp;
  }

  static ApplicationWithIcon? getCurrentAppWithIcon(String packageName) {
    getListOfApps();
    for (var app in _apps) {
      if (app.packageName == packageName) {
        _currentApp = app as ApplicationWithIcon?;
      }
    }
    return _currentApp;
  }
}
