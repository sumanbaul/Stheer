import 'package:flutter/material.dart';

import '../habit_card_menu_item.dart';

class HabitCardMenuItems {
  static const List<HabitCardMenuItem> habitMenu = [
    itemEdit,
    itemDelete,
  ];

  static const List<HabitCardMenuItem> habitMore = [
    itemMore,
  ];

  static const itemEdit = HabitCardMenuItem(
    text: 'Edit',
    icon: Icons.edit_rounded,
  );
  static const itemDelete = HabitCardMenuItem(
    text: 'Delete',
    icon: Icons.delete,
  );
  static const itemMore = HabitCardMenuItem(
    text: 'More',
    icon: Icons.monitor_heart,
  );
}
