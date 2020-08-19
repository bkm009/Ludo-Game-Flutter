import 'package:flutter/material.dart';

class CustomWidgets {
  static AlertDialog customAlertDialog(
      {context, title, message, actions, error = false}) {
    return AlertDialog(
        title: title != null
            ? Text(
                title.toString(),
                style: TextStyle(color: Colors.white),
              )
            : Text(""),
        content: message != null
            ? Text(message.toString(), style: TextStyle(color: Colors.white))
            : Text(""),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 25.0,
        backgroundColor: !error ? Colors.lightBlueAccent : Colors.redAccent,
        actions: actions);
  }

  static AlertDialog customBackButton({context, title, message, actions}) {
    return AlertDialog(
        title: title != null
            ? Text(
                title.toString(),
                style: TextStyle(color: Colors.white),
              )
            : Text(""),
        content: message != null
            ? Text(message.toString(), style: TextStyle(color: Colors.white))
            : Text(""),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 25.0,
        backgroundColor: Colors.lightBlueAccent,
        actions: actions);
  }
}

class PasswordTextField extends StatefulWidget {
  String _hintText;
  PasswordTextField({String hText}) {
    this._hintText = hText;
  }

  @override
  _PasswordTextFieldState createState() =>
      _PasswordTextFieldState(hText: this._hintText);
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  TextEditingController _textController = TextEditingController();
  bool _hidePassword = true;
  int _viewIconCount = 0;
  Color _viewIconColor = Colors.grey;

  String _hintText;
  _PasswordTextFieldState({String hText}) {
    this._hintText = hText;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Container(
        height: screenHeight * 0.08,
        child: TextFormField(
          controller: this._textController,
          obscureText: this._hidePassword,
          decoration: InputDecoration(
            icon: Icon(
              Icons.vpn_key,
              color: Colors.blue,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.remove_red_eye),
              color: _viewIconColor,
              onPressed: () {
                setState(() {
                  _viewIconCount += 1;
                  if (1 & _viewIconCount == 0) {
                    _viewIconColor = Colors.grey;
                  } else {
                    _viewIconColor = Colors.blue;
                  }
                  _hidePassword = !_hidePassword;
                });
              },
            ),
            labelText: this._hintText,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
          ),
          validator: (String value) {
            return value == ''
                ? 'Enter a Value'
                : value.contains(' ') ? 'Space is not allowed' : null;
          },
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  double topPad;
  CustomTextField({top}) {
    this.topPad = top;
  }

  @override
  _CustomTextFieldState createState() =>
      _CustomTextFieldState(top: this.topPad);
}

class _CustomTextFieldState extends State<CustomTextField> {
  double topPad;
  bool textFieldFocused = false;
  FocusNode fNode = new FocusNode();

  _CustomTextFieldState({top}) {
    this.topPad = top;
  }

  void checkFNode() {
    if (fNode.hasPrimaryFocus) {
      this.textFieldFocused = true;
    }
  }

  @override
  void initState() {
    fNode.addListener(checkFNode);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 500),
      top: this.topPad != null
          ? this.textFieldFocused ? screenHeight * 0.5 : this.topPad
          : screenHeight * 0.5,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.1,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
          vertical: screenWidth * 0.01,
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
            focusNode: fNode,
            textAlign: TextAlign.center,
            style: TextStyle(
              decorationColor: Colors.transparent,
              fontSize: screenHeight * 0.035,
            ),
            decoration: InputDecoration(
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
    );
  }
}
