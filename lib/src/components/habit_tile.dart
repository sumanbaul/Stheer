import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext?)? settingsTapped;
  final Function(BuildContext?)? deleteTapped;
  final Color? habitBgColor;
  final Function(BuildContext?, bool?)? habitsTapped;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
    required this.habitsTapped,
    required this.habitBgColor,
    //required this.habitCompletedColor,
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
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: habitBgColor,
              //habitCompleted ? habitCompleteAnimation.value : Colors.white,
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
                      activeColor: Color.fromARGB(255, 45, 101, 110),
                      side: BorderSide(
                        color: habitCompleted
                            ? Color.fromARGB(255, 64, 43, 141)
                            : Color.fromARGB(255, 230, 175, 182),
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
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                habitCompleted
                                    ? 'Completed!'.toUpperCase()
                                    : 'Tap to complete'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FaIcon(
                        FontAwesomeIcons.fire,
                        color: habitCompleted
                            ? Color.fromARGB(197, 219, 56, 27)
                            : Colors.grey[300],
                        size: 25,
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_rounded,
                      color: habitCompleted
                          ? Color.fromARGB(255, 45, 101, 110)
                          : Colors.grey[400],
                    ),
                  ],
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
                //child:
              ),
            ),
          ),

          // align the confetti on the screen
          // Align(
          //   alignment: Alignment.center,
          //   child: ConfettiWidget(
          //     blastDirectionality: BlastDirectionality.directional,
          //     particleDrag: 0.3,

          //     confettiController: confettiController,
          //     blastDirection: pi,
          //     maxBlastForce: 2,
          //     minBlastForce: 1,
          //     emissionFrequency: 0.03,

          //     // 10 paticles will pop-up at a time
          //     numberOfParticles: 10,

          //     // particles will pop-up
          //     gravity: 0.2,
          //   ),
          // ),
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
