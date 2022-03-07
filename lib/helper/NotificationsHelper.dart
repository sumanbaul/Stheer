import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

class NotificationsHelper {
  static bool started = false;
  static ReceivePort port = ReceivePort();
  static List<NotificationEvent?>? notificationEvent;

  static Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) => onData(message));

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isR = await (NotificationsListener.isRunning as Future<bool>);
    print("""Service is ${!isR ? "not " : ""}aleary running""");
    //getListOfApps();
    // setState(() {
    //   started = isR;
    // });
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    print(
      "send evt to ui: $evt",
    );
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  static List<NotificationEvent?>? onData(NotificationEvent? event) {
    print("Print Notification: $event");
    notificationEvent!.add(event);
    return notificationEvent;
  }
}
