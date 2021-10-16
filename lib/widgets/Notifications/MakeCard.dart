import 'package:flutter/material.dart';

import 'MakeListTile.dart';

class MakeCard {
  static getCard() {
    final makeCard = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(64, 75, 96, .9),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: MakeListTile.getListTile(),
      ),
    );

    return makeCard;
  }
}
