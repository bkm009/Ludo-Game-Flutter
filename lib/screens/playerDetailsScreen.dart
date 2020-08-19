import 'package:flutter/cupertino.dart';
import 'package:ludo_diamond/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/screens/tableScreen.dart';

class PlayerDetailsScreen extends StatefulWidget {
  int nos = 2;
  PlayerDetailsScreen(num) {
    this.nos = num;
  }

  PlayerDetailsScreenState createState() {
    return PlayerDetailsScreenState(this.nos);
  }
}

class PlayerDetailsScreenState extends State<PlayerDetailsScreen>
    with SingleTickerProviderStateMixin {
  int numOfPlayers = 2;
  Map<dynamic, dynamic> playerDetails = {};
  bool showPlayerDetails = false;
  bool secondSetChosen = false;
  bool editingText = false;

  PlayerDetailsScreenState(num) {
    numOfPlayers = num;
    if (numOfPlayers == 2) {
      playerDetails = {
        0: [0, "Player 1"],
        1: [2, "Player 2"],
      };
    } else if (numOfPlayers >= 3) {
      playerDetails = {
        0: [0, "Player 1"],
        1: [1, "Player 2"],
        2: [2, "Player 3"],
      };
    }
    if (numOfPlayers == 4) {
      playerDetails[3] = [3, "Player 4"];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    void changeColor(int playerId, int colorId) {
      if (playerId == null || colorId == null) {
        return;
      }

      if (this.numOfPlayers == 2) {
        if (colorId == 1 || colorId == 3) {
          playerDetails[0][0] = 1;
          playerDetails[1][0] = 3;
          this.secondSetChosen = true;
        } else {
          playerDetails[0][0] = 0;
          playerDetails[1][0] = 2;
          this.secondSetChosen = false;
        }

        return;
      }

      int prevColorId = playerDetails[playerId][0];
      playerDetails[playerId][0] = colorId;

      for (int i = 0; i < numOfPlayers; i++) {
        if (i != playerId && playerDetails[i][0] == colorId) {
          playerDetails[i][0] = prevColorId;
        }
      }
    }

    Container playerName({int playerId = 0, int set = 0}) {
      TextEditingController _ctrl = new TextEditingController.fromValue(
          new TextEditingValue(
              text: playerDetails[playerId][1],
              selection: new TextSelection.collapsed(
                  offset: playerDetails[playerId][1].length)));

      bool textEditable = true;

      if (set == 1 && this.secondSetChosen) {
        textEditable = false;
      } else if (set == 2 && !this.secondSetChosen) {
        textEditable = false;
      }

      return Container(
        height: screenHeight * 0.045,
        width: screenWidth * 0.35,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 3.0,
            color: Colors.black54,
          ),
          color: Colors.white,
          boxShadow: [
            new BoxShadow(
              color: Colors.black,
              offset: new Offset(5.0, 5.0),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.005),
        child: Material(
          child: TextField(
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: textEditable ? Colors.black : Colors.blueGrey,
            ),
            controller: _ctrl,
            enabled: textEditable,
            onChanged: (value) {
              setState(() {
                playerDetails[playerId][1] = value;
              });
            },
          ),
        ),
      );
    }

    Container color({int colorId = 0, int playerId = 0}) {
      bool selected = false;
      int cid = playerDetails[playerId][0];
      if (colorId == cid) {
        selected = true;
      }

      return Container(
        width: screenWidth * 0.12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2.0,
            color: colorId == 0
                ? Colors.blue
                : colorId == 1
                    ? Colors.red
                    : colorId == 2 ? Colors.green : Colors.yellow,
          ),
          color: Colors.transparent,
        ),
        child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: FloatingActionButton(
              heroTag: playerId.toString() + colorId.toString(),
              splashColor: Colors.transparent,
              onPressed: () {
                setState(() {
                  changeColor(playerId, colorId);
                });
              },
              backgroundColor: selected ? Colors.white : Colors.transparent,
              child: selected
                  ? Icon(
                      Icons.check_circle,
                      color: colorId == 0
                          ? Colors.blue
                          : colorId == 1
                              ? Colors.red
                              : colorId == 2 ? Colors.green : Colors.yellow,
                      size: screenWidth * 0.098,
                      textDirection: TextDirection.rtl,
                    )
                  : null,
            )),
      );
    }

    Row colorPicker2({int playerId = 0, int set = 1}) {
      int colorId = 0;
      if (set == 1) {
        colorId = playerId == 0 ? 0 : 2;
      } else if (set == 2) {
        colorId = playerId == 0 ? 1 : 3;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: screenWidth * 0.005),
          color(colorId: colorId, playerId: playerId),
          SizedBox(width: screenWidth * 0.05),
          playerName(playerId: playerId, set: set),
          SizedBox(width: screenWidth * 0.005),
        ],
      );
    }

    Row colorPicker3({int playerId = 0}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: screenWidth * 0.005),
          color(colorId: 0, playerId: playerId),
          SizedBox(width: screenWidth * 0.02),
          color(colorId: 1, playerId: playerId),
          SizedBox(width: screenWidth * 0.02),
          color(colorId: 2, playerId: playerId),
          SizedBox(width: screenWidth * 0.02),
          color(colorId: 3, playerId: playerId),
          SizedBox(width: screenWidth * 0.03),
          playerName(playerId: playerId),
          SizedBox(width: screenWidth * 0.005),
        ],
      );
    }

    Row colorPicker4({int playerId = 0}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: screenWidth * 0.005),
          color(colorId: playerId, playerId: playerId),
          SizedBox(width: screenWidth * 0.05),
          playerName(playerId: playerId),
          SizedBox(width: screenWidth * 0.005),
        ],
      );
    }

    List<Widget> player = [];

    if (this.numOfPlayers == 3) {
      player = [
        SizedBox(height: screenHeight * 0.02),
        colorPicker3(playerId: 0),
        SizedBox(height: screenHeight * 0.005),
        colorPicker3(playerId: 1),
        SizedBox(height: screenHeight * 0.005),
        colorPicker3(playerId: 2),
        SizedBox(height: screenHeight * 0.02),
      ];
    } else if (this.numOfPlayers == 4) {
      player = [
        SizedBox(height: screenHeight * 0.02),
        colorPicker4(playerId: 0),
        SizedBox(height: screenHeight * 0.005),
        colorPicker4(playerId: 1),
        SizedBox(height: screenHeight * 0.005),
        colorPicker4(playerId: 2),
        SizedBox(height: screenHeight * 0.005),
        colorPicker4(playerId: 3),
        SizedBox(height: screenHeight * 0.02),
      ];
    }

    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            this.editingText = false;
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        },
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName("/tableScreen"));
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Color(0xffFFD700),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: this.numOfPlayers > 2
                          ? player
                          : [
                              Container(
                                color: this.secondSetChosen
                                    ? Color(0xff000000).withOpacity(0.3)
                                    : Colors.transparent,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: screenHeight * 0.03),
                                    colorPicker2(playerId: 0),
                                    SizedBox(height: screenHeight * 0.005),
                                    colorPicker2(playerId: 1),
                                    SizedBox(height: screenHeight * 0.02),
                                  ],
                                ),
                              ),
                              Container(
                                color: this.secondSetChosen
                                    ? Colors.transparent
                                    : Color(0xff000000).withOpacity(0.3),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: screenHeight * 0.03),
                                    colorPicker2(playerId: 0, set: 2),
                                    SizedBox(height: screenHeight * 0.005),
                                    colorPicker2(playerId: 1, set: 2),
                                    SizedBox(height: screenHeight * 0.02),
                                  ],
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.2),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: screenWidth * 0.3,
                    child: FlatButton(
                      color: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/images/startGame.png'),
                      ),
                      onPressed: () {
                        setState(() {
                          if (game != null) {
                            game.exitGame();
                          }
                          SystemChrome.setEnabledSystemUIOverlays([]);
                          game = new LudoBox();
                          game.resetGame(
                              noOfPlayers: numOfPlayers,
                              details: playerDetails);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => GameScreen()));
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onWillPop: () {
        return null;
      },
    );
  }
}
