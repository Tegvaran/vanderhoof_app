import 'package:flutter/material.dart';

import 'cards.dart';

class Hike extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        HikeCard("Poo Poo Hike", 1.4, "Hard", 45, "Accessible"),
        HikeCard("Big Brain Hike", 2, "Medium", 35, "Not Accessible"),
        HikeCard("DaBaby Type Beat", 420, "Easy", 2, "Accessible")
      ],
    );
  }
}
