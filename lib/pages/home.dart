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
          appBar: new AppBar(
            title: new Text("Home ${model.images.length}"),
          ),
          body: model.images.length >= 3
              ? Container(
                decoration: BoxDecoration(color:Colors.purple),
                height: 600,
                width: 400,
                child: Transition1(
                  image1: model.images.elementAt(0),
                  image2: model.images.elementAt(1))
              )
              : Container(),
          floatingActionButton: RoundIconButton(
              icon: Icons.add,
              onPressed: () {
                //go to the add page
                Navigator.pushNamed(context, '/add-slide');
              }));
    });
  }
}
