import 'package:flutter/material.dart';

class HabitListerWidget extends StatefulWidget {
  HabitListerWidget({Key? key}) : super(key: key);

  @override
  State<HabitListerWidget> createState() => _HabitListerWidgetState();
}

class _HabitListerWidgetState extends State<HabitListerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(itemBuilder: _buildHabitItem));
  }

  Widget _buildHabitItem(BuildContext context, int index) {
    return Container(
      child: Text('Something'),
    );
  }
}
