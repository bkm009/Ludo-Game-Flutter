import 'dart:math';

import 'package:device_id/device_id.dart';
import 'package:flame/util.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:ludo_diamond/components/user.dart';
import 'package:ludo_diamond/helpers/logger.dart';
import 'package:ludo_diamond/helpers/permissions.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/screens/homeScreen.dart';
import 'package:ludo_diamond/screens/loginScreen.dart';
import 'package:ludo_diamond/screens/tableScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final flameUtil = Util();
LudoBox game = LudoBox();
var logger = Logger(output: FilePrinter());

String deviceId;
SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

  logger.log(Level.info, "App Started at " + DateTime.now().toString());

  var ps = await checkPermissions();
  if (!ps) {
    logger.log(Level.info, "Permission Denied $DateTime.now()");
    return runApp(
      MaterialApp(
        initialRoute: '/permissionDenied',
        routes: {
          '/permissionDenied': (context) => PermissionDenied(),
        },
      ),
    );
  }

  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  await Flame.images.loadAll(<String>[
    'landingPage.png',
    'star.png',
    'playerRed.png',
    'playerBlue.png',
    'playerGreen.png',
    'playerYellow.png',
    'one.png',
    'two.png',
    'three.png',
    'four.png',
    'five.png',
    'six.png',
    'play.png',
    'celebration_sheet.png',
    'starBlue.png',
    'starRed.png',
    'starGreen.png',
    'starYellow.png',
    'tileYellow.png',
    'tileRed.png',
    'tileBlue.png',
    'tileGreen.png',
    'arrowBlue.png',
    'arrowYellow.png',
    'arrowRed.png',
    'arrowGreen.png',
    'start.png',
    'redIcon.png',
    'yellowIcon.png',
    'greenIcon.png',
    'blueIcon.png',
    'backBtn0.png',
    'leftHand.png',
    'rightHand.png',
    '1stPlace.png',
    '2ndPlace.png',
    '3rdPlace.png',
    '4thPlace.png',
  ]);

  Flame.audio.disableLog();
  await Flame.audio.loadAll(<String>[
    'playerMoveSound.mp3',
    'gameStartSound.mp3',
    'enemyKillSound.mp3',
    'homeEntry.mp3',
    'gameBackground.mp3',
    'dice.mp3',
    'safe.mp3',
  ]);

  Flame.bgm.initialize();
  UserData.resetData();
  prefs = await SharedPreferences.getInstance();

  if (kReleaseMode) {
    deviceId = await DeviceId.getID;
    Flame.bgm.play("gameBackground.mp3", volume: 0.5);
  } else {
    deviceId = new Random().nextInt(500).toString();
  }

  runApp(
    MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreenPage(),
        '/tableScreen': (context) => TableScreen(),
        '/loginScreen': (context) => LoginPage(),
      },
    ),
  );
}
