import 'dart:async';

import 'package:flame/animation.dart' as fa;
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:ludo_diamond/board/movements.dart';
import 'package:ludo_diamond/components/dice.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/screens/homeScreen.dart';

Map<int, List<String>> playerSpriteFileName = {
  1: ['playerRed.png', 'playerRed.png', 'redIcon.png'],
  3: ['playerYellow.png', 'playerYellow.png', 'yellowIcon.png'],
  2: ['playerGreen.png', 'playerGreen.png', 'greenIcon.png'],
  0: ['playerBlue.png', 'playerBlue.png', 'blueIcon.png'],
};

class Player {
  final LudoBox game;

  bool reachedHome = false;
  Sprite playerSprite, th;
  Sprite playerActiveSprite;
  int playerId = 0;
  int playerColorId;
  int playerSubId = 0;
  int currentPlayerStep = 0;
  int playerStep = 0;
  double idleX, idleY;
  double currentX, currentY;
  bool playerTurn = false;
  Rect rect;

  // Player Circle area to show Valid Move
  Paint borderStroke = Paint();
  bool validMove = false;

  Player(this.game,
      {double idleX, double idleY, int playerId, int subId, int colorId}) {
    this.idleX = idleX;
    this.idleY = idleY;
    this.playerId = playerId;
    this.playerSubId = subId;
    this.playerColorId = colorId;
    this.playerSprite = Sprite(playerSpriteFileName[this.playerColorId][0]);
    this.playerActiveSprite =
        Sprite(playerSpriteFileName[this.playerColorId][1]);

    this.borderStroke.strokeWidth = 4.0;
    this.borderStroke.style = PaintingStyle.stroke;
    this.borderStroke.color = Color(0xff8B4513);
    this.validMove = false;
  }

  void render(Canvas c) {
    if (this.currentPlayerStep == 0) {
      double x = this.game.leftPad + ((this.idleX - 0.4) * boxWidth);
      double y = this.game.topPad + ((this.idleY - 1.1) * boxHeight);

      rect = Rect.fromLTWH(x, y, (boxWidth * 0.8), (boxHeight * 1.25));
      if (rect != null) {
        if (this.validMove &&
            this.game.dice.current != DiceSituation.playerPlaying) {
          Offset of = new Offset(0.0, boxWidth * 0.2);
          c.drawCircle(
              rect.bottomCenter - of, boxWidth / 2.25, this.borderStroke);
        }
        if (rect != null) {
          playerSprite.renderRect(c, rect);
        }
      }
    } else if (this.currentPlayerStep > 0 && !this.reachedHome) {
      int addStepValue = idleEntrySteps[this.playerColorId];
      if (this.currentPlayerStep + addStepValue <= 52 &&
          this
              .game
              .playersInCell
              .containsKey(this.currentPlayerStep + addStepValue) &&
          this.game.playersInCell[this.currentPlayerStep + addStepValue] > 1) {
        return;
      }

      if (this.game.players[this.playerId] != null &&
          this.currentPlayerStep > 52) {
        Player p1 = this.game.players[this.playerId].players[0];
        Player p2 = this.game.players[this.playerId].players[1];
        Player p3 = this.game.players[this.playerId].players[2];
        Player p4 = this.game.players[this.playerId].players[3];

        int count = 0;
        if (p1.currentPlayerStep == this.currentPlayerStep) {
          count += 1;
        }
        if (p2.currentPlayerStep == this.currentPlayerStep) {
          count += 1;
        }
        if (p3.currentPlayerStep == this.currentPlayerStep) {
          count += 1;
        }
        if (p4.currentPlayerStep == this.currentPlayerStep) {
          count += 1;
        }

        if (count > 1) {
          return;
        }
      }
      if (rect != null) {
        if (this.validMove &&
            this.game.dice.current != DiceSituation.playerPlaying) {
          Offset of = new Offset(0.0, boxWidth * 0.2);
          c.drawCircle(
              rect.bottomCenter - of, boxWidth / 2.25, this.borderStroke);
        }
        if (rect != null) {
          playerSprite.renderRect(c, rect);
        }
      }
    } else if (this.reachedHome) {
      this.currentX = homeSteps[this.playerColorId][this.currentPlayerStep][0];
      this.currentY = homeSteps[this.playerColorId][this.currentPlayerStep][1];

      double hx = homePosition[this.playerColorId][this.playerSubId][0];
      double hy = homePosition[this.playerColorId][this.playerSubId][1];

      double x = this.game.leftPad + ((this.currentX + hx) * boxWidth);
      double y = this.game.topPad + ((this.currentY + hy) * boxHeight);

      rect = Rect.fromLTWH(x, y, (boxWidth * 0.5), (boxHeight * 0.8));
      if (rect != null) {
        playerSprite.renderRect(c, rect);
      }
    }
  }

  void walk({bool jump = false}) {
    double pHeight = boxHeight * 1.25, pWidth = boxWidth * 0.8;
    int playerCell =
        (this.currentPlayerStep + idleEntrySteps[this.playerColorId]) % 52;
    this.currentX = stepsAndCellMapping[playerCell][0];
    this.currentY = stepsAndCellMapping[playerCell][1];

    if (this.currentPlayerStep > 52) {
      this.currentX = homeSteps[this.playerColorId][this.currentPlayerStep][0];
      this.currentY = homeSteps[this.playerColorId][this.currentPlayerStep][1];
    }

    double x = this.game.leftPad + ((this.currentX + 0.1) * boxWidth);
    double y = this.game.topPad + ((this.currentY - 0.5) * boxHeight);

    if (this.currentPlayerStep != this.playerStep && jump) {
      pWidth = boxWidth * 0.85;
      pHeight = boxHeight * 1.2;
      double xx, yy;
      if (this.currentPlayerStep < this.playerStep) {
        playerCell =
            (this.currentPlayerStep + 1 + idleEntrySteps[this.playerColorId]) %
                52;
        this.currentX = stepsAndCellMapping[playerCell][0];
        this.currentY = stepsAndCellMapping[playerCell][1];

        if (this.currentPlayerStep + 1 > 52) {
          this.currentX =
              homeSteps[this.playerColorId][this.currentPlayerStep + 1][0];
          this.currentY =
              homeSteps[this.playerColorId][this.currentPlayerStep + 1][1];
        }

        xx = this.game.leftPad + ((this.currentX + 0.1) * boxWidth);
        yy = this.game.topPad + ((this.currentY - 0.5) * boxHeight);
      } else {
        playerCell =
            (this.currentPlayerStep - 1 + idleEntrySteps[this.playerColorId]) %
                52;
        this.currentX = stepsAndCellMapping[playerCell][0];
        this.currentY = stepsAndCellMapping[playerCell][1];

        if (this.currentPlayerStep + 1 > 52) {
          this.currentX =
              homeSteps[this.playerColorId][this.currentPlayerStep - 1][0];
          this.currentY =
              homeSteps[this.playerColorId][this.currentPlayerStep - 1][1];
        }

        xx = this.game.leftPad + ((this.currentX + 0.1) * boxWidth);
        yy = this.game.topPad + ((this.currentY - 0.5) * boxHeight);
      }

      double ax = xx - x, ay = yy - y;
      x += (ax / 1.8);
      y += (ay / 1.8);
      this.rect = Rect.fromLTWH(x, y, pWidth, pHeight);
    } else {
      this.rect = Rect.fromLTWH(x, y, pWidth, pHeight);
    }
  }

  void update(double t) {}

  void allPlayerWalk() {
    for (int i = 0; i < 4; i++) {
      if (this.game.players[i] != null) {
        for (int j = 0; j < 4; j++) {
          this.game.players[i].players[j].walk();
        }
      }
    }
  }

  void onTapUp() {
    if (!this.game.dice.isDevicePlayerTurn()) {
      return;
    }

    if (this.game.dice.current == DiceSituation.playerPlaying) {
      return;
    }

    if (this.game.dice.current == DiceSituation.autoPlay) {
      return;
    }

    if (this.reachedHome) {
      return;
    }

    if (this.playerTurn && this.game.dice.current == DiceSituation.rolled) {
      this.game.judge.tableState["lastMoveFinished"] = false;
      this.game.dice.current = DiceSituation.playerPlaying;
      this.game.players[this.playerId].startTimer(stop: true);
      this.game.controller.playTurn(this);
    }
  }

  bool isPlayerIdle() {
    if (!this.reachedHome && this.currentPlayerStep == 0) {
      return true;
    }
    return false;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Players {
  final LudoBox game;
  bool playerTurn = false;
  int playerId = 0, playerColorId;
  List<Player> players;

  // Time Progress Bar
  int xPos, yPos;
  Timer clockTimer;
  Paint borderStroke = Paint();
  Paint whiteCellPaint = Paint();
  Paint playerPaint = Paint();
  Rect timerRectFull, timerRectClock;
  double timerTop, timerLeft;
  double timerWidth;

  // Coloring
  Color inActiveColor, activeColor = Color(0xffffffff);
  bool active = false;
  Timer colorTimer;

  // Player Icon
  Sprite playerIcon;
  Rect iconRect, playButtonRect;

  // Hand Icon
  SpriteSheet hand;
  fa.Animation handAnimation;
  Rect handRect;

  // Player Text
  Color textColor = new Color(0xffffffff);
  TextConfig textConfig;
  String playerName = "";

  // Player Color Id & Position Map
  Map<int, dynamic> colorIdlePos = {
    0: {
      'x': [2.0, 2.0, 4.0, 4.0],
      'y': [13.0, 11.0, 13.0, 11.0],
    },
    1: {
      'x': [2.0, 2.0, 4.0, 4.0],
      'y': [2.0, 4.0, 2.0, 4.0],
    },
    2: {
      'x': [11.0, 11.0, 13.0, 13.0],
      'y': [2.0, 4.0, 2.0, 4.0],
    },
    3: {
      'x': [11.0, 11.0, 13.0, 13.0],
      'y': [11.0, 13.0, 11.0, 13.0],
    },
  };

  Players(this.game, {int playerId, String playerName, int colorId}) {
    this.players = [];
    List<double> idleX = this.colorIdlePos[colorId]['x'];
    List<double> idleY = this.colorIdlePos[colorId]['y'];

    for (int i = 0; i < 4; i++) {
      Player temp = new Player(
        this.game,
        idleX: idleX[i],
        idleY: idleY[i],
        playerId: playerId,
        subId: i,
        colorId: colorId,
      );
      this.players.add(temp);
    }

    this.playerId = playerId;
    this.playerColorId = colorId;
    this.playerName = playerName == null ? "" : playerName;
    if (this.playerName.length > 8) {
      this.playerName = this.playerName.substring(0, 7) + "...";
    }

    borderStroke.strokeWidth = 1.5;
    borderStroke.style = PaintingStyle.stroke;
    borderStroke.color = Color(0xffffffff);
    whiteCellPaint.color = Color(0xffffffff);
    this.playerIcon = Sprite(playerSpriteFileName[this.playerColorId][2]);

    double diceSize = boxWidth * 1.5 < 32.0 ? boxWidth * 1.5 : 32.0;
    double iconSize = boxWidth * 1.5 < 40.0 ? boxWidth * 1.5 : 40.0;
    double handSize = boxWidth * 1.25 < 35.0 ? boxWidth * 1.25 : 35.0;

    if (this.playerColorId == 1) {
      xPos = 0;
      yPos = 0;
      playerPaint.color = colorRED;
      this.timerLeft = this.game.leftPad + (xPos * boxWidth);
      this.timerTop = this.game.topPad + (yPos * boxHeight) - (boxHeight * 0.5);

      this.inActiveColor = colorREDBoard;
      this.activeColor = Color(0xffffffff);

      this.iconRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * 1.5),
              this.game.topPad - (boxWidth * 2.2)),
          radius: iconSize);

      this.playButtonRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 4.5)),
              this.game.topPad + (boxWidth * (yPos - 2.2))),
          radius: diceSize);

      this.handRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 7.5)),
              this.game.topPad + (boxWidth * (yPos - 2.2))),
          radius: handSize);

      this.hand = SpriteSheet(
        imageName: 'leftHand.png',
        textureWidth: 263,
        textureHeight: 152,
        columns: 20,
        rows: 1,
      );

      this.handAnimation = this.hand.createAnimation(0, stepTime: 0.1);
    } else if (this.playerColorId == 3) {
      xPos = 9;
      yPos = 9 + 5;
      playerPaint.color = colorYELLOW;
      this.timerLeft = this.game.leftPad + (xPos * boxWidth);
      this.timerTop =
          this.game.topPad + (yPos * boxHeight) + (boxHeight * 1.25);

      this.inActiveColor = colorYELLOWBoard;
      this.activeColor =
          Color(0xffffffff); // Color.fromRGBO(255, 255, 102, 1.0);

      this.iconRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * 13.5),
              this.game.topPad + (boxWidth * 17.2)),
          radius: iconSize);

      this.playButtonRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 1.5)),
              this.game.topPad + (boxWidth * (yPos + 3.2))),
          radius: diceSize);

      this.handRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos - 1.5)),
              this.game.topPad + (boxWidth * (yPos + 3.2))),
          radius: handSize);

      this.hand = SpriteSheet(
        imageName: 'rightHand.png',
        textureWidth: 263,
        textureHeight: 152,
        columns: 20,
        rows: 1,
      );

      this.handAnimation = this.hand.createAnimation(0, stepTime: 0.1);
    } else if (this.playerColorId == 2) {
      xPos = 9;
      yPos = 0;
      playerPaint.color = colorGREEN;
      this.timerLeft = this.game.leftPad + (xPos * boxWidth);
      this.timerTop = this.game.topPad + (yPos * boxHeight) - (boxHeight * 0.5);

      this.inActiveColor = colorGREENBoard;
      this.activeColor = Color(0xffffffff); //Color.fromRGBO(50, 205, 50, 1.0);

      this.iconRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * 13.5),
              this.game.topPad - (boxWidth * 2.2)),
          radius: iconSize);

      this.playButtonRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 1.5)),
              this.game.topPad + (boxWidth * (yPos - 2.2))),
          radius: diceSize);

      this.handRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos - 1.5)),
              this.game.topPad + (boxWidth * (yPos - 2.2))),
          radius: handSize);

      this.hand = SpriteSheet(
        imageName: 'rightHand.png',
        textureWidth: 263,
        textureHeight: 152,
        columns: 20,
        rows: 1,
      );

      this.handAnimation = this.hand.createAnimation(0, stepTime: 0.1);
    } else if (this.playerColorId == 0) {
      xPos = 0;
      yPos = 9 + 5;
      playerPaint.color = colorBLUE;
      this.timerLeft = this.game.leftPad + (xPos * boxWidth);
      this.timerTop =
          this.game.topPad + (yPos * boxHeight) + (boxHeight * 1.25);

      this.inActiveColor = colorBLUEBoard;
      this.activeColor = Color(0xffffffff); //Color.fromRGBO(65, 105, 225, 1.0);

      this.iconRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * 1.5),
              this.game.topPad + (boxWidth * 17.2)),
          radius: iconSize);

      this.playButtonRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 4.5)),
              this.game.topPad + (boxWidth * (yPos + 3.2))),
          radius: diceSize);

      this.handRect = Rect.fromCircle(
          center: new Offset(this.game.leftPad + (boxWidth * (xPos + 7.5)),
              this.game.topPad + (boxWidth * (yPos + 3.2))),
          radius: handSize);

      this.hand = SpriteSheet(
        imageName: 'leftHand.png',
        textureWidth: 263,
        textureHeight: 152,
        columns: 20,
        rows: 1,
      );

      this.handAnimation = this.hand.createAnimation(0, stepTime: 0.1);
    }

    this.timerWidth = boxWidth * 6;
    this.timerRectFull = Rect.fromLTWH(
        this.timerLeft, this.timerTop, boxWidth * 6, boxHeight * 0.25);
  }
  void render(Canvas c) {
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (players[playerIndex] != null) {
        this.playerTurn = players[playerIndex].playerTurn;
        players[playerIndex].render(c);
      }
    }

    // Rendering Timer for Player Turn
    if (HomeScreenState.gameType != "FREE" && !this.game.gameFinished) {
      this.timerRectClock = Rect.fromLTWH(
          this.timerLeft, this.timerTop, this.timerWidth, boxHeight * 0.25);

      if (this.playerTurn &&
          this.timerRectClock != null &&
          this.timerRectFull != null) {
        c.drawRect(this.timerRectFull, borderStroke);
        c.drawRect(this.timerRectFull, whiteCellPaint);
        c.drawRect(this.timerRectClock, playerPaint);
      }
    }

    // Hand Animation
    if (this.playerTurn &&
        this.game.dice.current == DiceSituation.waiting &&
        this.handAnimation != null &&
        this.handRect != null &&
        !this.game.gameFinished) {
      this.handAnimation.getSprite().renderRect(c, this.handRect);
    }

    // Rendering Player Icon
    if (this.iconRect != null) {
      this.playerIcon.renderRect(c, iconRect);
    }

    // Rendering Player Name Text
    textConfig = TextConfig(
        fontSize: boxWidth * 0.8, color: this.textColor, fontFamily: "karma");
    textConfig.render(
        c,
        this.playerName,
        new Position(this.game.leftPad + (boxWidth * (xPos + 1)),
            this.game.topPad + (boxHeight * (yPos - 0.1))));
  }

  void update(double t) {
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (players[playerIndex] != null) {
        players[playerIndex].update(t);
      }
    }

    if (this.handAnimation != null) {
      this.handAnimation.update(t);
    }
  }

  void startTimer({bool stop = false}) {
    if (HomeScreenState.gameType == "FREE" && stop == false) {
      return;
    }

    this.timerWidth = boxWidth * 6;

    void handleTimeout() {
      double perSecondWidth = (boxWidth * 6) / 10.0;
      this.timerWidth -= perSecondWidth;
      if (this.timerWidth <= 0.0) {
        this.clockTimer.cancel();
        this.clockTimer = null;
        if (this.game.dice.current == DiceSituation.rolled) {
          this.game.controller.autoPlay(this.playerId);
        }
        this.game.controller.toggleTurn(this.playerId);
      } else {
        if (this.clockTimer != null && this.clockTimer.isActive) {
          this.clockTimer.cancel();
          this.clockTimer = null;
        }
        this.clockTimer = new Timer(Duration(seconds: 1), handleTimeout);
        this.game.addTimer(this.clockTimer);
      }
    }

    if (!stop) {
      if (this.clockTimer != null && this.clockTimer.isActive) {
        this.clockTimer.cancel();
        this.clockTimer = null;
      }
      this.clockTimer = new Timer(Duration(seconds: 1), handleTimeout);
      this.game.addTimer(this.clockTimer);
    } else {
      if (this.clockTimer != null && this.clockTimer.isActive) {
        this.clockTimer.cancel();
        this.clockTimer = null;
      }
    }
  }

  void resetColor() {
    for (int index = 0; index < 4; index++) {
      if (this.game.players[index] != null) {
        this.game.players[index].active = false;
        if (this.game.players[index].colorTimer != null &&
            this.game.players[index].colorTimer.isActive) {
          this.game.players[index].colorTimer.cancel();
          this.game.players[index].colorTimer = null;
        }
      }

      colorREDBoard = Color.fromRGBO(229, 46, 39, 1.0);
      colorGREENBoard = Color.fromRGBO(16, 122, 62, 1.0);
      colorBLUEBoard = Color.fromRGBO(26, 118, 186, 1.0);
      colorYELLOWBoard = Color.fromRGBO(254, 192, 18, 1.0);
      this.textColor = new Color(0xffffffff);
    }
  }

  void toggleActiveColor(int playerId) {
    if (this.game.gameFinished) {
      return;
    }

    if (this.game.players[playerId] != null) {
      int playerColorId = this.game.players[playerId].playerColorId;
      this.game.players[playerId].active = !this.game.players[playerId].active;
      if (this.game.players[playerId].active) {
        this.textColor = this.game.players[playerId].inActiveColor;
        if (playerColorId == 1) {
          colorREDBoard = this.game.players[playerId].activeColor;
        } else if (playerColorId == 3) {
          colorYELLOWBoard = this.game.players[playerId].activeColor;
        } else if (playerColorId == 2) {
          colorGREENBoard = this.game.players[playerId].activeColor;
        } else if (playerColorId == 0) {
          colorBLUEBoard = this.game.players[playerId].activeColor;
        }
      } else {
        this.textColor = this.game.players[playerId].activeColor;
        if (playerColorId == 1) {
          colorREDBoard = this.game.players[playerId].inActiveColor;
        } else if (playerColorId == 3) {
          colorYELLOWBoard = this.game.players[playerId].inActiveColor;
        } else if (playerColorId == 2) {
          colorGREENBoard = this.game.players[playerId].inActiveColor;
        } else if (playerColorId == 0) {
          colorBLUEBoard = this.game.players[playerId].inActiveColor;
        }
      }
    }

    if (this.colorTimer != null && this.colorTimer.isActive) {
      this.colorTimer.cancel();
      this.colorTimer = null;
    }

    this.colorTimer = new Timer(
        Duration(milliseconds: 500), () => toggleActiveColor(playerId));
    this.game.addTimer(this.colorTimer);
  }

  void onTapUp() {}
}
