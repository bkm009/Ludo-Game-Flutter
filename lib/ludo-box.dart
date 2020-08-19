import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/flame_audio.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:logger/logger.dart';
import 'package:ludo_diamond/board/drawing.dart';
import 'package:ludo_diamond/board/movements.dart';
import 'package:ludo_diamond/components/controller.dart';
import 'package:ludo_diamond/components/dice.dart';
import 'package:ludo_diamond/components/judge.dart';
import 'package:ludo_diamond/components/player.dart';
import 'package:ludo_diamond/helpers/websocket_handler.dart';
import 'package:ludo_diamond/main.dart';

import 'helpers/customWidgets.dart';

double boxWidth = 25.0;
double boxHeight = 25.0;
double horizontalGrid, verticalGrid;
FlameAudio audioPlayer = new FlameAudio();

Color colorRED = Color.fromRGBO(229, 46, 39, 1.0);
Color colorGREEN = Color.fromRGBO(16, 122, 62, 1.0);
Color colorBLUE = Color.fromRGBO(26, 118, 186, 1.0);
Color colorYELLOW = Color.fromRGBO(254, 192, 18, 1.0);

Color colorREDBoard = Color.fromRGBO(229, 46, 39, 1.0);
Color colorGREENBoard = Color.fromRGBO(16, 122, 62, 1.0);
Color colorBLUEBoard = Color.fromRGBO(26, 118, 186, 1.0);
Color colorYELLOWBoard = Color.fromRGBO(254, 192, 18, 1.0);

class LudoBox extends Game {
  TapGestureRecognizer tapper;
  List<Timer> allTimers = [];

  double leftPad, topPad;
  int numberOfPlayers = 2;
  Map<dynamic, dynamic> playerDetails = {};

  Size screenSize;
  Sprite background;
  bool gameStarted = true;
  bool gameStartBannerVisible = true, bannerTimeOutCalled = false;
  List<String> audioPlayerIds = [];
  bool gameFinished = false;
  Logger log;

  DrawBoard painter;
  Dice dice;
  JudgeSystem judge;
  GameController controller;
  CustomWebSocket channelLayer;
  List<Players> players = [null, null, null, null];
  var playersInCell = {};
  var gameProperties = {
    "gameMode": "OFFLINE",
    "numberOfPlayers": 2,
  };

  LudoBox() {
    this.clearTimers();
    this.allTimers = [];

    // Registering Tap Gesture
    this.tapper = TapGestureRecognizer();
    this.tapper.onTapUp = this.onTapUp;
    flameUtil.addGestureRecognizer(tapper);

    this.log = new Logger();
  }

  void resetGame({
    int noOfPlayers = 2,
    Map<dynamic, dynamic> details,
    String gameMode = "OFFLINE",
    bool isPrivateTable = false,
    int tableId,
    bool createTable = false,
    bool joinTable = false,
  }) {
    this.numberOfPlayers = noOfPlayers;
    this.playerDetails = details;
    this.gameFinished = false;
    gameProperties = {
      'gameMode': gameMode,
      'numberOfPlayers': noOfPlayers,
      'isPrivateTable': isPrivateTable,
      'tableId': tableId,
    };

    players = [null, null, null, null];
    playersInCell = {};
    gameStartBannerVisible = true;
    bannerTimeOutCalled = false;
    gameStarted = true;

    if (gameMode != null && gameMode == "ONLINE") {
      this.channelLayer = new CustomWebSocket(this, tableId);
      this.gameStarted = false;
      this.gameStartBannerVisible = false;
    }

    if (this.playerDetails == null || this.playerDetails.length == 0) {
      if (this.numberOfPlayers == 2) {
        this.playerDetails = {
          0: [0, "Player 1"],
          1: [2, "Player 2"],
        };
      } else if (this.numberOfPlayers == 3) {
        this.playerDetails = {
          0: [0, "Player 1"],
          1: [1, "Player 2"],
          2: [2, "player 3"],
        };
      }
      if (this.numberOfPlayers == 4) {
        this.playerDetails[3] = [3, "Player 4"];
      }
    }

    initialize(createTable: createTable, joinTable: joinTable);
  }

  void initialize({createTable = false, joinTable = false}) async {
    resize(await Flame.util.initialDimensions());

    dice = new Dice(this);
    judge = new JudgeSystem(this);
    controller = new GameController(this);
    painter = new DrawBoard(this);

    for (int i = 0; i < this.numberOfPlayers; i++) {
      this.players[i] = new Players(
        this,
        playerId: i,
        colorId: this.playerDetails[i][0],
        playerName: this.playerDetails[i][1],
      );
    }

//    if (this.numberOfPlayers == 2) {
//      players[0] = new Players(this,
//          playerId: 0, colorId: 0, playerName: "Player 1"); // Blue - 0
//      players[1] = new Players(this,
//          playerId: 1, colorId: 2, playerName: "Player 2"); // Red - 1
//    } else if (this.numberOfPlayers >= 3) {
//      players[0] = new Players(this,
//          playerId: 0, colorId: 0, playerName: "Player 1"); // Blue - 0
//      players[1] = new Players(this,
//          playerId: 1, colorId: 1, playerName: "Player 2"); // Red - 1
//      players[2] = new Players(this,
//          playerId: 2, colorId: 2, playerName: "Player 3"); // Green - 2
//    }
//    if (this.numberOfPlayers > 3) {
//      players[3] = new Players(
//        this,
//        playerId: 3,
//        colorId: 3,
//        playerName: "Player 4",
//      ); // Yellow - 3
//    }

    judge.togglePlayersTurn();
    background = Sprite('landingPage.png');
    judge.gameMode = this.gameProperties["gameMode"];
    this.judge.togglePlayersTurn();

    if (this.channelLayer != null) {
      this.channelLayer.broadcast(
            this.judge.tableState,
            createTable: createTable,
            joinTable: joinTable,
          );
    }

    if (Flame.bgm != null && Flame.bgm.isPlaying) {
      Flame.bgm.pause();
    }
  }

  @override
  void render(Canvas canvas) {
    try {
      // TODO: implement render
      // Drawing Background
      Rect bg = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
      Paint bgPaint = Paint();
      Paint bgPaintBorder = Paint();
      bgPaint.color = Color(0xffffffff);
      bgPaintBorder.strokeWidth = 2.0;
      bgPaintBorder.style = PaintingStyle.stroke;
      canvas.drawRect(bg, bgPaint);
      canvas.drawRect(bg, bgPaintBorder);

      canvas.save();
      if (background != null) {
        background.renderRect(canvas,
            new Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));
      }

      if (painter != null) {
        painter.render(canvas);
      }
      DrawBoard.drawLudoSquares(canvas, leftPad, topPad);

      if (dice != null && !this.gameFinished) {
        dice.render(canvas);
      }

      if (controller != null && !this.gameFinished) {
        controller.render(canvas);
      }

      this.updatePlayersCell();
      for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
        if (players[playerIndex] != null) {
          players[playerIndex].render(canvas);
        }
      }

      // Rendering Game Start Banner
//      if (this.gameStartBannerVisible && gameStartBanner != null) {
//        Offset center =
//            new Offset(screenSize.width / 2, topPad + (7.5 * boxHeight));
//        gameStartBanner.renderRect(
//            canvas,
//            new Rect.fromCenter(
//              center: center,
//              width: 12 * boxWidth,
//              height: (boxHeight * 12),
//            ));
//      }

      if (!this.bannerTimeOutCalled && this.gameStarted) {
        this.bannerTimeOutCalled = true;
        void handleBannerDisappear() {
          this.gameStartBannerVisible = false;
          this.players[0].startTimer();
        }

        audioPlayer.play('gameStartSound.mp3');
        Timer tTimer = new Timer(Duration(seconds: 1), handleBannerDisappear);
        this.addTimer(tTimer);
      }

      canvas.restore();

      // Rendering Individual Players
      var cellPosMap = {
        0: [-0.1, -0.7],
        1: [0.4, -0.7],
        2: [-0.1, -0.3],
        3: [0.4, -0.3],
        4: [-0.1, -0.7],
        5: [0.4, -0.7],
        6: [-0.1, -0.3],
        7: [0.4, -0.3],
        8: [-0.1, -0.7],
        9: [0.4, -0.7],
        10: [-0.1, -0.3],
        11: [0.4, -0.3],
        12: [-0.1, -0.7],
        13: [0.4, -0.7],
        14: [-0.1, -0.3],
        15: [0.4, -0.3],
      };

      for (int i = 0; i < 52; i++) {
        List<Player> temp = [];
        for (int j = 0; j < 4; j++) {
          if (this.players[j] != null) {
            for (int k = 0; k < 4; k++) {
              Player p = this.players[j].players[k];
              if (!p.isPlayerIdle()) {
                int pos =
                    (p.currentPlayerStep + idleEntrySteps[p.playerColorId]) %
                        52;
                if (pos == i && p.currentPlayerStep < 53) {
                  if (this.playersInCell.containsKey(pos) &&
                      this.playersInCell[pos] > 1) {
                    temp.add(p);
                  }
                }
              }
            }
          }
        }

        if (temp.length > 0) {
          double currentX = stepsAndCellMapping[i][0];
          double currentY = stepsAndCellMapping[i][1];

          double x = this.leftPad + ((currentX + 0.1) * boxWidth);
          double y = this.topPad + ((currentY - 0.5) * boxHeight);

          for (int j = 0; j < temp.length; j++) {
            temp[j].rect =
                Rect.fromLTWH(x, y, (boxWidth * 0.8), (boxHeight * 1.25));

            try {
              if (temp.length > 1) {
                x = this.leftPad + ((currentX + cellPosMap[j][0]) * boxWidth);
                y = this.topPad + ((currentY + cellPosMap[j][1]) * boxHeight);

                temp[j].rect =
                    Rect.fromLTWH(x, y, boxWidth * 0.8, boxHeight * 1.25);
              }
            } catch (e) {
              print('$e');
              this.log.e('$e');
            }

            if (temp[j].rect != null) {
              if (temp[j].validMove &&
                  this.dice.current != DiceSituation.playerPlaying) {
                Offset of = new Offset(0.0, boxWidth * 0.2);
                canvas.drawCircle(temp[j].rect.bottomCenter - of,
                    boxWidth / 2.25, temp[j].borderStroke);
              }
              temp[j].playerSprite.renderRect(canvas, temp[j].rect);
            }
          }
        }
      }

      for (int pi = 0; pi < 4; pi++) {
        if (this.players[pi] != null) {
          List<Player> p = this.players[pi].players;
          int colorId = this.players[pi].playerColorId;
          for (int j = 0; j < 4; j++) {
            List<Player> temp = [];
            Map<int, bool> added = {};
            if (p[j].currentPlayerStep > 52 && !p[j].reachedHome) {
              if (!added.containsKey(j)) {
                temp.add(p[j]);
                added[j] = true;
              }
              for (int k = j + 1; k < 4; k++) {
                if (p[j].currentPlayerStep == p[k].currentPlayerStep) {
                  if (!added.containsKey(k)) {
                    temp.add(p[k]);
                    added[k] = true;
                  }
                }
              }
            }

            if (temp.length > 1) {
              for (int j = 0; j < temp.length; j++) {
                double currentX =
                    homeSteps[colorId][temp[j].currentPlayerStep][0];
                double currentY =
                    homeSteps[colorId][temp[j].currentPlayerStep][1];

                double x = this.leftPad + ((currentX + 0.1) * boxWidth);
                double y = this.topPad + ((currentY - 0.5) * boxHeight);

                temp[j].rect =
                    Rect.fromLTWH(x, y, (boxWidth * 0.8), (boxHeight * 1.25));

                try {
                  if (temp.length > 1) {
                    x = this.leftPad +
                        ((currentX + cellPosMap[j][0]) * boxWidth);
                    y = this.topPad +
                        ((currentY + cellPosMap[j][1]) * boxHeight);

                    temp[j].rect =
                        Rect.fromLTWH(x, y, boxWidth * 0.8, boxHeight * 1.25);
                  }
                } catch (e) {
                  print('$e');
                  this.log.e('$e');
                }

                if (temp[j].rect != null) {
                  if (temp[j].validMove &&
                      this.dice.current != DiceSituation.playerPlaying) {
                    Offset of = new Offset(0.0, boxWidth * 0.2);
                    canvas.drawCircle(temp[j].rect.bottomCenter - of,
                        boxWidth / 2.25, temp[j].borderStroke);
                  }
                  temp[j].playerSprite.renderRect(canvas, temp[j].rect);
                }
              }
            }
          }
        }
      }

      if (painter != null) {
        painter.render(canvas, drawRank: true);
      }
    } catch (err) {
      logger.log(Level.error,
          "Error | Ludo Box Render | " + DateTime.now().toString() + " | $err");
      this.log.e(
          "Error | Ludo Box Render | " + DateTime.now().toString() + " | $err");
    }
  }

  @override
  void update(double t) {
    try {
      // TODO: implement update
      if (this.gameStartBannerVisible || !this.gameStarted) {
        return;
      }

      dice.update(t);
      controller.update(t);
      for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
        if (players[playerIndex] != null) {
          players[playerIndex].update(t);
        }
      }
    } catch (err) {
      logger.log(Level.error,
          "Error | Ludo Box Update | " + DateTime.now().toString() + " | $err");
      this.log.e(
          "Error | Ludo Box Update | " + DateTime.now().toString() + " | $err");
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    horizontalGrid = (screenSize.width - 4.0) / 100.0;
    verticalGrid = (screenSize.height - 4.0) / 100.0;

    leftPad = horizontalGrid * 2.0;
    topPad = verticalGrid * 25;

    boxWidth = horizontalGrid * 6.4;
    boxHeight = horizontalGrid * 6.4;

    super.resize(size);
  }

  void onTapUp(TapUpDetails d) {
    try {
      if (this.gameStartBannerVisible || !this.gameStarted) {
        return;
      }

      if (dice.rect.contains(d.globalPosition)) {
        dice.onTapUp();
      }

      for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
        if (players[playerIndex] != null) {
          for (int index = 0; index < 4; index++) {
            if (players[playerIndex]
                .players[index]
                .rect
                .contains(d.globalPosition)) {
              players[playerIndex].players[index].onTapUp();
            }
          }
        }
      }
    } catch (err) {
      logger.log(Level.error,
          "Error | Ludo Box Tap | " + DateTime.now().toString() + " | $err");
      this
          .log
          .e("Error | Ludo Box Tap | " + DateTime.now().toString() + " | $err");
    }
  }

  void updatePlayersInCell(int cellNumber, {leaving = true}) {
    if (cellNumber > 0) {
      if (!this.playersInCell.containsKey(cellNumber)) {
        this.playersInCell[cellNumber] = 0;
      }

      if (leaving && this.playersInCell[cellNumber] > 0) {
        this.playersInCell[cellNumber] -= 1;
      } else if (!leaving) {
        this.playersInCell[cellNumber] += 1;
      }
    }
  }

  void updatePlayersCell() {
    this.playersInCell = {};
    for (int i = 0; i < 4; i++) {
      if (this.players[i] != null) {
        int colorId = this.players[i].playerColorId;
        int addStepValue = idleEntrySteps[colorId];
        for (int j = 0; j < 4; j++) {
          Player temp = this.players[i].players[j];
          if (!temp.isPlayerIdle()) {
            int pos = (temp.currentPlayerStep + addStepValue) % 52;
            if (!this.playersInCell.containsKey(pos)) {
              this.playersInCell[pos] = 0;
            }
            this.playersInCell[pos] += 1;
          }
        }
      }
    }
  }

  void addTimer(Timer t) {
    this.allTimers.add(t);
  }

  void clearTimers() {
    if (this.allTimers != null) {
      for (int it = 0; it < this.allTimers.length; it++) {
        if (this.allTimers[it] != null && this.allTimers[it].isActive) {
          this.allTimers[it].cancel();
        }
        this.allTimers[it] = null;
      }
    }
  }

  void stopGame() {
    try {
      for (int i = 0; i < 4; i++) {
        if (this.players[i] != null) {
          if (this.players[i].clockTimer != null) {
            this.players[i].clockTimer.cancel();
          }
          if (this.players[i].colorTimer != null) {
            this.players[i].colorTimer.cancel();
          }
        }
      }
    } catch (err) {
      logger.log(Level.error,
          "Error | Ludo Box Stop | " + DateTime.now().toString() + " | $err");
      this.log.e(
          "Error | Ludo Box Stop | " + DateTime.now().toString() + " | $err");
    }
  }

  void exitGame() {
    try {
      if (this.channelLayer != null) {
        this.channelLayer.close();
      }
      this.stopGame();
      if (Flame.bgm != null && !Flame.bgm.isPlaying) {
        Flame.bgm.resume();
      }
      if (this.tapper != null) {
        flameUtil.removeGestureRecognizer(this.tapper);
        this.tapper.dispose();
        this.tapper.onTapUp = null;
        this.tapper = null;
      }

      this.clearTimers();
    } catch (err) {
      logger.log(
          Level.error,
          "Error | Ludo Box exitGame | " +
              DateTime.now().toString() +
              " | $err");
      this.log.e("Error | Ludo Box exitGame | " +
          DateTime.now().toString() +
          " | $err");
    }
  }
}

// Game Screen called from Flutter App
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static Future<int> loadDelay() async {
    await new Future.delayed(Duration(seconds: 5), () {});
    return 1;
  }

  Future<int> loadingData = loadDelay();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<int>(
      future: loadingData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (game.gameProperties != null) {
            if (game.gameProperties.containsKey("gameMode")) {
              if (game.gameProperties["gameMode"] == "ONLINE") {
                if (game.channelLayer.channel == null) {
                  return AlertDialog(
                    title: Text(
                      'Network Error',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text('Unable to connect to Server.',
                        style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    elevation: 25.0,
                    backgroundColor: Colors.redAccent,
                    actions: <Widget>[
                      FlatButton(
                        child:
                            Text('Okay', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                }
              }
            }
          }

          return WillPopScope(
            child: Material(
              child: Stack(
                children: <Widget>[
                  game.widget,
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        child: FlatButton(
                          color: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Image(
                            image: AssetImage('assets/images/backBtn0.png'),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext dialogContext) {
                                  String title = "Confirmation";
                                  String message = "Do you wanna exit game ?";
                                  List<Widget> actions = [
                                    FlatButton(
                                      child: Text('No',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        game.exitGame();
                                        Navigator.of(context).popUntil(
                                            ModalRoute.withName(
                                                "/tableScreen"));
                                      },
                                    ),
                                  ];

                                  return CustomWidgets.customAlertDialog(
                                    context: context,
                                    title: title,
                                    message: message,
                                    actions: actions,
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image(
                      image: AssetImage("assets/images/logoText.png"),
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.08,
                    ),
                  ),
                ],
              ),
            ),
            onWillPop: () {
              return null;
            },
          );
        } else {
          return WillPopScope(
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/landingPage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
            onWillPop: () {
              return null;
            },
          );
        }
      },
    );
  }
}
