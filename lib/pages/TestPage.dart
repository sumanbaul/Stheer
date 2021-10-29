import 'package:flutter/material.dart';
import 'package:notifoo/helper/NotificationsHelper.dart';
import 'package:notifoo/widgets/BottomBar.dart';
import 'package:notifoo/widgets/Notifications/ListUIBody.dart';
import 'package:notifoo/widgets/Topbar.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<TestPage> {
  List notifications;

  @override
  void initState() {
    NotificationsHelper.initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: Topbar.getTopbar(widget.title),
      body: ListUIBody.getListUI(),
      bottomNavigationBar: BottomBar.getBottomBar(context),
    );
  }
}

// class NotifyService extends NotificationListener {

//   @override
//   void onNotificationPosted(NotificationListener sbn) {
//     //Log.i("NotifyService", "got notification");
//     print(sbn);
//   }
// }
