import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/components/user.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/main.dart';
import 'package:ludo_diamond/screens/notificationHandler.dart';

class MultiPlayerInvite extends StatefulWidget {
  int numberOfPlayers;
  MultiPlayerInvite(int num) {
    this.numberOfPlayers = num;
  }

  @override
  _MultiPlayerInviteState createState() =>
      _MultiPlayerInviteState(this.numberOfPlayers);
}

class _MultiPlayerInviteState extends State<MultiPlayerInvite> {
  int bet = 50;
  int numOfPlayers = 2;
  List<Map<String, dynamic>> selected = [null, null, null];

  _MultiPlayerInviteState(int num) {
    this.numOfPlayers = num;
    this.selected = [];
    for (int i = 1; i < this.numOfPlayers; i++) {
      this.selected.add(null);
    }
  }

  Widget playerAddBox(BuildContext context, int index) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return this.selected[index] == null
        ? SizedBox(
            width: screenWidth * 0.25,
            height: screenHeight * 0.2,
            child: OutlineButton(
              onPressed: () async {
                List<int> temp = [];
                for (int i = 0; i < this.selected.length; i++) {
                  if (this.selected[i] != null &&
                      this.selected[i]["userId"] != -1) {
                    temp.add(this.selected[i]["userId"]);
                  }
                }
                var result = await showSearch(
                    context: context, delegate: PlayerSearchDelegate(temp));

                setState(() {
                  if (result != null &&
                      result["userId"].toString() == UserData.userId) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        String title = "Error";
                        String message = "Can not Select same User";
                        List<Widget> actions = [
                          FlatButton(
                            child: Text('okay',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ];

                        return CustomWidgets.customAlertDialog(
                          context: context,
                          title: title,
                          message: message,
                          actions: actions,
                          error: true,
                        );
                      },
                    );
                    return;
                  }
                  this.selected[index] = result;
                });
              },
              borderSide: BorderSide(
                color: Colors.yellowAccent,
                width: 5.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
              ),
              child: Icon(
                Icons.add,
                color: Colors.yellowAccent,
                size: screenHeight * 0.1,
              ),
            ),
          )
        : SizedBox(
            width: screenWidth * 0.25,
            height: screenHeight * 0.2,
            child: OutlineButton(
              onPressed: () {
                setState(() {
                  this.selected[index] = null;
                });
              },
              borderSide: BorderSide(
                color: Colors.green,
                width: 5.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.01,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    this.selected[index]["username"].toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.white,
                          offset: Offset(3.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.do_not_disturb_on,
                    color: Colors.red,
                    size: screenHeight * 0.05,
                  ),
                ],
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenCenter = MediaQuery.of(context).size.height / 2;

    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: new GestureDetector(
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
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.03,
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.06,
                      child: OutlineButton(
                        highlightedBorderColor:
                            Color.fromRGBO(255, 222, 3, 0.8),
                        color: Colors.white,
                        splashColor: Colors.blue,
                        borderSide: BorderSide(
                          color: Color.fromRGBO(255, 222, 3, 0.8),
                          width: 4.0,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: screenWidth * 0.09,
                          textDirection: TextDirection.ltr,
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.of(context)
                                .popUntil(ModalRoute.withName("/tableScreen"));
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "PRIZE",
                      style: TextStyle(
                        fontSize: screenWidth * 0.09,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.attach_money,
                      color: Colors.yellow,
                      size: screenWidth * 0.15,
                    ),
                    Text(
                      '$bet',
                      style: TextStyle(
                        fontSize: screenWidth * 0.12,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.2),
                    SizedBox(
                      width: screenWidth * 0.22,
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            this.bet = 50;
                          });
                        },
                        child: Icon(
                          Icons.restore,
                          color: Colors.redAccent,
                          size: screenWidth * 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: screenWidth * 0.2,
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            this.bet += 50;
                          });
                        },
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        child: Text(
                          "+ 50",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.24,
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            this.bet += 100;
                          });
                        },
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        child: Text(
                          "+ 100",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.24,
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            this.bet += 500;
                          });
                        },
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        child: Text(
                          "+ 500",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.22,
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            this.bet += 1000;
                          });
                        },
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        child: Text(
                          "+ 1K",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    playerAddBox(context, 0),
                    SizedBox(width: screenWidth * 0.1),
                    this.numOfPlayers > 2
                        ? playerAddBox(context, 1)
                        : SizedBox.shrink(),
                    SizedBox(width: screenWidth * 0.1),
                    this.numOfPlayers > 3
                        ? playerAddBox(context, 2)
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: OutlineButton(
                onPressed: () {
                  bool anyoneLowBalance = false;
                  for (int i = 0; i < this.selected.length; i++) {
                    if (this.selected[i]["balance"] < this.bet) {
                      anyoneLowBalance = true;
                    }
                  }

                  if (this.selected.contains(null) || anyoneLowBalance) {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        String title = "Error";
                        String message = anyoneLowBalance
                            ? "Not all Players have enough fund to Play"
                            : "Please select all Players";
                        List<Widget> actions = [
                          FlatButton(
                            child: Text('okay',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ];

                        return CustomWidgets.customAlertDialog(
                          context: context,
                          title: title,
                          message: message,
                          actions: actions,
                          error: true,
                        );
                      },
                    );
                  }

                  if (true) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => Notifications({
                              "action": "SERVER_ERROR",
                            })));
                  } else {
                    int min = 11;
                    int max = 99;
                    int a1 = min + new Random().nextInt(max - min);
                    int a2 = new DateTime.now().millisecondsSinceEpoch;

                    var privateTableCode = (a1 * 10) + a2;

                    game.resetGame(
                      noOfPlayers: this.numOfPlayers,
                      isPrivateTable: false,
                      tableId: privateTableCode,
                      gameMode: "ONLINE",
                      joinTable: true,
                    );
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => GameScreen()));

                    return Container();
                  }
                },
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.green,
                  size: screenWidth * 0.2,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        },
      ),
    );
  }
}

class PlayerSearchDelegate extends SearchDelegate {
  List<int> added = [];
  PlayerSearchDelegate(selected) {
    this.added = selected;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults

    Future<List<Map<String, dynamic>>> data = UserData.searchUser(query);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/landingPage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.04,
                  screenHeight * 0.04,
                  screenWidth * 0.04,
                  screenHeight * 0.02,
                ),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: screenWidth * 0.4,
                          child: Text(
                            snapshot.data[index]["username"].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.yellowAccent,
                                  offset: Offset(3.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        !snapshot.data[index]["isTrue"]
                            ? SizedBox(
                                width: screenWidth * 0.05,
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                  size: screenWidth * 0.05,
                                ),
                              )
                            : SizedBox(),
                        !snapshot.data[index]["isTrue"]
                            ? SizedBox(
                                width: screenWidth * 0.25,
                                child: Text(
                                  "suggested",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth * 0.05,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        snapshot.data[index]["enoughBalance"]
                            ? !this
                                    .added
                                    .contains(snapshot.data[index]["userId"])
                                ? SizedBox(
                                    width: screenWidth * 0.15,
                                    child: OutlineButton(
                                      onPressed: () {
                                        close(context, snapshot.data[index]);
                                      },
                                      borderSide: null,
                                      child: Icon(
                                        Icons.add_circle,
                                        color: Colors.white,
                                        size: screenWidth * 0.08,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: screenWidth * 0.18,
                                    child: Text(
                                      "Added",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: screenWidth * 0.05,
                                      ),
                                    ),
                                  )
                            : SizedBox(
                                width: screenWidth * 0.3,
                                child: Text(
                                  "Low Balance",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Stack(
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
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/landingPage.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
