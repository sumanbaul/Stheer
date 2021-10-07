import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:device_apps/device_apps.dart';
import 'package:notifoo/extensions/textFormat.dart';
import 'package:notifoo/model/Notifications.dart';

class NotificationsLog extends StatefulWidget {
  @override
  _NotificationsLogState createState() => _NotificationsLogState();
}

class _NotificationsLogState extends State<NotificationsLog> {
  List<NotificationEvent> _log = [];
  //List<Notifications> _logNotification = [];
  List<Application> _apps;
  ApplicationWithIcon _currentApp;

  bool started = false;
  bool _loading = false;
  String packageName = "";

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    print(
      "send evt to ui: $evt",
    );
    final SendPort send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) => onData(message));

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isR = await NotificationsListener.isRunning;
    print("""Service is ${!isR ? "not " : ""}aleary running""");
    getListOfApps();
    setState(() {
      started = isR;
    });

    //var getData = DatabaseHelper.instance.getNotifications();
  }

  void onData(NotificationEvent event) {
    setState(() {
      // if (!event.packageName.contains("example") ||
      //     !event.packageName.contains("discover") ||
      //     !event.packageName.contains("service")) {
      //   _log.add(event);
      // }

      packageName =
          event.packageName.toString().split('.').last.capitalizeFirstofEach;
      if (event.packageName.contains("skydrive") ||
          (event.packageName.contains("service")) ||
          (event.packageName.contains("android")) ||
          (event.packageName.contains("notifoo")) ||
          (event.packageName.contains("screenshot")) ||
          (event.packageName.contains("gallery"))) {
        //print(event.packageName);
      } else {
        for (var app in _apps) {
          //print(app);
          // print(app.packageName);
          //var x = app;
          if (app.packageName == event.packageName) {
            _currentApp = app;
            print("Success Package Found: " + app.packageName);

            var jsonData = json.decoder.convert(event.toString());
            _log.add(event);
            DatabaseHelper.instance.insertNotification(
              Notifications(
                  title: jsonData["title"],
                  infoText: jsonData["text"],
                  showWhen: 1,
                  subText: jsonData["text"],
                  timestamp: event.timestamp.toString(),
                  package_name: jsonData["package_name"],
                  text: jsonData["text"],
                  summaryText: jsonData["summaryText"] ?? ""),
            );
          }
        }

        // _logNotification.add(jsonData);
        //print("something");

        // DatabaseHelper.instance.insertNotification(_logNotification.last);

        //Map<String, dynamic> datas = jsonDecode(jsonData);
        // print("jsonData['summaryText']:" + jsonData["summaryText"]);
        //print("jsonData['package_name']:" + jsonData["package_name"]);
        //print("jsonData['textLines']:" + jsonData["textLines"]);
        //print("jsonData['summaryText']:" + jsonData["summaryText"]);

        // DatabaseHelper.instance.insertNotification(Notifications(
        //     title: jsonData["title"],
        //     infoText: jsonData["textLines"],
        //     showWhen: int.parse(jsonData["showWhen"]),
        //     subText: jsonData["subtext"],
        //     timestamp: jsonData["timestamp"].toString(),
        //     package_name: jsonData["package_name"],
        //     text: jsonData["text"],
        //     summaryText: jsonData["summaryText"]));

      }
    });
    // if (!event.packageName.contains("example") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("xiaomi")) {
    //   // TODO: fix bug
    //   // NotificationsListener.promoteToForeground("");
    // }
    print("Print Notification: $event");
  }

  void startListening() async {
    print("start listening");
    setState(() {
      _loading = true;
    });
    var hasPermission = await NotificationsListener.hasPermission;
    if (!hasPermission) {
      print("no permission, so open settings");
      NotificationsListener.openPermissionSettings();
      return;
    }

    var isR = await NotificationsListener.isRunning;

    if (!isR) {
      await NotificationsListener.startService(
          title: "Notifoo listening",
          description: "Let's scrape the notifactions...");
    }

    setState(() {
      started = true;
      _loading = false;
    });
  }

  void stopListening() async {
    print("stop listening");

    setState(() {
      _loading = true;
    });

    await NotificationsListener.stopService();

    setState(() {
      started = false;
      _loading = false;
    });
  }

//getting list of apps
  Future<String> getListOfApps() async {
    _apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
        includeSystemApps: true);
    //print(_apps);
  }

  Application getCurrentApp(String packageName) {
    getListOfApps();
    for (var app in _apps) {
      if (app.packageName == packageName) {
        _currentApp = app;
      }
    }
    return _currentApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifoo'),
      ),
      body: FutureBuilder<List<Notifications>>(
        future: DatabaseHelper.instance.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //var packageName = (Notifications element) => element.package_name;
            //getCurrentApp(packageName.toString());
            // print("Snapshot data: $snapshot.data");
            return StickyGroupedListView<Notifications, String>(
              elements: snapshot.data,
              order: StickyGroupedListOrder.DESC,
              groupBy: (Notifications element) => element.package_name,
              groupComparator: (String value1, String value2) =>
                  value2.compareTo(value1),
              itemComparator:
                  (Notifications element1, Notifications element2) =>
                      element1.package_name.compareTo(element2.package_name),
              floatingHeader: true,
              groupSeparatorBuilder: (Notifications element) => Container(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      border: Border.all(
                        color: Colors.blue[300],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${element.package_name.toString().split('.').last.capitalizeFirstofEach}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (_, Notifications element) {
                getCurrentApp(element.package_name);
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
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                      leading: _currentApp is ApplicationWithIcon
                          ? Image.memory(_currentApp.icon)
                          : null,
                      title: Text(element.title ?? packageName),
                      subtitle: Text(element.text.toString()),
                      //trailing: Text(element.text.toString()),
                      trailing:
                          //  Text(entry.packageName.toString().split('.').last),
                          Icon(Icons.keyboard_arrow_right),
                      onTap: () => onAppClicked(context, _currentApp),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: started ? stopListening : startListening,
        tooltip: 'Start/Stop sensing',
        child: _loading
            ? Icon(Icons.close)
            : (started ? Icon(Icons.stop) : Icon(Icons.play_arrow)),
      ),
    );
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
