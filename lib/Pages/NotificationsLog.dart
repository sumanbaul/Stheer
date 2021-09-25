import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';

class NotificationsLog extends StatefulWidget {
  @override
  _NotificationsLogState createState() => _NotificationsLogState();
}

class _NotificationsLogState extends State<NotificationsLog> {
  List<NotificationEvent> _log = [];
  bool started = false;
  bool _loading = false;

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    print("send evt to ui: $evt");
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
  }

  void onData(NotificationEvent event) {
    setState(() {
      // if (!event.packageName.contains("example") ||
      //     !event.packageName.contains("discover") ||
      //     !event.packageName.contains("service")) {
      //   _log.add(event);
      // }

      if (event.packageName.contains("skydrive") ||
          (event.packageName.contains("service"))) {
        print(event.packageName);
      } else {
        _log.add(event);
      }
    });
    // if (!event.packageName.contains("example") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("xiaomi")) {
    //   // TODO: fix bug
    //   // NotificationsListener.promoteToForeground("");
    // }
    print(event.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifoo'),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: _log.length,
              reverse: true,
              itemBuilder: (BuildContext context, int idx) {
                final entry = _log[idx];
                return Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: const Offset(
                          2.0,
                          2.0,
                        ),
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                  ),
                  padding: EdgeInsets.all(5.0),
                  child: ListTile(
                    trailing:
                        Text(entry.packageName.toString().split('.').last),
                    //Text(entry.packageName.toString()),
                    title: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.title ?? "<<no title>>"),
                          // Text(entry.text.toString()),
                          //Text(entry.message.toString() ?? ""),
                          //Text(entry.timestamp.toString())
                        ],
                      ),
                    ),
                    //subtitle: Text(entry.createAt.toString().substring(0, 11)),
                    subtitle: Text(entry.text.toString()),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: started ? stopListening : startListening,
        tooltip: 'Start/Stop sensing',
        child: _loading
            ? Icon(Icons.close)
            : (started ? Icon(Icons.stop) : Icon(Icons.play_arrow)),
      ),
    );
  }
}
