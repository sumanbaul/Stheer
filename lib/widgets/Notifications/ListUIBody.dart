import 'package:flutter/material.dart';

import 'MakeCard.dart';

class ListUIBody {
  static getListUI() {
    final makeBody = Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return MakeCard.getCard();
        },
      ),
    );

    return makeBody;
  }
}
