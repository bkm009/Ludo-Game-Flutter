import 'dart:convert';
import 'dart:io';
import 'package:ludo_diamond/components/dice.dart';
import 'package:ludo_diamond/components/player.dart';
import 'package:ludo_diamond/ludo-box.dart';
import 'package:ludo_diamond/main.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

final bool isSecure = false;
final String hostName = "10.0.2.2:8000/";
final String API_VERSION = "v1";

class CustomWebSocket {
  final LudoBox game;
  var channel;
  var hostURL;
  WebSocket ws;

  CustomWebSocket(this.game, var tableId) {
    this.channel = null;
    this.hostURL = "ws://";
    if (isSecure) {
      this.hostURL = "wss://";
    }

    this.hostURL +=
        hostName + "ws/$API_VERSION/table/" + tableId.toString() + "/";
    WebSocket.connect(this.hostURL).timeout(Duration(seconds: 5)).then((ws) {
      try {
        this.channel = new IOWebSocketChannel(ws);
        this.startListening();
      } catch (e) {
        print('connection. ${e.toString()}');
        this.channel = null;
      }
    }, onError: (err) {
      this.channel = null;
    });
  }

  void broadcast(var data, {bool createTable = false, joinTable = false}) {
    if (this.channel != null) {
      var playerPositions = {};
      for (int i = 0; i < 4; i++) {
        if (this.game.players[i] != null) {
          if (!playerPositions.containsKey(i)) {
            playerPositions[i.toString()] = [{}, {}, {}, {}];
          }
          for (int j = 0; j < 4; j++) {
            Player temp = this.game.players[i].players[j];
            var tMap = {
              "currentPlayerStep": temp.currentPlayerStep,
              "playerStep": temp.playerStep,
              "playerTurn": temp.playerTurn,
            };
            playerPositions[i.toString()][j] = tMap;
          }
        }
      }

      data["deviceId"] = deviceId;
      data["playerPositions"] = playerPositions;
      data["dicePosition"] = this.game.dice.current.index;
      data["createTable"] = createTable;
      data["joinTable"] = joinTable;
      data["noOfPlayers"] = this.game.numberOfPlayers;
      Map<String, dynamic> broadcastingData = {
        "data": {"table_state": data},
      };
      this.channel.sink.add(JsonEncoder().convert(broadcastingData));
    }
  }

  void startListening() async {
    this.channel.stream.listen((message) {
      var data = jsonDecode(message);
      this.game.judge.togglePlayersTurn();
      if (data != null && data["data"] != null) {
        data = data["data"];
        if (data["table_state"] != null) {
          if (data["table_state"]["dicePosition"] != null) {
            int dicePosition = data["table_state"]["dicePosition"];
            this.game.dice.current = DiceSituation.values[dicePosition];
          }

          // Check if all Player Joined
          if (data["table_state"]["gameStarted"] != null) {
            if (data["table_state"]["gameStarted"] && !this.game.gameStarted) {
              this.game.gameStarted = true;
              this.game.gameStartBannerVisible = true;
            }
          }

          // Start Timer for Player Turn
          if (data["table_state"]["playersTurn"] != null) {
            int pTurn = data["table_state"]["playersTurn"];
            this.game.players[pTurn].startTimer();
          }

          if (data["table_state"]["playerIds"] != null) {
            var playerIds = data["table_state"]["playerIds"];
            if (playerIds[deviceId] != null) {
              this.game.judge.playerId = playerIds[deviceId];
            }
          }

          this.game.judge.tableState = data["table_state"];
          if (data["table_state"]["playerPositions"] != null) {
            var playerPositions = data["table_state"]["playerPositions"];
            this.game.playersInCell = {};
            for (int i = 0; i < 4; i++) {
              if (this.game.players[i] != null) {
                if (playerPositions.containsKey(i.toString())) {
                  var tPosition = playerPositions[i.toString()];
                  for (int j = 0; j < 4; j++) {
                    Player temp = this.game.players[i].players[j];
                    temp.currentPlayerStep = tPosition[j]["currentPlayerStep"];
                    temp.playerStep = tPosition[j]["playerStep"];
                    temp.playerTurn = tPosition[j]["playerTurn"];
                    this.game.updatePlayersInCell(tPosition[j]["playerStep"],
                        leaving: false);
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  void close() {
    this.ws.close();
    this.channel.sink.close(status.goingAway);
  }
}
