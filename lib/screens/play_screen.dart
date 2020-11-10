import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wormz/utilities/constants.dart';
import 'package:wormz/utilities/policyclass.dart';
import 'dart:io';
import 'package:wormz/utilities/score_storage.dart';

enum direction { up, down, left, right, still }

class PlayScreen extends StatefulWidget {
  final ScoreStore storage;

  PlayScreen({@required this.storage});

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _highScore;
  bool newHighScore = false;

  @override
  void initState() {
    super.initState();

    widget.storage.readScore().then((int value) {
      _highScore = value;
    });
  }

  ///Set up Sounds
  // final player = AudioCache();

  ///Set up Screen
  final int blocksPerRow = 24;
  final int blocksPerColumn = 40;
  int timerMilliSecs;

  ///Maths functions
  var duration = Duration(); //speed of wormz refresh.
  final randomGen = Random(); //for placing food randomly

  ///Sets initial worm position for head and next Segment when screen is built
  List<List<int>> wormz = [
    [10, 11],
    [10, 10]
  ];

  /// Set an initial place for food and other vars
  List food = [10, 20];
  var wormzDirection = direction.down;
  String dieReason = '';
  bool isGameRunning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: (IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 32,
                      color: kTextWhtTrans,
                    ),
                    onPressed: () => showInfo(),
                  )),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'W',
                    style: TextStyle(
                        fontSize: 42.0,
                        fontFamily: 'Monofett',
                        color: kOrange,
                        letterSpacing: 1.2),
                  ),
                  Text(
                    'o',
                    style: TextStyle(
                        fontSize: 42.0,
                        fontFamily: 'Monofett',
                        color: kYellowDark,
                        letterSpacing: 1.2),
                  ),
                  Text(
                    'rmz',
                    style: TextStyle(
                        fontSize: 42.0,
                        fontFamily: 'Monofett',
                        color: kYellowLight,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        Expanded(
          child: GestureDetector(
            /// First ignore an attempt to reverse direction then
            /// change direction based on the change in x or y detected
            onHorizontalDragUpdate: (horizontalDrag) {
              if (wormzDirection != direction.left &&
                  horizontalDrag.delta.dx > 0) {
                wormzDirection = direction.right;
              } else if (wormzDirection != direction.right &&
                  horizontalDrag.delta.dx < 0) {
                wormzDirection = direction.left;
              }
            },
            onVerticalDragUpdate: (verticalDrag) {
              if (wormzDirection != direction.up && verticalDrag.delta.dy > 0) {
                wormzDirection = direction.down;
              } else if (wormzDirection != direction.down &&
                  verticalDrag.delta.dy < 0) {
                wormzDirection = direction.up;
              }
            },
            child: AspectRatio(
              aspectRatio: blocksPerRow / (blocksPerColumn),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kYellowLight),
                ),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(), //make sure grid
                  // cannot be scrolled.
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //Sets the number of columns in the grid view to a
                      // defined number.
                      crossAxisCount: blocksPerRow),
                  itemBuilder: (context, index) {
                    ///Set the conditions to draw the grid
                    var containerColour;
                    var x = index % blocksPerRow;

                    var y = (index / blocksPerRow)
                        .floor(); //returns integer of index / blocks per row.

                    ///Check to see if the container to be built is part of
                    ///the wormz body and set bool if yes.
                    bool isWormzTail = false;
                    for (var position in wormz) {
                      //does the container match any of the x,y coords in
                      // wormzBody List
                      if (position[0] == x && position[1] == y) {
                        isWormzTail = true;
                      }
                    }

                    ///--------------------------------------------------------- SET CONTAINER COLOURS
                    ///Check to see if the container to be built is part of
                    ///the wormz body, food or empty and set appropriate colour
                    // Check x,y coords of wormz head.
                    if (!isGameRunning) {
                      containerColour = kGreenDark;
                    } else {
                      if (wormz[0][0] == x && wormz[0][1] == y) {
                        containerColour = kOrange;
                      } else if (wormz[1][0] == x && wormz[1][1] == y) {
                        containerColour = kYellowDark;
                      } else if (isWormzTail) {
                        //set colour of rest of wormz
                        containerColour = kYellowLight;
                        //Set food colour
                      } else if (food[0] == x && food[1] == y) {
                        containerColour = kGreen;
                      } else if (food[0] == -1 && food[1] == -1) {
                        containerColour = kGreenDark;
                      } else {
                        //Set empty containers
                        containerColour = kGreenDark;
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: containerColour,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                    );
                  },
                  itemCount: blocksPerRow * blocksPerColumn,

                  ///total number of
                  /// items to be built = 800 in this case.
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 150.0,
              decoration: BoxDecoration(
                color: !isGameRunning ? kOrange : kYellowLight,
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: FlatButton(
                onPressed: () {
                  HapticFeedback.vibrate();
                  if (!isGameRunning) {
                    startGame();
                  } else {
                    endGame();
                  }
                },
                child: !isGameRunning
                    ? Text(
                        'Start Game',
                        style: TextStyle(color: kTextWht, fontSize: 21.0),
                      )
                    : Text(
                        'End Game',
                        style: TextStyle(color: kGreenDark, fontSize: 22.0),
                      ),
              ),
            ),
            Container(
              width: 150.0,
              child: Text('Score: ${wormz.length - 2}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextWht, fontSize: 22.0)),
            )
          ],
        ),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  ///Start game and timer
  void startGame() {
    timerMilliSecs = 300;
    var duration = Duration(milliseconds: timerMilliSecs);
    wormz.clear();
    wormz = [
      [10, 11],
      [10, 10]
    ];
    wormzDirection = direction.down;
    isGameRunning = true;
    dropFood();

    ///Set up a timer to call move wormz every 300 milliseconds
    Timer.periodic(duration, (Timer timer) {
      if (checkEnd()) {
        timer.cancel();
        endGame();
      } else {
        moveWorm();
      }
    });
  }

  ///End The game
  void endGame() {
    setState(() {
      isGameRunning = false;
      showAlert(context);
    });
  }

  ///Move the wormz in whatever direction is needed
  void moveWorm() {
    ///check direction and move.
    ///To move the wormz we will insert a new Element into the List at
    ///position 0.
    ///If position 0 is a food element we leave the new item there if not we
    ///remove the last element from the wormz body.
    setState(() {
      switch (wormzDirection) {
        case direction.down:
          {
            wormz.insert(0, [wormz.first[0], wormz.first[1] + 1]);
          }
          break;
        case direction.up:
          {
            wormz.insert(0, [wormz.first[0], wormz.first[1] - 1]);
          }
          break;
        case direction.left:
          {
            wormz.insert(0, [wormz.first[0] - 1, wormz.first[1]]);
          }
          break;
        case direction.right:
          {
            wormz.insert(0, [wormz.first[0] + 1, wormz.first[1]]);
          }
          break;
        case direction.still:
          {
            wormz = wormz;
          }
          break;
      }
      if (wormz.first[0] == food[0] && wormz.first[1] == food[1]) {
        playSound(1);
        refreshSpeed();
        dropFood();
      } else {
        wormz.removeLast();
      }
    });
  }

  ///Check for various end conditions and return true if met
  bool checkEnd() {
    bool result = false;

    if (!isGameRunning) {
      result = true;
    }

    /// Check if hits walls
    if (wormz.first[1] < 0 ||
        wormz.first[1] >= blocksPerColumn ||
        wormz.first[0] < 0 ||
        wormz.first[0] > blocksPerRow) {
      playSound(2);
      result = true;
      dieReason = 'wall';
      HapticFeedback.heavyImpact();
    }

    /// Check if eats itself
    /// check all points in wormz execpt head to start from 1 not 0
    for (int i = 1; i < wormz.length; i++) {
      if (wormz.first[0] == wormz[i][0] && wormz.first[1] == wormz[i][1]) {
        playSound(2);
        result = true;
        dieReason = 'self';
        HapticFeedback.vibrate();
      }
    }
    return result;
  }

  ///Randomly drop food when needed
  void dropFood() {
    ///Make food disappear for a bit
    food = [-1, -1];

    ///Set a duration for food to appear
    Future.delayed(Duration(seconds: 2)).then((value) {
      playSound(3);
      int rndX = randomGen.nextInt(blocksPerRow - 2) + 1;
      int rndY = randomGen.nextInt(blocksPerColumn - 2) + 1;
      food = [rndX, rndY];
      HapticFeedback.vibrate();
    });
  }

  ///Speeds up the wormz the more it eats
  void refreshSpeed() {
    if (timerMilliSecs > 10) {
      timerMilliSecs = timerMilliSecs - 10;
    }
    duration = Duration(microseconds: timerMilliSecs);
  }

  void playSound(int soundNum) async {
    final player = AudioCache();
    if (soundNum == 1) {
      player.play('crunch.wav');
    } else if (soundNum == 2) {
      player.play('walk1.wav');
    } else if (soundNum == 3) {
      player.play('ping.wav');
    }
  }

  ///Show Dialog and high score
  void showAlert(BuildContext context) async {
    // Check to see if current score is better than high score
    int currentScore = wormz.length - 2;
    // Check to see if new score is the high score
    if (_highScore < currentScore) {
      newHighScore = true;
      writeHighScore(currentScore);
      _highScore = currentScore;
    } else {
      newHighScore = false;
    }

    String message;
    if (dieReason == 'wall') {
      message = 'You hit the wall';
    } else if (dieReason == 'self') {
      message = 'You ate yourself';
    } else {
      message = '';
    }
    AlertDialog thisAlert = AlertDialog(
      backgroundColor: kGreenDarkest,
      elevation: 0.0,
      title: Container(
        color: kGreenDark,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kOrange,
                      letterSpacing: 1.2),
                ),
                Text(
                  'a',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kYellowDark,
                      letterSpacing: 1.2),
                ),
                Text(
                  'me Over',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kYellowLight,
                      letterSpacing: 1.2),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              message,
              style: TextStyle(color: kTextWht),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              !newHighScore ? 'High Score: $_highScore' : '',
              style: TextStyle(fontSize: 20.0, color: kTextWhtTrans),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Your Score: ${wormz.length - 2}',
              style: TextStyle(fontSize: 20.0, color: kTextWhtTrans),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              newHighScore ? 'NEW HIGH SCORE' : '',
              style: TextStyle(fontSize: 20.0, color: kYellowDark),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
                width: 100.0,
                height: 25.0,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: FlatButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      newHighScore = false;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: kTextWht,
                      ),
                    ))),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => thisAlert);
  }

  ///Gets passed an int that is current length of worm -2.  Checks DB to see if
  ///the saved length is longer and if yes saves it.  when the game first runs
  ///this has the effect of creating the score file if one does not exist
  ///already
  Future<int> checkHighScore(int length) async {
    int validatedHighScore;

    return validatedHighScore;
  }

  Future<File> writeHighScore(int _newScore) async {
    return widget.storage.writeScore(_newScore);
  }

  void showInfo() {
    AlertDialog thisAlert = AlertDialog(
      backgroundColor: kGreenDarkest,
      elevation: 0.0,
      title: Container(
        color: kGreenDark,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'I',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kOrange,
                      letterSpacing: 1.2),
                ),
                Text(
                  'N',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kYellowDark,
                      letterSpacing: 1.2),
                ),
                Text(
                  'FO',
                  style: TextStyle(
                      fontSize: 42.0,
                      fontFamily: 'Monofett',
                      color: kYellowLight,
                      letterSpacing: 1.2),
                ),
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Swipe the screen in the direction you want to go.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextWht),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'High Score: $_highScore',
              style: TextStyle(fontSize: 20.0, color: kTextWhtTrans),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
                width: 100.0,
                height: 25.0,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: FlatButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      Navigator.pop(context);
                    },
                    child: Text('Close',
                        style: TextStyle(
                          color: kTextWht,
                        )))),
            SizedBox(
              height: 30.0,
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text:
                        'By Downloading and using this App you are agreeing to our\n',
                    style: TextStyle(
                      color: kGreyTxt,
                    ),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return PolicyDialog(
                                      mdFileName: 'tc.md',
                                    );
                                  });
                              HapticFeedback.vibrate();
                            },
                          text: 'Terms and Conditions',
                          style: TextStyle(color: kOrange, fontSize: 15.0)),
                      TextSpan(text: ' - & - '),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              HapticFeedback.vibrate();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return PolicyDialog(
                                      mdFileName: 'pp.md',
                                    );
                                  });
                              HapticFeedback.vibrate();
                            },
                          text: 'Privacy Policy\n',
                          style: TextStyle(color: kOrange, fontSize: 15.0)),
                      TextSpan(text: 'Tap above to View')
                    ])),
          ],
        ),
      ),
    );

    showDialog(
        barrierDismissible: true, context: context, builder: (_) => thisAlert);
  }
}
