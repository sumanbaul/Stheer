import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/helper/InstalledAppsHelper.dart';
import 'package:notifoo/model/Notifications.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class NotificationsList {
  //static ApplicationWithIcon currentApp;

  static getNotificationsList() {
    final notificationsView = FutureBuilder<List<Notifications>>(
      future: DatabaseHelper.instance.getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //var packageName = (Notifications element) => element.packageName;
          //getCurrentApp(packageName.toString());
          // print("Snapshot data: $snapshot.data");
          return StickyGroupedListView<Notifications, String>(
            elements: snapshot.data,
            order: StickyGroupedListOrder.DESC,
            groupBy: (Notifications element) => element.packageName,
            groupComparator: (String value1, String value2) =>
                value2.compareTo(value1),
            itemComparator: (Notifications element1, Notifications element2) =>
                element1.packageName.compareTo(element2.packageName),
            floatingHeader: true,
            groupSeparatorBuilder: (Notifications element) => Container(
              height: 50,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border.all(
                      color: Colors.teal,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${InstalledAppsHelper.getCurrentApp(element.packageName).appName}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            itemBuilder: (_, Notifications element) {
              // getCurrentApp(element.packageName);
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                elevation: 8.0,
                margin:
                    new EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Container(
                  child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      leading:
                          InstalledAppsHelper.getCurrentApp(element.packageName)
                                  is ApplicationWithIcon
                              ? Image.memory(
                                  InstalledAppsHelper.getCurrentAppWithIcon(
                                          element.packageName)
                                      .icon)
                              : null,
                      title: Text(
                          element.title ?? element.packageName.toUpperCase()),
                      subtitle: Text(element.text.toString()),
                      //trailing: Text(element.text.toString()),
                      trailing:
                          //  Text(entry.packageName.toString().split('.').last),
                          Icon(Icons.keyboard_arrow_right),
                      onTap: () => ''
                      // onAppClicked(context,
                      //     InstalledAppsHelper.getCurrentApp(element.packageName)
                      //     ),
                      ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("Oops!");
        }
        return Center(child: CircularProgressIndicator());
      },
    );

    return notificationsView;
  }

  onAppClicked(BuildContext context, Application app) {
    final appName = SnackBar(content: Text(app.appName));
    ScaffoldMessenger.of(context).showSnackBar(appName);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(app.appName),
            actions: <Widget>[
              _AppButtonAction(
                label: 'Open app',
                onPressed: () => app.openApp(),
              ),
              _AppButtonAction(
                label: 'Open app settings',
                onPressed: () => app.openSettingsScreen(),
              ),
            ],
          );
        });
  }
}

class _AppButtonAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  _AppButtonAction({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed?.call();
        Navigator.of(context).maybePop();
      },
      child: Text(label),
    );
  }
}
