// import 'package:device_apps/device_apps.dart';
import 'package:notifoo/src/helper/AppListHelper.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/apps.dart';

class InstalledApps {
  late List<Apps> listOfApps;
  // late List<Application> scannedListOfApplication;
  final AppListHelper appListHelper = new AppListHelper();

  Future<void> getAppsList() async {
    try {
      List<Apps> result = await DatabaseHelper.instance.getInstalledApps();

      if (result != null) {
        listOfApps = result;
        appListHelper
            .setStateAuthUrl(result); // #todo might remove later, need to check
      } else {
        // Scanning disabled due to dependency incompatibility; keep existing DB entries only
        print("Skipping installed apps scan (device_apps disabled)");
      }
    } catch (e) {
      print(e);
    }
  }
}
