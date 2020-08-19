import 'dart:async';
import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/ludo-box.dart';

enum DiceSituation {
  waiting,
  rolling,
  diceRollCalled,
  autoPlay,
  rolled,
  playerPlaying
}

class Dice {
  final LudoBox game;

  Sprite playButton;
  List<Sprite> rolledDice;
  DiceSituation current = DiceSituation.waiting;
  Rect rect;

  Dice(this.game) {
    playButton = Sprite('play.png');
    rolledDice = [
      Sprite('one.png'),
      Sprite('two.png'),
      Sprite('three.png'),
      Sprite('four.png'),
      Sprite('five.png'),
      Sprite('six.png'),
    ];
  }

  void render(Canvas c) {
    rect = Rect.fromLTWH(
        this.game.leftPad + (5 * boxWidth),
        this.game.topPad + (16.0 * boxHeight),
        (horizontalGrid * 30),
        (horizontalGrid * 30));

    if (current == DiceSituation.waiting &&
        playButton != null &&
        this.isDevicePlayerTurn()) {
      int playerTurn = this.game.judge.tableState["playersTurn"];
      rect = this.game.players[playerTurn].playButtonRect;
      if (rect != null) {
        playButton.renderRect(c, rect);
      }
    } else if (current == DiceSituation.rolling ||
        current == DiceSituation.diceRollCalled) {
      int min = 1, max = 6;
      Random rnd = new Random();
      int ii = min + (rnd.nextInt(max) % 6);

      int playerTurn = this.game.judge.tableState["playersTurn"];
      rect = this.game.players[playerTurn].playButtonRect;
      if (rect != null) {
        rolledDice[ii - 1].renderRect(c, rect);
      }

      current = DiceSituation.diceRollCalled;
    } else if (current == DiceSituation.rolled ||
        current == DiceSituation.playerPlaying ||
        current == DiceSituation.autoPlay) {
      int dResult = this.game.judge.tableState["diceResult"];
      int playerTurn = this.game.judge.tableState["playersTurn"];
      rect = this.game.players[playerTurn].playButtonRect;
      if (rect != null) {
        rolledDice[dResult - 1].renderRect(c, rect);
      }
    }
  }

  void update(double t) {}

  void onTapUp() {
    if (!this.isDevicePlayerTurn()) {
      return;
    }

    if (!this.game.judge.tableState["lastMoveFinished"]) {
      return;
    }
    if (current == DiceSituation.waiting) {
      HapticFeedback.vibrate();
      rollDice();
      this
          .game
          .players[this.game.judge.tableState["playersTurn"]]
          .startTimer(stop: true);
      current = DiceSituation.rolling;
      audioPlayer.play('dice.mp3');
      this.game.judge.broadCastData();
    }
  }

  void rollDice() {
    if (current != DiceSituation.diceRollCalled) {
      void handleTimeout() {
        int min = 1, max = 60;
        Random rnd = new Random();

        if (!kReleaseMode) {
          this.game.judge.tableState["diceResult"] =
              2; //min + (rnd.nextInt(max) % 6);
        } else {
          this.game.judge.tableState["diceResult"] =
              min + (rnd.nextInt(max) % 6);
        }

        if (this.game.judge != null) {
          current = DiceSituation.autoPlay;
          this
              .game
              .players[this.game.judge.tableState["playersTurn"]]
              .startTimer(stop: false);
          this.game.judge.broadcastDiceResult();
        }
      }

      const duration = const Duration(milliseconds: 500);
      Timer tTimer = new Timer(duration, handleTimeout);
      this.game.addTimer(tTimer);
    }
  }

  bool isDevicePlayerTurn() {
    if (this.game.judge.playerId == -1) {
      return true;
    } else {
      if (this.game.judge.playerId ==
          this.game.judge.tableState["playersTurn"]) {
        return true;
      }
    }
    return false;
  }
}
