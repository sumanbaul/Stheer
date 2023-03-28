import 'package:device_apps/device_apps.dart';
import 'package:stheer/src/helper/AppListHelper.dart';
import 'package:stheer/src/helper/DatabaseHelper.dart';
import 'package:stheer/src/model/apps.dart';

class InstalledApps {
  late List<Apps> listOfApps;
  late List<Application> scannedListOfApplication;
  final AppListHelper appListHelper = new AppListHelper();

  Future<void> getAppsList() async {
    try {
      List<Apps> result = await DatabaseHelper.instance.getInstalledApps();

      if (result != null) {
        listOfApps = result;
        appListHelper
            .setStateAuthUrl(result); // #todo might remove later, need to check
      } else {
        print("Scanning for installed apps");

        scannedListOfApplication = await AppListHelper.getListOfApps();

        print("Adding apps to database");

        scannedListOfApplication.forEach(
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
            DatabaseHelper.instance.insertDeviceApps(app);
            listOfApps.add(app);
            print('app: $app');
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
