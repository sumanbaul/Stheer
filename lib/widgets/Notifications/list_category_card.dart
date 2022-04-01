import 'package:flutter/material.dart';
import '../../model/notificationCategory.dart';
import 'list_detail.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard(
      {Key? key, this.index, this.notificationsCategoryList})
      : super(key: key);
  final int? index;
  final List<NotificationCategory>? notificationsCategoryList;

  buildNotificationCard(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
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
                              CircleAvatar(
                                radius: 25.0,
                                child:
                                    notificationsCategoryList![index].appIcon,
                                // backgroundImage:
                                //     notificationsCategoryList[index]
                                //         .appIcon
                                //         .image,
                                //backgroundImage: _nc[index].appIcon,
                                //child: _nc[index].appIcon,
                                // child: ClipRRect(
                                //   child: _nc[index].appIcon,
                                //   borderRadius: BorderRadius.circular(100.0),
                                // ),
                                backgroundColor: Colors.black12,
                              ),
                              // ClipOval(
                              //   child: Image(
                              //     image: _nc[index].appIcon.image,
                              //     fit: BoxFit.cover,
                              //     width: 50.0,
                              //     height: 50.0,
                              //     gaplessPlayback: true,
                              //     alignment: Alignment.center,
                              //   ),
                              // ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notificationsCategoryList![index].appTitle!,
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
                              notificationsCategoryList![index].message!,
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              notificationsCategoryList![index].timestamp!,
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
                            packageName:
                                notificationsCategoryList![index].packageName,
                            title: notificationsCategoryList![index].appTitle,
                            //appIcon: notificationsCategoryList![index].appIcon,
                            appTitle:
                                notificationsCategoryList![index].appTitle,
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
    return buildNotificationCard(context, this.index!);
  }
}
