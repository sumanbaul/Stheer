import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:confetti/confetti.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext?)? settingsTapped;
  final Function(BuildContext?)? deleteTapped;
  final Function(BuildContext?, bool?)? habitsTapped;
  final ConfettiController confettiController;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
    required this.habitsTapped,
    required this.confettiController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //settings option
            SlidableAction(
              onPressed: settingsTapped,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(12),
            ),

            //delete option
            SlidableAction(
              onPressed: deleteTapped,
              backgroundColor: Colors.red.shade400,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Stack(children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //checkbox
                    Checkbox(
                      value: habitCompleted,
                      onChanged: (bool? newValue) =>
                          habitsTapped!(context, newValue),
                      //shape: OutlinedBorder.lerp(a, b, t),
                      activeColor: Color.fromARGB(255, 89, 208, 230),
                      side: BorderSide(
                        color: Color.fromARGB(255, 230, 175, 182),
                        style: BorderStyle.solid,
                        strokeAlign: StrokeAlign.center,
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //habit name
                          Text(
                            habitName,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'other details',
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey[400],
                )
              ],
            ),
          ),
          new Positioned.fill(
            child: new Material(
              type: MaterialType.transparency,
              color: Colors.transparent,
              child: new InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => habitsTapped!(context, !habitCompleted),
                splashColor: Color.fromARGB(48, 153, 97, 218),
              ),
            ),
          ),

          // align the confetti on the screen
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              //blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 1,
              emissionFrequency: 0.03,

              // 10 paticles will pop-up at a time
              numberOfParticles: 10,

              // particles will pop-up
              gravity: 0,
            ),
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: TextButton(
          //       onPressed: () {
          //         // invoking confettiController to come into play
          //         confettiController.play();
          //       },
          //       child: Text('Center',
          //           style: const TextStyle(color: Colors.white, fontSize: 20))),
          // ),
        ]),
      ),
    );
  }
}
