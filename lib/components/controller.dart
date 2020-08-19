import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/spritesheet.dart';
import 'package:ludo_diamond/board/movements.dart';
import 'package:ludo_diamond/components/dice.dart';
import 'package:ludo_diamond/components/player.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/screens/homeScreen.dart';

class GameController {
  final LudoBox game;
  SpriteSheet homeReachSpriteSheet;
  Animation homeReachAnimation;
  bool homeReachCelebrationCalled = false, walk = false;
  Rect celebrationRect;

  GameController(this.game) {
    homeReachSpriteSheet = SpriteSheet(
      imageName: 'celebration_sheet.png',
      textureWidth: 120,
      textureHeight: 120,
      columns: 38,
      rows: 1,
    );

    homeReachAnimation = homeReachSpriteSheet.createAnimation(0, stepTime: 0.1);
  }

  void render(Canvas c) {
    if (this.homeReachCelebrationCalled) {
      this.celebrationRect = Rect.fromLTWH(
          this.game.leftPad + (5.0 * boxWidth),
          this.game.topPad + (5.0 * boxHeight),
          (horizontalGrid * 30),
          (horizontalGrid * 30));
      if (this.celebrationRect != null) {
        homeReachAnimation.getSprite().renderRect(c, this.celebrationRect);
      }
    }
  }

  void update(double t) {
    if (this.homeReachAnimation != null) {
      this.homeReachAnimation.update(t);
    }
  }

  void playTurn(Player player,
      {bool manualPlay = false, bool autoPlay = false}) {
    int initialStep = player.playerStep;
    int totalSteps = 58;
    bool validPlayed = false;

    this.game.judge.tableState["lastMoveValid"] = false;
    int additionStep = 0;

    if (!player.reachedHome && player.isPlayerIdle()) {
      if (this.game.judge.tableState["diceResult"] == 6) {
        additionStep = 2;
        validPlayed = true;
      }
    } else if (!player.reachedHome && !player.isPlayerIdle()) {
      if (player.playerStep + this.game.judge.tableState["diceResult"] <=
          totalSteps) {
        additionStep = this.game.judge.tableState["diceResult"];
        validPlayed = true;
      }
    }

    if (validPlayed) {
      this.game.judge.tableState["lastMoveValid"] = true;
    }
    if (autoPlay) {
      return;
    }

    if (validPlayed) {
      player.currentPlayerStep = player.playerStep;
      player.playerStep += additionStep;
      int addStepValue = idleEntrySteps[player.playerColorId];
      if (initialStep != 0 && initialStep <= 52) {
        initialStep = (initialStep + addStepValue) % 52;
        if (initialStep == 0) {
          initialStep = 52;
        }
        this.game.updatePlayersInCell(initialStep);
      }

      if (player.playerStep <= 52) {
        int finalStep = (player.playerStep + addStepValue) % 52;
        if (finalStep == 0) {
          finalStep = 52;
        }

        this.game.updatePlayersInCell(finalStep, leaving: false);
      }

      if (player.playerStep == 58) {
        this.game.judge.tableState["lastMoveReachedHome"] = true;
      }
      this.game.judge.tableState["lastMoveValid"] = true;
      animatePlayerMoves(player);
    } else {
      this.game.dice.current = DiceSituation.rolled;
      this.game.judge.tableState["lastMoveValid"] = false;
      if (manualPlay) {
        this.toggleTurn(player.playerId);
        this.game.judge.broadCastData();
      }
    }
  }

  void animatePlayerMoves(Player player) async {
    void checkIfPlayerWon(Player p) {
      int count = 0;
      for (int i = 0; i < 4; i++) {
        if (this.game.players[player.playerId].players[i].reachedHome) {
          count += 1;
        }
      }

      if (count == 4) {
        if (!this.game.judge.tableState.containsKey("ranks")) {
          this.game.judge.tableState["ranks"] = {};
        }

        Map<dynamic, dynamic> ranks = this.game.judge.tableState["ranks"];
        int rank = ranks.length + 1;
        ranks[player.playerId] = rank;
        this.game.judge.tableState["ranks"] = ranks;
      }
    }

    void callOffCelebration() {
      checkIfPlayerWon(player);
      this.homeReachCelebrationCalled = false;
      this.game.judge.tableState["lastMoveReachedHome"] = true;
      this.toggleTurn(player.playerId);
    }

    this.game.judge.tableState["lastMoveFinished"] = false;
    bool cycle = true;
    while (player.currentPlayerStep != player.playerStep) {
      if (cycle) {
        cycle = false;
        if (player.currentPlayerStep == 0) {
          audioPlayer.play('playerMoveSound.mp3');
          player.currentPlayerStep = player.playerStep;
          player.allPlayerWalk();
        } else {
          audioPlayer.play('playerMoveSound.mp3');
          player.walk(jump: true);
          await new Future.delayed(Duration(milliseconds: 180), () {
            if (player.currentPlayerStep == player.playerStep) {
              player.allPlayerWalk();
              cycle = false;
              return;
            }
            player.currentPlayerStep = player.currentPlayerStep + 1;
            player.allPlayerWalk();
            cycle = true;
            this.game.judge.broadCastData();
          });
        }

        if (player.currentPlayerStep == 58) {
          player.reachedHome = true;
          audioPlayer.play('homeEntry.mp3');
          this.homeReachCelebrationCalled = true;
          this.game.judge.broadCastData();
          Timer tTimer = new Timer(Duration(seconds: 1), callOffCelebration);
          this.game.addTimer(tTimer);
          break;
        }
      }
    }
    this.game.judge.tableState["lastMoveFinished"] = true;
    this.game.judge.broadCastData();
    if (!this.homeReachCelebrationCalled) {
      this.game.updatePlayersCell();
      this.battleAndWin(player);
      if (!this.game.judge.tableState["lastMoveKilledOpponent"]) {
        this.toggleTurn(player.playerId);
      }
    }
  }

  void toggleTurn(int playerId) {
    if (!(this.game.judge.tableState["diceResult"] == 6 ||
        this.game.judge.tableState["lastMoveReachedHome"] ||
        this.game.judge.tableState["lastMoveKilledOpponent"])) {
      this.game.judge.tableState["playersTurn"] =
          (playerId + 1) % this.game.numberOfPlayers;
    }

    Map<dynamic, dynamic> ranks = this.game.judge.tableState["ranks"];
    int winners = ranks.length + 1;
    if (winners == this.game.numberOfPlayers) {
      this.game.gameFinished = true;
      return;
    }

    int pTurn = this.game.judge.tableState["playersTurn"];
    while (ranks.containsKey(pTurn)) {
      this.game.judge.tableState["playersTurn"] =
          (pTurn + 1) % this.game.numberOfPlayers;
      pTurn = this.game.judge.tableState["playersTurn"];
    }

    this.game.dice.current = DiceSituation.waiting;
    this.game.judge.togglePlayersTurn();

    this
        .game
        .players[this.game.judge.tableState["playersTurn"]]
        .startTimer(stop: false);
  }

  void checkManualPlay(int playerId) {
    int _idle = 0, _reachedHome = 0, _valid = 0;
    Player _validPlayer;
    if (this.game.players[playerId] != null) {
      for (int index = 0; index < 4; index++) {
        Player temp = this.game.players[playerId].players[index];
        if (temp.reachedHome) {
          _reachedHome += 1;
        } else {
          if (temp.isPlayerIdle()) {
            _idle += 1;
          }
        }

        playTurn(temp, autoPlay: true);
        if (this.game.judge.tableState["lastMoveValid"]) {
          _valid += 1;
          _validPlayer = temp;
          temp.validMove = true;
        }
      }
    }

    if (_valid == 0) {
      this.toggleTurn(playerId);
      this.game.judge.broadCastData();
      return;
    }

    if (_idle > 0 && this.game.judge.tableState["diceResult"] == 6) {
      this.game.dice.current = DiceSituation.rolled;
      return;
    } else if ((_idle + _reachedHome) == 4 &&
        this.game.judge.tableState["diceResult"] != 6) {
      this.toggleTurn(playerId);
      this.game.judge.broadCastData();
      return;
    } else if (_valid == 1) {
      this.game.players[playerId].startTimer(stop: true);
      this.playTurn(_validPlayer, manualPlay: true);
      return;
    }
    this.game.dice.current = DiceSituation.rolled;
  }

  void battleAndWin(Player player) async {
    int playerCell =
        (player.playerStep + idleEntrySteps[player.playerColorId]) % 52;
    if (playerCell == 0) {
      playerCell = 52;
    }

    if (player.playerStep > 52) {
      return;
    }

    if (safeCells.contains(playerCell)) {
      audioPlayer.play("safe.mp3");
      return;
    }

    if (this.game.playersInCell[playerCell] != null &&
        this.game.playersInCell[playerCell] <= 1) {
      return;
    }

    for (int i = 0; i < 4; i++) {
      if (this.game.players[i] != null && i != player.playerId) {
        for (int j = 0; j < 4; j++) {
          Player temp = this.game.players[i].players[j];
          if (!temp.reachedHome &&
              temp.playerStep > 0 &&
              temp.playerStep < 53) {
            int tempCell =
                (temp.playerStep + idleEntrySteps[temp.playerColorId]) % 52;
            if (tempCell == 0) {
              tempCell = 52;
            }

            if (playerCell == tempCell && player.playerId != temp.playerId) {
              temp.currentPlayerStep = temp.playerStep;
              temp.playerStep = 0;
              temp.currentX = null;
              temp.currentY = null;
              this.game.judge.tableState["lastMoveKilledOpponent"] = true;

              this.game.players[player.playerId].startTimer(stop: true);
              audioPlayer.play('enemyKillSound.mp3');

              this.game.judge.tableState["lastMoveFinished"] = false;
              bool cycle = true;
              while (temp.currentPlayerStep != temp.playerStep) {
                if (cycle) {
                  cycle = false;
                  if (temp.currentPlayerStep < 2) {
                    temp.currentPlayerStep = 0;
                    temp.allPlayerWalk();
                  } else {
                    temp.walk(jump: true);
                    await new Future.delayed(Duration(milliseconds: 100), () {
                      if (temp.currentPlayerStep == temp.playerStep) {
                        temp.allPlayerWalk();
                        cycle = false;
                        return;
                      }
                      temp.currentPlayerStep = temp.currentPlayerStep - 1;
                      temp.allPlayerWalk();
                      cycle = true;
                      this.game.judge.broadCastData();
                    });
                  }
                }
              }

              this.game.judge.tableState["lastMoveFinished"] = true;
              this.toggleTurn(player.playerId);
            }
          }
        }
      }
    }
  }

  void autoPlay(int playerId) {
    for (int i = 0; i < 4; i++) {
      if (this.game.players[playerId] != null &&
          this.game.players[playerId].players[i] != null) {
        playTurn(this.game.players[playerId].players[i], autoPlay: true);
        if (this.game.judge.tableState["lastMoveValid"]) {
          break;
        }
      }
    }

    if (HomeScreenState.gameType == "FREE" &&
        !this.game.judge.tableState["lastMoveValid"]) {
      this.game.judge.tableState["playersTurn"] =
          (playerId + 1) % this.game.numberOfPlayers;
      this.game.dice.current = DiceSituation.waiting;
    }
  }
}
