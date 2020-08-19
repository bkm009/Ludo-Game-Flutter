import 'dart:async';

import 'package:logger/logger.dart';
import 'package:ludo_diamond/components/dice.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/screens/homeScreen.dart';

import '../main.dart';

class JudgeSystem {
  final LudoBox game;
  String gameMode = "OFFLINE";
  int playerId = -1;
  var tableState = {
    "playersTurn": 0,
    "diceResult": 1,
    "lastMoveReachedHome": false,
    "lastMoveKilledOpponent": false,
    "lastMoveFinished": true,
    "playerPositions": {},
    "ranks": {},
  };

  JudgeSystem(this.game) {
    this.tableState = {
      "playersTurn": 0,
      "diceResult": 1,
      "lastMoveReachedHome": false,
      "lastMoveKilledOpponent": false,
      "lastMoveFinished": true,
      "playerPositions": {},
      "ranks": {},
    };
  }

  // Method to Broadcast Dice Result to all Players
  void broadcastDiceResult() {
    this.tableState["lastMoveReachedHome"] = false;
    this.tableState["lastMoveKilledOpponent"] = false;
    this.broadCastData();
    void handleTimeout() {
      int cid = this.tableState["playersTurn"];
      this.game.dice.current = DiceSituation.autoPlay;
      this.game.controller.checkManualPlay(this.tableState["playersTurn"]);
//      this.game.controller.autoPlay(cid);
      if (HomeScreenState.gameType == "FREE" &&
          cid == this.tableState["playersTurn"]) {
//        this.game.controller.autoPlay(cid);
      }
    }

    const duration = const Duration(milliseconds: 500);
    Timer tTimer = new Timer(duration, handleTimeout);
    this.game.addTimer(tTimer);
  }

  void broadCastData() {
    if (this.gameMode == "ONLINE") {
      if (this.game.channelLayer != null) {
        this.game.channelLayer.broadcast(this.tableState);
      }
    }
  }

  // Enable player movement whose turn is arrived
  void togglePlayersTurn() {
    try {
      this.game.players[0].resetColor();
      for (int i = 0; i < 4; i++) {
        if (this.game.players[i] != null) {
          if (i == this.tableState["playersTurn"]) {
            this.game.players[i].toggleActiveColor(i);
          }
          for (int j = 0; j < 4; j++) {
            this.game.players[i].players[j].playerTurn = false;
            this.game.players[i].startTimer(stop: true);
            if (i == this.tableState["playersTurn"]) {
              this.game.players[i].players[j].playerTurn = true;
            }
            this.game.players[i].players[j].validMove = false;
          }
        }
      }
    } catch (err) {
      logger.log(Level.error,
          "Error | Judge togglePlayersTurn | $DateTime.now() | $err");
      this.togglePlayersTurn();
    }
  }
}
