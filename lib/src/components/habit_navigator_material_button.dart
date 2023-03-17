import 'package:flutter/material.dart';

class HabitNavigatorMaterialButton extends StatelessWidget {
  final Function()? materialButtonOnPressed;
  final Icon materialButtonIcon;
  final String materialButtonText;
  const HabitNavigatorMaterialButton(
      {Key? key,
      required this.materialButtonOnPressed,
      required this.materialButtonIcon,
      required this.materialButtonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      hoverColor: Colors.amber,
      visualDensity: VisualDensity.compact,
      onPressed: materialButtonOnPressed, //navigateToData(false),
      child: materialButtonText == ""
          ? materialButtonIcon
          : Text(materialButtonText),
      elevation: 5,
      minWidth: 15,
      textColor: Color.fromARGB(255, 65, 56, 88),
    );
  }
}
