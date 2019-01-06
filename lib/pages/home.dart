import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/app-model.dart';
import '../elements/btn-round-icon.dart';
import '../transitions/transition1.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  PageController _controller;
  bool _enableAddSlide = true;

  @override
    void initState() {
      _controller = PageController(initialPage:0,viewportFraction:0.9);
      _controller.addListener((){
        setState((){
          _enableAddSlide = _controller.page.floor() == 0 ? true : false;
        });
      });
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, widget, model) {
      return Scaffold(
          body: SafeArea(
              child:PageView.builder(
                controller: _controller,
                itemCount: model.items.length * 3,
                itemBuilder: ( context, index ){
                  var entry = model.items[(index / 3).floor()];
                  return Container(
                    color: Colors.blue,
                    child:  Stack(children: [
                      entry.images.length >= 2
                          ? Container(
                              constraints: BoxConstraints.expand(),
                              decoration: BoxDecoration(color: Colors.purple),
                              child: Transition1(
                                  image1: entry.images.elementAt(0),
                                  image2: entry.images.elementAt(2)))
                          : Container(),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text( DateFormat.MMMd().format( entry.date ),
                              style: TextStyle(
                                  color: Color.fromARGB(200, 255, 255, 255),
                                  fontSize: 80.0,
                                  fontWeight: FontWeight.bold)))
                    ])
                  );
                }
              ) 
            /*Stack(children: [
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
          ])*/
          ),
          floatingActionButton: AnimatedContainer(
            transform: Matrix4.identity()..scale( _enableAddSlide ? 1.0 : 0.0 ),
            duration : Duration(milliseconds: 500),
            //scale: _enableAddSlide ? 1.0 : 0.0, 
            child: RoundIconButton(
                color: Colors.red,
                icon: Icons.add,
                onPressed: () {
                  //go to the add page
                  Navigator.pushNamed(context, '/add-slide');
                }))
          ); 
    });
  }
}
