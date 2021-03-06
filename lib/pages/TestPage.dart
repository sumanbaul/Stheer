import 'package:flutter/material.dart';

import '../widgets/Notifications/notifications_list_widget.dart';

class TestPage extends StatefulWidget {
  TestPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<TestPage> {
  List? notifications;

  @override
  void initState() {
    //NotificationsHelper.initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      //appBar: Topbar.getTopbar(widget.title),
      body: NotificationsListWidget(),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
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
