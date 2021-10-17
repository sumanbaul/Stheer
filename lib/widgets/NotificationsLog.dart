import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/AppsList.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:device_apps/device_apps.dart';
import 'package:notifoo/model/Notifications.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/BottomBar.dart';

//Initialize singleton
final AppsList appsList = new AppsList();

class NotificationsLog extends StatefulWidget {
  NotificationsLog({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _NotificationsLogState createState() => _NotificationsLogState();
}

class _NotificationsLogState extends State<NotificationsLog> {
  List<NotificationEvent> _log = [];
  List<Application> _apps = appsList.appListData;
  ApplicationWithIcon _currentApp;

  bool appsLoaded = false;

  String flagEntry;

  bool started = false;
  bool _loading = false;
  String packageName = "";

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();
    DatabaseHelper.instance.initializeDatabase();

    super.initState();
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    // print(
    //   "send evt to ui: $evt",
    // );
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

    setState(() {
      started = isR;
    });

    //var getData = DatabaseHelper.instance.getNotifications();
  }

  void onData(NotificationEvent event) {
    print(event);
    setState(() {
      //packageName = event.packageName.toString().split('.').last.capitalizeFirstofEach;
      if (event.packageName.contains("skydrive") ||
          (event.packageName.contains("service")) ||
          // (event.packageName.contains("android")) ||
          (event.packageName.contains("notifoo")) ||
          (event.packageName.contains("screenshot")) ||
          (event.title.contains("WhatsApp")) ||
          (event.packageName.contains("gallery"))) {
        //print(event.packageName);
      } else {
        for (var app in _apps) {
          //print(app);
          if (app.packageName == event.packageName) {
            _currentApp = app;
            packageName = event.packageName;
            // print("Success Package Found: " + app.packageName);
            //var jsondata2 = json.decode(event.toString());
            Map<String, dynamic> jsonresponse = json.decode(event.toString());

            //var jsonData = json.decoder.convert(event.toString());
            _log.add(event);

            //var xx = jsonresponse.containsKey('summaryText');
            if (!jsonresponse.containsKey('summaryText')) {
              if ((event.title != flagEntry)) {
                DatabaseHelper.instance.insertNotification(
                  Notifications(
                      title: event.title,
                      text: event.text,
                      message: event.message,
                      packageName: event.packageName,
                      timestamp: event.timestamp,
                      createAt: event.createAt.toString(),
                      eventJson: event.toString()
                      // infoText: jsonData["text"],
                      // showWhen: 1,
                      // subText: jsonData["text"],
                      // timestamp: event.timestamp.toString(),
                      // packageName: jsonData["packageName"],
                      // text: jsonData["text"],
                      // summaryText: jsonData["summaryText"] ?? ""
                      ),
                );
              }
              flagEntry = event.title;
            } else {
              // # TODO fix here
              Map<String, dynamic> jsonTitle =
                  json.decode(jsonresponse["textLines"]);
              var titleLength = jsonTitle.length;

              DatabaseHelper.instance.insertNotification(
                Notifications(
                    title: jsonresponse["textLines"][titleLength],
                    text: event.text,
                    message: event.message,
                    packageName: event.packageName,
                    timestamp: event.timestamp,
                    createAt: event.createAt.toString(),
                    eventJson: event.toString()
                    // infoText: jsonData["text"],
                    // showWhen: 1,
                    // subText: jsonData["text"],
                    // timestamp: event.timestamp.toString(),
                    // packageName: jsonData["packageName"],
                    // text: jsonData["text"],
                    // summaryText: jsonData["summaryText"] ?? ""
                    ),
              );
            }
          }
        }
      }
    });
    // if (!event.packageName.contains("example") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("xiaomi")) {
    //   // TODO: fix bug
    //   // NotificationsListener.promoteToForeground("");
    // }
    // print("Print Notification: $event");
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

  Application getCurrentApp(String packageName) {
    // getListOfApps().whenComplete(() => _apps);
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
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: Topbar.getTopbar(widget.title),
      bottomNavigationBar: BottomBar.getBottomBar(context),
      body: getNotificationListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: started ? stopListening : startListening,
        tooltip: 'Start/Stop sensing',
        child: _loading
            ? Icon(Icons.close)
            : (started ? Icon(Icons.close) : Icon(Icons.play_arrow)),
      ),
    );
  }

  getNotificationListBody() {
    return FutureBuilder<List<Notifications>>(
      future: DatabaseHelper.instance.getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //var packageName = (Notifications element) => element.packageName;

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
                      '${getCurrentApp(element.packageName).appName}',
                      // '${element.packageName}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            itemBuilder: (_, Notifications element) {
              if (element != null) {
                getCurrentApp(element.packageName);
                //print('Current App: ' +
                // getCurrentApp(element.packageName).appName);

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

                      leading: _currentApp is ApplicationWithIcon
                          ? Image.memory(_currentApp.icon)
                          : null,
                      title: Text(element.title ?? packageName),
                      subtitle: Text(element.text.toString()),

                      //isThreeLine: true,
                      //trailing: Text(element.text.toString()),
                      trailing:
                          //  Text(entry.packageName.toString().split('.').last),
                          Icon(Icons.keyboard_arrow_right),
                      onTap: () => onAppClicked(
                          context, getCurrentApp(element.packageName)),
                    ),
                  ),
                );
              } else {
                return Center(child: Text('Nothing to Display!'));
              }
              // getCurrentApp(element.packageName);
            },
          );
        } else if (snapshot.hasError) {
          //return Center(child: Text("Oops!"));
          return Center(child: CircularProgressIndicator());
        }
        return Center(child: CircularProgressIndicator());
      },
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
              AppButtonAction(
                label: 'Open app',
                onPressed: () => app.openApp(),
              ),
              AppButtonAction(
                label: 'Open app settings',
                onPressed: () => app.openSettingsScreen(),
              ),
            ],
          );
        });
  }
}

class AppButtonAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  AppButtonAction({this.label, this.onPressed});

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
