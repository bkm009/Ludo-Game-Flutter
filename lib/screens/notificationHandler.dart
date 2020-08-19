import 'package:flutter/material.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';

class Notifications extends StatelessWidget {
  Map<String, dynamic> data = {};
  Notifications(result) {
    this.data = result;
  }

  @override
  Widget build(BuildContext context) {
    String title, message;
    bool error = false;
    List<Widget> actions = [
      FlatButton(
        child: Text('Okay', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
    ];

    if (this.data["action"] == "SERVER_ERROR") {
      error = true;
      title = "Network Error";
      message = "Unable to Connect to Server. Try Again";
      actions = [
        FlatButton(
          child: Text('Okay', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName("/home"));
          },
        ),
      ];
    }

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
          CustomWidgets.customAlertDialog(
            context: context,
            title: title,
            message: message,
            actions: actions,
            error: error,
          ),
        ],
      ),
      onWillPop: () {
        return null;
      },
    );
  }
}
