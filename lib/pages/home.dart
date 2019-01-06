import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../model/app-model.dart';
import '../elements/btn-round-icon.dart';
import '../transitions/transition1.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, widget, model) {
      return Scaffold(
          body: SafeArea(
              child: Stack(children: [
            model.images.length >= 2
                ? Container(
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(color: Colors.purple),
                    child: Transition1(
                        image1: model.images.elementAt(0),
                        image2: model.images.elementAt(2)))
                : Container(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text("Jan 5",
                    style: TextStyle(
                        color: Color.fromARGB(200, 255, 255, 255),
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold)))
          ])),
          floatingActionButton: RoundIconButton(
              icon: Icons.add,
              onPressed: () {
                //go to the add page
                Navigator.pushNamed(context, '/add-slide');
              }));
    });
  }
}
