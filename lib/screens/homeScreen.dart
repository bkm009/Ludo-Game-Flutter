import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:ludo_diamond/components/user.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';
import 'package:ludo_diamond/main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  static String gameType = "FREE";

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenCenter = MediaQuery.of(context).size.height / 2;
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
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Image(
              image: AssetImage("assets/images/logoText.png"),
              width: screenWidth * 0.95,
            ),
            SizedBox(height: screenHeight * 0.05),
            Align(
              alignment: Alignment.center,
              child: FlatButton(
                color: Colors.transparent,
                onPressed: () {
                  setState(() {
                    HomeScreenState.gameType = "PRIZE";
                  });

                  if (prefs != null && prefs.containsKey("userId")) {
                    String _userId = prefs.getString("userId");
                    if (_userId != "" && _userId != null) {
                      UserData.userId = _userId;
                      UserData.refreshData();
                      UserData.connectAndRunning(context);
                      Navigator.of(context).pushNamed("/tableScreen");
                    }
                  } else {
                    Navigator.of(context).pushNamed("/loginScreen");
                  }
                },
                child: Image.asset(
                  'assets/images/b1.gif',
                  width: screenWidth * 0.6,
                ),
              ),
            ),
            SizedBox(height: screenCenter - (screenHeight * .45)),
            Align(
              alignment: Alignment.center,
              child: FlatButton(
                color: Colors.transparent,
                onPressed: () {
                  setState(() {
                    HomeScreenState.gameType = "FREE";
                  });
                  Navigator.of(context).pushNamed("/tableScreen");
                },
                child: Image.asset(
                  'assets/images/b2.gif',
                  width: screenWidth * 0.6,
                ),
              ),
            ),
            SizedBox(height: screenCenter - (screenHeight * .4)),
          ],
        ),
      ],
    );
  }
}

class HomeScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: HomeScreen(),
        resizeToAvoidBottomPadding: false,
      ),
      onWillPop: () {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            String title = "Confirmation";
            String message = "Do you wanna exit game ?";
            List<Widget> actions = [
              FlatButton(
                child: Text('No', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (Flame.bgm != null && Flame.bgm.isPlaying) {
                    Flame.bgm.stop();
                  }
                  Flame.bgm.dispose();
                  Navigator.of(context).pop(true);
                },
              ),
            ];

            return CustomWidgets.customAlertDialog(
              context: context,
              title: title,
              message: message,
              actions: actions,
            );
          },
        );
      },
    );
  }
}
