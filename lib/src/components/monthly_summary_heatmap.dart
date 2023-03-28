import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:stheer/src/helper/datetime/date_time.dart';

class MonthlySummaryHeatmap extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final String startDate;
  final Function(DateTime?)? heatMapOnClick;

  const MonthlySummaryHeatmap({
    Key? key,
    required this.datasets,
    required this.startDate,
    required this.heatMapOnClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List<Color> _colors = [
      Color.fromARGB(255, 238, 238, 238),
      Color.fromARGB(255, 202, 234, 236)
    ];
    const List<double> _stops = [0.4, 0.99];
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      //margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(15),
        //   bottomRight: Radius.circular(15),
        // ),
        // gradient: LinearGradient(
        //     colors: _colors,
        //     stops: _stops,
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color.fromARGB(57, 145, 159, 165),
        //     blurRadius: 5.0, // soften the shadow
        //     spreadRadius: 0.5, //extend the shadow
        //     offset: Offset(
        //       -5.0, // Move to right 10  horizontally
        //       5.0, // Move to bottom 10 Vertically
        //     ),
        //   ),
        // ],
      ),
      child: HeatMap(
        startDate: createDateTimeObject(startDate)
            .subtract(Duration(days: 45)), //createDateTimeObject(startDate),
        //weekTextColor: Colors.blueGrey,
        colorTipCount: 8,
        colorTipHelper: [
          Text('ssssss'),
        ],
        //initDate: createDateTimeObject(startDate),

        endDate: DateTime.now().add((Duration(days: 0))),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200],
        fontSize: 15,
        colorTipSize: 30,
        borderRadius: 6,
        //margin: EdgeInsets.all(4),
        textColor: Color.fromARGB(255, 27, 16, 82),
        showText: true,
        showColorTip: false,
        // colorTipCount: 10,

        // showText: true,
        scrollable: true,
        size: 30,
        colorsets: const {
          1: Color.fromARGB(19, 2, 170, 179),
          2: Color.fromARGB(40, 2, 170, 179),
          3: Color.fromARGB(60, 2, 170, 179),
          4: Color.fromARGB(80, 2, 170, 179),
          5: Color.fromARGB(100, 2, 170, 179),
          6: Color.fromARGB(120, 2, 170, 179),
          7: Color.fromARGB(150, 2, 170, 179),
          8: Color.fromARGB(180, 2, 170, 179),
          9: Color.fromARGB(220, 2, 170, 179),
          10: Color.fromARGB(255, 2, 170, 179),
        },
        // onClick: (value) {
        //   heatMapOnClick = value;
        //   ScaffoldMessenger.of(context)
        //       .showSnackBar(SnackBar(content: Text(value.toString())));
        // },
        onClick: (value) => heatMapOnClick!(value),
      ),
    );
  }
}
