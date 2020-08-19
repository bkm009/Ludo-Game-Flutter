import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ludo_diamond/helpers/websocket_handler.dart';
import 'package:ludo_diamond/main.dart';
import 'package:ludo_diamond/screens/notificationHandler.dart';
import 'package:web_socket_channel/io.dart';

class UserData {
  static String userId;
  static String coinsBalance;
  static String response;

  static void resetData() {
    userId = null;
    coinsBalance = null;
  }

  static void connectAndRunning(BuildContext context) {
    String hostURL = "";
    hostURL = "ws://";
    if (isSecure) {
      hostURL = "wss://";
    }

    hostURL += hostName +
        "ws/$API_VERSION/connected/" +
        UserData.userId.toString() +
        "/";

    WebSocket.connect(hostURL).timeout(Duration(seconds: 5)).then((ws) {
      try {
        var channel = new IOWebSocketChannel(ws);
        channel.stream.listen((message) {
          var data = jsonDecode(message);
          if (data != null && data["data"] != null) {
            data = data["data"];
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Notifications(data)));
          }
        }, onError: (err) {
          print("$err");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Notifications({
                    "action": "SERVER_ERROR",
                  })));
        }, onDone: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Notifications({
                    "action": "SERVER_ERROR",
                  })));
        });
      } catch (e) {
        print("$e");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Notifications({
                  "action": "SERVER_ERROR",
                })));
      }
    }, onError: (err) {
      print("$err");
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Notifications({
                "action": "SERVER_ERROR",
              })));
    });
  }

  static Future<String> loginProcess(username, password) async {
    String result = "SERVER_ERROR";

    String hostURL = "";
    hostURL = "ws://";
    if (isSecure) {
      hostURL = "wss://";
    }

    hostURL += hostName + "ws/$API_VERSION/login/";
    WebSocket.connect(hostURL).timeout(Duration(seconds: 5)).then((ws) {
      try {
        var channel = new IOWebSocketChannel(ws);
        Map<String, dynamic> broadcastingData = {
          "data": {"username": username, "password": password},
        };
        channel.sink.add(JsonEncoder().convert(broadcastingData));
        channel.stream.listen((message) {
          var data = jsonDecode(message);
          if (data != null && data["data"] != null) {
            data = data["data"];
            if (data["status"] != null) {
              if (data["status"] == "INVALID_CREDS") {
                result = "INVALID_CREDS";
              } else if (data["status"] == "VALID_LOGIN") {
                String uid = data["userId"].toString();
                String balance = data["balance"].toString();
                UserData.userId = uid;
                UserData.coinsBalance = balance;
                prefs.setString("userId", uid);
                prefs.setString("balance", balance);
                result = "VALID_LOGIN";
              }
            }
          }
          return result;
        }, onError: (err) {
          result = "SERVER_ERROR";
          return result;
        });
      } catch (e) {
        print('connection. ${e.toString()}');
        result = "SERVER_ERROR";
        return result;
      }
    }, onError: (err) {
      result = "SERVER_ERROR";
      return result;
    });

    await Future.delayed(Duration(seconds: 10), () {});
    return result;
  }

  static void refreshData() {
    if (UserData.userId == null || UserData.userId == "") {
      return;
    }

    String hostURL = "";
    hostURL = "ws://";
    if (isSecure) {
      hostURL = "wss://";
    }

    hostURL += hostName + "ws/$API_VERSION/data/";
    WebSocket.connect(hostURL).timeout(Duration(seconds: 5)).then((ws) {
      try {
        var channel = new IOWebSocketChannel(ws);
        Map<String, dynamic> broadcastingData = {
          "data": {"userId": UserData.userId},
        };
        channel.sink.add(JsonEncoder().convert(broadcastingData));
        channel.stream.listen((message) {
          var data = jsonDecode(message);
          if (data != null && data["data"] != null) {
            data = data["data"];
            if (data["status"] != null) {
              if (data["status"] == "SUCCESS") {
                String balance = data["balance"].toString();
                UserData.coinsBalance = balance;
                prefs.setString("balance", balance);
              }
            }
          }
        }, onError: (err) {});
      } catch (e) {
        print('connection. ${e.toString()}');
      }
    }, onError: (err) {});
  }

  static Future<List<Map<String, dynamic>>> searchUser(String query) async {
    String hostURL = "";
    hostURL = "ws://";
    if (isSecure) {
      hostURL = "wss://";
    }

    hostURL += hostName + "ws/$API_VERSION/search/$query/";
    List<Map<String, dynamic>> result = [];
    WebSocket.connect(hostURL).timeout(Duration(seconds: 5)).then((ws) {
      try {
        var channel = new IOWebSocketChannel(ws);
        channel.stream.listen((message) {
          var data = jsonDecode(message);
          if (data != null && data["data"] != null) {
            data = data["data"];
            result = new List.from(data);
          }
        }, onError: (err) {
          result = [];
        });
      } catch (e) {
        print('connection. ${e.toString()}');
        result = [];
      }
    }, onError: (err) {
      result = [];
    });

    await Future.delayed(Duration(seconds: 5), () {});
    return result;
  }
}
