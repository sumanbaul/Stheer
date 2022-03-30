import 'package:flutter/material.dart';

import '../../model/notificationCategory.dart';

class NotificationsCategoryLister extends StatefulWidget {
  NotificationsCategoryLister({Key? key}) : super(key: key);

  @override
  State<NotificationsCategoryLister> createState() =>
      _NotificationsCategoryListerState();
}

class _NotificationsCategoryListerState
    extends State<NotificationsCategoryLister> {
  Future<List<NotificationCategory>>? notificationsByCatFuture;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
