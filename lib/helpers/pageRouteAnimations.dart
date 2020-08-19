import 'package:flutter/material.dart';

class PopOut extends PageRouteBuilder {
  final Widget page;
  PopOut({this.page})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                page,
            transitionDuration: Duration(milliseconds: 650),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.bounceOut,
                    ),
                  ),
                  child: child,
                ));
}
