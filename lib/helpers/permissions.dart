import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final _handler = new PermissionHandler();

  Future<bool> _request(PermissionGroup group) async {
    var result = await _handler.requestPermissions([group]);
    if (result[group] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> _hasPermission(PermissionGroup group) async {
    var result = await _handler.checkPermissionStatus(group);
    return result == PermissionStatus.granted;
  }
}

Future<bool> checkPermissions() async {
  PermissionService ps = new PermissionService();
  PermissionGroup storage = PermissionGroup.storage;
  PermissionGroup telephone = PermissionGroup.phone;

  var result = await ps._hasPermission(storage);
  if (!result) {
    await ps._request(storage);
  }

  result = await ps._hasPermission(telephone);
  if (!result) {
    await ps._request(telephone);
  }

  result =
      await ps._hasPermission(storage) & await ps._hasPermission(telephone);
  return result;
}

class PermissionDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String title = "Permission Error";
    String message = "All required Permissions are not Granted. \n"
        "Restart Game & Grant the required Permissions.\n"
        "Please check in Settings for Permissions in case no Permission is requested.";
    List<Widget> actions = [
      FlatButton(
        child: Text('OK', style: TextStyle(color: Colors.white)),
        onPressed: () {
          if (Flame.bgm != null && Flame.bgm.isPlaying) {
            Flame.bgm.stop();
          }
          Flame.bgm.dispose();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
      ),
    ];

    return WillPopScope(
      child: Scaffold(
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/landingPage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
            child: Image(
              image: AssetImage("assets/images/logoText.png"),
              width: screenWidth * 0.95,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomWidgets.customAlertDialog(
                context: context,
                title: title,
                message: message,
                actions: actions,
                error: true),
          ),
        ]),
        resizeToAvoidBottomPadding: false,
      ),
      onWillPop: () {
        return null;
      },
    );
  }
}
