import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_diamond/components/user.dart';
import 'package:ludo_diamond/helpers/customWidgets.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode usernameFocusNode = new FocusNode();
  bool usernameTextFieldFocused = false;
  bool loginProcessing = false;

  String usernameInput, passwordInput;

  FocusNode passwordFocusNode = new FocusNode();
  bool passwordTextFieldFocused = false;

  void checkFNode() {
    if (this.usernameFocusNode.hasPrimaryFocus) {
      this.usernameTextFieldFocused = true;
    }
    if (this.passwordFocusNode.hasPrimaryFocus) {
      this.passwordTextFieldFocused = true;
    }
  }

  @override
  void initState() {
    this.usernameFocusNode.addListener(checkFNode);
    this.passwordFocusNode.addListener(checkFNode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      child: AbsorbPointer(
        absorbing: this.loginProcessing,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
              this.usernameFocusNode.unfocus();
              this.usernameTextFieldFocused = false;
              this.passwordFocusNode.unfocus();
              this.passwordTextFieldFocused = false;
              SystemChrome.setEnabledSystemUIOverlays([]);
            }
          },
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
              this.loginProcessing
                  ? Center(
                      child: Container(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(),
              Container(
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.2),
                child: Image(
                  image: AssetImage("assets/images/logoText.png"),
                  width: screenWidth * 0.95,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.03,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.06,
                    child: OutlineButton(
                      highlightedBorderColor: Color.fromRGBO(255, 222, 3, 0.8),
                      color: Colors.white,
                      splashColor: Colors.blue,
                      borderSide: BorderSide(
                        color: Color.fromRGBO(255, 222, 3, 0.8),
                        width: 4.0,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: screenWidth * 0.09,
                        textDirection: TextDirection.ltr,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName("/home"));
                      },
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                top: this.usernameTextFieldFocused
                    ? screenHeight * 0.35
                    : screenHeight * 0.55,
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.1,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      width: 5.0,
                      color: Colors.yellow,
                    ),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.green,
                        offset: new Offset(5.0, 5.0),
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          this.usernameInput = value;
                        });
                      },
                      focusNode: usernameFocusNode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decorationColor: Colors.transparent,
                        fontSize: screenHeight * 0.035,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.0,
                        ),
                        hintText: "Enter Username",
                        filled: true,
                        fillColor: Colors.greenAccent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                top: this.passwordTextFieldFocused
                    ? screenHeight * 0.35
                    : screenHeight * 0.70,
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.1,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      width: 5.0,
                      color: Colors.yellow,
                    ),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.green,
                        offset: new Offset(5.0, 5.0),
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          this.passwordInput = value;
                        });
                      },
                      obscureText: true,
                      focusNode: passwordFocusNode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decorationColor: Colors.transparent,
                        fontSize: screenHeight * 0.035,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.0,
                        ),
                        hintText: "Enter Password",
                        filled: true,
                        fillColor: Colors.greenAccent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.04),
                  child: FloatingActionButton(
                    heroTag: "loginBtn",
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.input,
                      size: screenWidth * 0.1,
                    ),
                    onPressed: () async {
                      if (this.usernameInput != null &&
                          this.usernameInput != "" &&
                          this.passwordInput != null &&
                          this.passwordInput != "") {
                        setState(() {
                          this.loginProcessing = true;
                        });

                        String title, message;
                        var actions = [
                          FlatButton(
                            child: Text('Try Again',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ];

                        var result = await UserData.loginProcess(
                            this.usernameInput, this.passwordInput);
                        if (result == "SERVER_ERROR") {
                          title = "Network Error";
                          message = "Unable to Connect to Cloud Server.";
                        } else if (result == "INVALID_CREDS") {
                          title = "Login Error";
                          message = "Incorrect Username or Password.";
                        } else if (result == "VALID_LOGIN") {
                          Navigator.of(context).pushNamed("/tableScreen");
                          return null;
                        }

                        setState(() {
                          this.loginProcessing = false;
                        });

                        return CustomWidgets.customAlertDialog(
                          context: context,
                          title: title,
                          message: message,
                          actions: actions,
                          error: true,
                        );
                      } else {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              String message = "Please Enter valid Data";
                              List<Widget> actions = [
                                FlatButton(
                                  child: Text('Okay',
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                )
                              ];

                              return CustomWidgets.customAlertDialog(
                                context: context,
                                message: message,
                                actions: actions,
                                error: true,
                              );
                            });

                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        return null;
      },
    );
  }
}
