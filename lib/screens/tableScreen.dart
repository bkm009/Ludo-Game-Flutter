import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/components/user.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';
import 'package:ludo_diamond/helpers/pageRouteAnimations.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/main.dart';
import 'package:ludo_diamond/screens/homeScreen.dart';
import 'package:ludo_diamond/screens/multiplayerGame.dart';
import 'package:ludo_diamond/screens/playerDetailsScreen.dart';

class TableScreen extends StatefulWidget {
  TableScreenState createState() {
    return TableScreenState();
  }
}

class TableScreenState extends State<TableScreen> {
  bool showPrivateTable = false;
  bool showPrivateTableCode = false;
  bool showConfigurations = false;
  int privateTablePlayers = 2;
  int privateTableCode;
  bool userLoggedIn = false;
  bool showUserMenu = false;
  bool codeTextFieldFocused = false;

  TableScreenState() {
    userLoggedIn = HomeScreenState.gameType == "PRIZE" &&
            UserData.userId != null &&
            UserData.userId != ""
        ? true
        : false;
  }

  // Configuration's Password
  var currentKey = PasswordTextField(hText: 'Current Password');
  var newKey = PasswordTextField(hText: 'New Password');
  var confirmKey = PasswordTextField(hText: 'Confirm Password');

  FocusNode fNode = new FocusNode();

  void checkFNode() {
    if (fNode.hasPrimaryFocus) {
      codeTextFieldFocused = true;
    }
  }

  @override
  void initState() {
    fNode.addListener(checkFNode);
    super.initState();
  }

  void _clean() {
    showPrivateTable = false;
    showPrivateTableCode = false;
    privateTablePlayers = 2;
    privateTableCode = null;
    showConfigurations = false;
    showUserMenu = false;
    codeTextFieldFocused = false;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenCenter = MediaQuery.of(context).size.height / 2;

    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          SystemChrome.setEnabledSystemUIOverlays([]);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            fNode.unfocus();

            this.codeTextFieldFocused = false;
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
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenHeight * 0.03,
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      child: FlatButton(
                        color: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: this.userLoggedIn
                            ? Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: screenWidth * 0.09,
                                textDirection: TextDirection.ltr,
                              )
                            : Image(
                                image: AssetImage('assets/images/backBtn0.png'),
                              ),
                        onPressed: () {
                          setState(() {
                            if (this.userLoggedIn) {
                              this.showUserMenu = true;
                              this.showConfigurations = false;
                              showPrivateTable = false;
                              showPrivateTableCode = false;
                              fNode.unfocus();
                              SystemChrome.setEnabledSystemUIOverlays([]);
                              codeTextFieldFocused = false;
                            } else {
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName("/home"));
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      HomeScreenState.gameType == "FREE" ? "FREE" : "PRIZE",
                      style: TextStyle(
                        fontSize: screenWidth * 0.09,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/logoText.png"),
                  width: screenWidth * 0.95,
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                        color: Colors.transparent,
                        onPressed: () {
                          if (this.showPrivateTable) {
                            return;
                          }
                          if (UserData.userId == null ||
                              UserData.userId == "" ||
                              HomeScreenState.gameType == "FREE") {
                            Navigator.of(context)
                                .push(PopOut(page: PlayerDetailsScreen(2)));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MultiPlayerInvite(2)));
                          }
                        },
                        child: Image.asset(
                          'assets/images/p2.gif',
                          width: screenWidth * 0.4,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        color: Colors.transparent,
                        onPressed: () {
                          if (this.showPrivateTable) {
                            return;
                          }
                          if (UserData.userId == null ||
                              UserData.userId == "" ||
                              HomeScreenState.gameType == "FREE") {
                            Navigator.of(context)
                                .push(PopOut(page: PlayerDetailsScreen(3)));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MultiPlayerInvite(3)));
                          }
                        },
                        child: Image.asset(
                          'assets/images/p3.gif',
                          width: screenWidth * 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                        color: Colors.transparent,
                        onPressed: () {
                          if (this.showPrivateTable) {
                            return;
                          }
                          if (UserData.userId == null ||
                              UserData.userId == "" ||
                              HomeScreenState.gameType == "FREE") {
                            Navigator.of(context)
                                .push(PopOut(page: PlayerDetailsScreen(4)));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MultiPlayerInvite(4)));
                          }
                        },
                        child: Image.asset(
                          'assets/images/p4.gif',
                          width: screenWidth * 0.4,
                        ),
                      ),
                    ),
                    HomeScreenState.gameType == "FREE"
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                              color: Colors.transparent,
                              onPressed: () {
                                if (this.showPrivateTable) {
                                  return;
                                }
                                setState(() {
                                  this.codeTextFieldFocused = false;
                                  this.showPrivateTable = true;
                                });
                              },
                              child: Image.asset(
                                'assets/images/pt.gif',
                                width: screenWidth * 0.4,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
            AnimatedPositioned(
              duration: showPrivateTable
                  ? Duration(milliseconds: 500)
                  : Duration(milliseconds: 300),
              top: showPrivateTable
                  ? codeTextFieldFocused
                      ? screenHeight * 0.1
                      : screenHeight * 0.5
                  : screenHeight * 1.3,
              child: Container(
                height: screenCenter * 1.1,
                width: screenWidth * 0.9,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.blue,
                      blurRadius: 15.0,
                      spreadRadius: 2.0,
                    )
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Offstage(
                      offstage: !this.showPrivateTable,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: FlatButton(
                          child: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              this.showPrivateTable = false;
                              this.showPrivateTableCode = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: !this.showPrivateTableCode,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: FlatButton(
                          child: Icon(Icons.arrow_back, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              this.showPrivateTableCode = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Offstage(
                      offstage:
                          !this.showPrivateTable | this.showPrivateTableCode,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: Icon(Icons.do_not_disturb_on),
                                onPressed: () {
                                  if (this.privateTablePlayers > 2) {
                                    setState(() {
                                      this.privateTablePlayers -= 1;
                                    });
                                  }
                                },
                              ),
                              Text(
                                '$privateTablePlayers',
                                style: TextStyle(fontSize: screenWidth * .06),
                              ),
                              FlatButton(
                                child: Icon(Icons.add_circle),
                                onPressed: () {
                                  if (this.privateTablePlayers < 4) {
                                    setState(() {
                                      this.privateTablePlayers += 1;
                                    });
                                  }
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  "Create",
                                  style: TextStyle(fontSize: screenWidth * .06),
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.showPrivateTableCode = true;
                                    int min = 11;
                                    int max = 99;
                                    int a1 =
                                        min + new Random().nextInt(max - min);
                                    int a2 = new DateTime.now()
                                        .millisecondsSinceEpoch;

                                    this.privateTableCode = (a1 * 10) + a2;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Material(
                                child: Container(
                                  width: screenWidth * 0.5,
                                  child: TextField(
                                    focusNode: this.fNode,
                                    onChanged: (text) {
                                      this.privateTableCode = int.parse(text);
                                    },
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(15),
                                      WhitelistingTextInputFormatter(
                                          RegExp("[0-9]")),
                                    ],
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                      ),
                                      hintText: "Enter Table Code",
                                    ),
                                  ),
                                ),
                              ),
                              FlatButton(
                                child: Text(
                                  "Join",
                                  style: TextStyle(fontSize: screenWidth * .06),
                                ),
                                onPressed: () {
                                  if (this.privateTableCode == null) {
                                    // ignore: missing_return
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          String message =
                                              "Please Enter valid Table Code";
                                          List<Widget> actions = [
                                            FlatButton(
                                              child: Text('Okay',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            )
                                          ];

                                          return CustomWidgets
                                              .customAlertDialog(
                                            context: context,
                                            message: message,
                                            actions: actions,
                                            error: true,
                                          );
                                        });

                                    return;
                                  }

                                  game.resetGame(
                                    noOfPlayers: this.privateTablePlayers,
                                    isPrivateTable: true,
                                    tableId: this.privateTableCode,
                                    gameMode: "ONLINE",
                                    joinTable: true,
                                  );
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GameScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: !this.showPrivateTableCode,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SelectableText(
                                '$privateTableCode',
                                style: TextStyle(fontSize: screenWidth * 0.06),
                              ),
                              FlatButton(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.green,
                                  size: screenWidth * 0.18,
                                ),
                                onPressed: () {
                                  game.resetGame(
                                      noOfPlayers: this.privateTablePlayers,
                                      isPrivateTable: true,
                                      tableId: this.privateTableCode,
                                      gameMode: "ONLINE",
                                      createTable: true);

                                  setState(() {
                                    this._clean();
                                  });

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GameScreen()));
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            'Share the above code,\nstart playing',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: showConfigurations
                  ? Duration(milliseconds: 500)
                  : Duration(milliseconds: 500),
              top: screenHeight * 0.1,
              right: showConfigurations ? 0.0 : -screenWidth * 1.2,
              child: Container(
                height: screenHeight * 0.85,
                width: screenWidth * 0.9,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff8ffff),
                  border: Border.all(
                    color: Colors.redAccent,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.white,
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              width: screenWidth * 0.1,
                              child: FloatingActionButton(
                                heroTag: "closeConfig",
                                backgroundColor: Colors.deepOrange,
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.showConfigurations = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          currentKey,
                          SizedBox(height: screenHeight * 0.02),
                          newKey,
                          SizedBox(height: screenHeight * 0.02),
                          confirmKey,
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton(
                        heroTag: 'changePassword',
                        elevation: 0.0,
                        backgroundColor: Colors.deepOrange,
                        child: Icon(Icons.done_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    'Feature in Progress.\nNot for Free Play'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('got it'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: showUserMenu
                  ? Duration(milliseconds: 600)
                  : Duration(milliseconds: 500),
              top: screenHeight * 0.1,
              left: showUserMenu ? 0.0 : -screenWidth * 1.2,
              child: Container(
                height: screenHeight * 0.85,
                width: screenWidth * 0.9,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff8ffff),
                  border: Border.all(
                    color: Colors.redAccent,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.white,
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        child: FloatingActionButton(
                          heroTag: "closeConfigLoggedIn",
                          backgroundColor: Colors.deepOrange,
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              this.showUserMenu = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: screenHeight * 0.02),
                        Divider(thickness: 2.0),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: FlatButton(
                            color: Colors.greenAccent,
                            child: RichText(
                              text: TextSpan(
                                text: "Coins  ",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black,
                                      offset: Offset(10.0, 2.0),
                                    ),
                                  ],
                                ),
                                children: [
                                  UserData.coinsBalance != null
                                      ? TextSpan(
                                          text:
                                              UserData.coinsBalance.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.08,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : TextSpan(
                                          text: "0",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.07,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                UserData.refreshData();
                              });
                            },
                            splashColor: Colors.transparent,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Divider(thickness: 2.0),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: FlatButton(
                            color: Colors.lightBlueAccent,
                            child: Text(
                              "History",
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(10.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    String message = "coming soon...";
                                    List<Widget> actions = [
                                      FlatButton(
                                        child: Text('ok',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                    ];

                                    return CustomWidgets.customAlertDialog(
                                      context: context,
                                      message: message,
                                      actions: actions,
                                    );
                                  });
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Divider(thickness: 2.0),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: FlatButton(
                            color: Colors.deepOrangeAccent,
                            child: Text(
                              "Log Out",
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(10.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    String title = "Confirmation";
                                    String message = "Do you wanna logout ?";
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
                                          prefs.setString("userId", null);
                                          prefs.remove("userId");
                                          UserData.resetData();
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName("/home"));
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
                        SizedBox(height: screenHeight * 0.1),
                      ],
                    ),
                  ],
                ),
              ),
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
