import 'dart:ui';

import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/painting.dart';
import 'package:ludo_diamond/components/player.dart';
import 'package:ludo_diamond/ludo-box.dart';

class DrawBoard {
  final LudoBox game;

  Sprite star, starRed, starYellow, starGreen, starBlue;
  Sprite tileRed, tileGreen, tileYellow, tileBlue;
  Sprite arrowBlue, arrowYellow, arrowRed, arrowGreen;
  Sprite start;

  Sprite first, second, third, fourth;

  Paint borderStroke = Paint(), whiteCellPaint = Paint();

  DrawBoard(this.game) {
    this.borderStroke.strokeWidth = 0.4;
    this.borderStroke.style = PaintingStyle.stroke;

    this.whiteCellPaint.color = Color(0xffffffff);

    this.start = new Sprite("start.png");
    this.star = new Sprite("star.png");
    this.starRed = new Sprite("starRed.png");
    this.starYellow = new Sprite("starYellow.png");
    this.starGreen = new Sprite("starGreen.png");
    this.starBlue = new Sprite("starBlue.png");

    this.tileRed = new Sprite("tileRed.png");
    this.tileYellow = new Sprite("tileYellow.png");
    this.tileGreen = new Sprite("tileGreen.png");
    this.tileBlue = new Sprite("tileBlue.png");

    this.arrowRed = new Sprite("arrowRed.png");
    this.arrowYellow = new Sprite("arrowYellow.png");
    this.arrowGreen = new Sprite("arrowGreen.png");
    this.arrowBlue = new Sprite("arrowBlue.png");

    this.first = new Sprite("1stPlace.png");
    this.second = new Sprite("2ndPlace.png");
    this.third = new Sprite("3rdPlace.png");
    this.fourth = new Sprite("4thPlace.png");
  }

  void render(Canvas canvas, {bool drawRank: false}) {
    if (!drawRank) {
      drawAllSquares(canvas, this.game.leftPad, this.game.topPad);
      drawPlayerArea(canvas, this.game.leftPad, this.game.topPad,
          playerId: 0, colorId: 0);
      drawPlayerArea(canvas, this.game.leftPad, this.game.topPad,
          playerId: 1, colorId: 1);
      drawPlayerArea(canvas, this.game.leftPad, this.game.topPad,
          playerId: 2, colorId: 2);
      drawPlayerArea(canvas, this.game.leftPad, this.game.topPad,
          playerId: 3, colorId: 3);
    } else {
      drawRanks(canvas, this.game.leftPad, this.game.topPad);
    }
  }

  void drawAllSquares(
    Canvas gameCanvas,
    double left,
    double top,
  ) {
    Map<String, Sprite> spriteMap = {
      'starRed': this.starRed,
      'starGreen': this.starGreen,
      'starBlue': this.starBlue,
      'starYellow': this.starYellow,
      'tileRed': this.tileRed,
      'tileGreen': this.tileGreen,
      'tileBlue': this.tileBlue,
      'tileYellow': this.tileYellow,
      'star': this.star,
      'arrowRed': this.arrowRed,
      'arrowYellow': this.arrowYellow,
      'arrowGreen': this.arrowGreen,
      'arrowBlue': this.arrowBlue,
    };

    Map<String, String> cellSpriteMap = {
      '6,1': 'starRed', // Red star
      '7,1': 'tileRed',
      '7,2': 'tileRed',
      '7,3': 'tileRed',
      '7,4': 'tileRed',
      '7,5': 'tileRed',
      '1,8': 'starGreen', // Green Star
      '1,7': 'tileGreen',
      '2,7': 'tileGreen',
      '3,7': 'tileGreen',
      '4,7': 'tileGreen',
      '5,7': 'tileGreen',
      '9,7': 'tileBlue',
      '10,7': 'tileBlue',
      '11,7': 'tileBlue',
      '12,7': 'tileBlue',
      '13,7': 'tileBlue',
      '13,6': 'starBlue', // Blue Star
      '7,9': 'tileYellow',
      '7,10': 'tileYellow',
      '7,11': 'tileYellow',
      '7,12': 'tileYellow',
      '7,13': 'tileYellow',
      '8,13': 'starYellow', // Yellow Star
      // Stars
      '8,2': 'star',
      '2,6': 'star',
      '6,12': 'star',
      '12,8': 'star',
      // Arrows
      '7,0': 'arrowRed',
      '7,14': 'arrowYellow',
      '0,7': 'arrowGreen',
      '14,7': 'arrowBlue',
    };

    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        Rect cell = Rect.fromLTWH(
            (j * boxWidth) + left, (i * boxHeight) + top, boxWidth, boxHeight);

        gameCanvas.drawRect(cell, this.whiteCellPaint);
        gameCanvas.drawRect(cell, this.borderStroke);

        String cellKey = i.toString() + "," + j.toString();
        if (cellSpriteMap.containsKey(cellKey)) {
          String spriteKey = cellSpriteMap[cellKey];
          if (spriteMap.containsKey(spriteKey) &&
              spriteMap[spriteKey] != null) {
            spriteMap[spriteKey].renderRect(gameCanvas, cell);
          }
        }
      }
    }
  }

  void drawPlayerArea(Canvas gameCanvas, double left, double top,
      {playerId = 0, colorId = 0}) {
    int xPosition, yPosition;
    Color areaColor;

    if (colorId == 1) {
      xPosition = 0;
      yPosition = 0;
      areaColor = colorREDBoard;
    } else if (colorId == 3) {
      xPosition = 9;
      yPosition = 9;
      areaColor = colorYELLOWBoard;
    } else if (colorId == 2) {
      xPosition = 9;
      yPosition = 0;
      areaColor = colorGREENBoard;
    } else if (colorId == 0) {
      xPosition = 0;
      yPosition = 9;
      areaColor = colorBLUEBoard;
    }

    Paint areaPaint = Paint();
    areaPaint.color = areaColor;

    Rect playerArea = Rect.fromLTWH(left + (xPosition * boxWidth),
        top + (yPosition * boxHeight), boxWidth * 6, boxHeight * 6);
    Rect playerAreaWhite = Rect.fromLTWH(left + ((1 + xPosition) * boxWidth),
        top + ((1 + yPosition) * boxHeight), boxWidth * 4, boxHeight * 4);

    gameCanvas.drawRect(playerArea, areaPaint);
    gameCanvas.drawRect(playerArea, this.borderStroke);

    gameCanvas.drawRect(playerAreaWhite, this.whiteCellPaint);
    gameCanvas.drawRect(playerAreaWhite, this.borderStroke);

    List<int> xPositionsPlayerCircle = [xPosition + 2, xPosition + 4];
    List<int> yPositionsPlayerCircle = [yPosition + 2, yPosition + 4];
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        Offset offset = new Offset(
            left + (xPositionsPlayerCircle[i] * boxWidth),
            top + (yPositionsPlayerCircle[j] * boxHeight));
        this.start.renderRect(
            gameCanvas, new Rect.fromCircle(center: offset, radius: 12.0));
        gameCanvas.drawCircle(offset, 15.0, this.borderStroke);
      }
    }
  }

  void drawRanks(Canvas gameCanvas, double left, double top) {
    Map<dynamic, dynamic> ranks = this.game.judge.tableState["ranks"];
    Map<dynamic, Sprite> rankSprite = {
      1: this.first,
      2: this.second,
      3: this.third,
      4: this.fourth,
    };
    for (int i = 0; i < 4; i++) {
      if (this.game.players[i] != null) {
        int playerId = this.game.players[i].playerId;

        if (ranks.containsKey(playerId)) {
          int cxPosition, cyPosition, cId;
          if (this.game.players[playerId] != null) {
            cId = this.game.players[playerId].playerColorId;
          }
          if (cId == 1) {
            cxPosition = 0;
            cyPosition = 0;
          } else if (cId == 3) {
            cxPosition = 9;
            cyPosition = 9;
          } else if (cId == 2) {
            cxPosition = 9;
            cyPosition = 0;
          } else if (cId == 0) {
            cxPosition = 0;
            cyPosition = 9;
          }

          Rect playerAreaWin = Rect.fromLTWH(
              left + ((1 + cxPosition) * boxWidth),
              top + ((1 + cyPosition) * boxHeight),
              boxWidth * 4,
              boxHeight * 4);

          gameCanvas.drawRect(playerAreaWin, this.whiteCellPaint);
          gameCanvas.drawRect(playerAreaWin, this.borderStroke);

          int place = ranks[playerId];
          rankSprite[place].renderRect(gameCanvas, playerAreaWin);
        }
      }
    }

    if (ranks.length + 1 == this.game.numberOfPlayers) {
      this.game.clearTimers();
      List<int> pIds = [];
      Map<dynamic, dynamic> positions = {};
      for (int i = 0; i < this.game.numberOfPlayers; i++) {
        if (ranks.containsKey(i)) {
          positions[ranks[i]] = i;
        } else {
          pIds.add(i + 1);
        }
      }

      positions[pIds[0]] = this.game.numberOfPlayers - 1;

      Rect scoreBoard =
          new Rect.fromLTWH(left, top, boxWidth * 15.0, boxHeight * 15.0);
      Paint boardPaint = new Paint();
      boardPaint.color = Color(0xffffffff).withOpacity(0.9);
      gameCanvas.drawRect(scoreBoard, boardPaint);

      TextConfig finished = new TextConfig(
          fontSize: boxWidth * 1.5,
          color: Color(0xff000000).withOpacity(0.75),
          fontFamily: "karma");

      finished.render(gameCanvas, "Game Finished",
          new Position(scoreBoard.left + (boxWidth * 2.5), scoreBoard.top));

      for (int i = 1; i <= this.game.numberOfPlayers; i++) {
        Rect trophy = new Rect.fromLTWH(left + (boxWidth * 1),
            top + (boxWidth * (i * 3.0)), boxWidth * 2.5, boxHeight * 2.5);

        Players p = this.game.players[positions[i]];
        rankSprite[i].renderRect(gameCanvas, trophy);
        TextConfig playerName = new TextConfig(
            fontSize: boxWidth * 1.25,
            color: p.inActiveColor,
            fontFamily: "karma");
        playerName.render(
            gameCanvas,
            p.playerName,
            new Position(left + (boxWidth * 2.5) + (boxWidth * 2.5),
                top + (boxWidth * (i * 3.0))));
      }
    }
  }

  static void drawHomeArrowPath(
    Canvas gameCanvas,
    double left,
    double top,
    double mx,
    double my,
    double x1,
    double x2,
    double y1,
    double y2,
    Color pathColor,
  ) {
    Paint borderStroke = Paint();
    borderStroke.strokeWidth = 0.2;
    borderStroke.style = PaintingStyle.stroke;

    Paint arrowPaint = Paint();
    arrowPaint.color = pathColor;

    var arrowPath = Path();
    arrowPath.moveTo(left + (mx * boxWidth), top + (my * boxHeight));
    arrowPath.lineTo(left + (x1 * boxWidth), top + (y1 * boxHeight));
    arrowPath.lineTo(left + (x2 * boxWidth), top + (y2 * boxHeight));
    arrowPath.close();
    gameCanvas.drawPath(arrowPath, arrowPaint);
    gameCanvas.drawPath(arrowPath, borderStroke);
  }

  static void drawLudoSquares(Canvas gameCanvas, double left, double top) {
    DrawBoard.drawHomeArrowPath(
        gameCanvas, left, top, 6, 6, 6, 7.5, 9, 7.5, colorRED);
    DrawBoard.drawHomeArrowPath(
        gameCanvas, left, top, 6, 6, 9, 7.5, 6, 7.5, colorGREEN);
    DrawBoard.drawHomeArrowPath(
        gameCanvas, left, top, 6, 9, 9, 7.5, 9, 7.5, colorBLUE);
    DrawBoard.drawHomeArrowPath(
        gameCanvas, left, top, 9, 9, 9, 7.5, 6, 7.5, colorYELLOW);
  }
}
