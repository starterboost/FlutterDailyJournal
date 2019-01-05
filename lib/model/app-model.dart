import 'package:flutter/material.dart';

class AppInheritedWidget extends InheritedWidget {
  AppInheritedWidget({Key key, child}) : super(key: key, child: child);
  

  static AppInheritedWidget of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AppInheritedWidget)as AppInheritedWidget);
  }

  @override
  bool updateShouldNotify( AppInheritedWidget oldWidget) {
    return true;
  }

  
}