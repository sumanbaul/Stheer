import 'package:flutter/material.dart';
import 'package:notifoo/src/helper/datetime_ago.dart';

import '../../../src/model/notificationCategory.dart';
import 'list_detail.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard(
      {Key? key,
      this.index,
      required this.notificationsCategory,
      this.notification})
      : super(key: key);
  final int? index;
  final NotificationCategory? notificationsCategory;
  final Notification? notification;

  buildNotificationCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 5),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Card(
        elevation: 0.0,
        margin: EdgeInsets.only(top: 0.0),
        color: Colors.transparent,
        child: Stack(children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //  margin: EdgeInsets.only(bottom: 10),
                height: 100,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(59, 66, 84, 1),
                        Color.fromRGBO(41, 47, 61, 1)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    //color: Color.fromRGBO(40, 48, 59, 1),
                    // color: Color.fromRGBO(58, 66, 86, 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(84, 98, 117, 1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(-3, -3)),
                      BoxShadow(
                          color: Color.fromRGBO(40, 48, 59, 1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(3, 3)),
                    ]),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // ClipOval(
                              //   child: notificationsCategory!.appIcon,
                              // ),
                              CircleAvatar(
                                radius: 25.0,
                                child: notificationsCategory!.appIcon,
                                backgroundColor: Colors.black12,
                              ),

                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notificationsCategory!.appTitle!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    'Tap to view details',
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(196, 196, 196, 1)),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_right)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              notificationsCategory!.message!,
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              notificationsCategory!.timestamp.toString(),
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          new Positioned.fill(
              child: new Material(
                  type: MaterialType.transparency,
                  color: Colors.transparent,
                  child: new InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => {
                      print('tapped'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailList(
                            packageName: notificationsCategory!.packageName,
                            title: notificationsCategory!.appTitle,
                            appIcon: notificationsCategory!.appIcon,
                            appTitle: notificationsCategory!.appTitle,
                            notification: notification,
                          ),
                        ),
                      ),
                    },
                  )))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildNotificationCard(context);
  }
}
