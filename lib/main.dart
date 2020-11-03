import 'package:flutter/material.dart';
import 'package:wormz/screens/play_screen.dart';
import 'package:wormz/utilities/constants.dart';
import 'package:wormz/utilities/score_storage.dart';

void main() => runApp(Wormz());

class Wormz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: kTextWht, canvasColor: kTextWht, accentColor: kOrange),
      home: Scaffold(
        backgroundColor: kGreenDarkest,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: PlayScreen(
              storage: ScoreStore(),
            ),
          ),
        ),
      ),
    );
  }
}
