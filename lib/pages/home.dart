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
  bool _enableAddSlide = true;

  

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, widget, model) {
      return SafeArea(
          child: Scaffold(
              backgroundColor: Colors.black,
              body: PageSlideEntries(model:model),
              floatingActionButton: AnimatedContainer(
                  transform: Matrix4.identity()
                    ..scale(_enableAddSlide ? 1.0 : 0.0),
                  duration: Duration(milliseconds: 500),
                  //scale: _enableAddSlide ? 1.0 : 0.0,
                  child: RoundIconButton(
                      color: Colors.red,
                      icon: Icons.add,
                      onPressed: () {
                        //go to the add page
                        Navigator.pushNamed(context, '/add-slide');
                      }))));
    });
  }
}

class PageSlideEntries extends StatefulWidget {
  PageSlideEntries({@required this.model});
  final AppModel model;

  _PageSlideEntriesState createState() => _PageSlideEntriesState();
}

class _PageSlideEntriesState extends State<PageSlideEntries> {

  PageController _controller;
  static const double _ViewportFraction = 0.8;
  bool _enableAddSlide = false;

  @override
  void initState() {
    _controller =
        PageController(initialPage: 0, viewportFraction: _ViewportFraction);
    _controller.addListener(() {
      setState(() {
        _enableAddSlide = _controller.page.floor() == 0 ? true : false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return PageView.builder(
              controller: _controller,
              itemCount: widget.model.items.length,
              itemBuilder: (context, index) {
                var entry = widget.model.items[index];
                return Container(
                    width: constraints.maxWidth,
                    height: _ViewportFraction * constraints.maxHeight,
                    color: Colors.orange,
                    child: Stack(children: [
                      entry.images.length >= 2
                          ? Center(
                              child: Container(
                                  constraints: BoxConstraints.expand(),
                                  child: Transition1(
                                      image1: entry.images.elementAt(
                                          0 % entry.images.length),
                                      image2: entry.images.elementAt(
                                          1 % entry.images.length))))
                          : Container(),
                      Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                              DateFormat.MMMd().format(entry.date) +
                                  " ${entry.images.length}",
                              style: TextStyle(
                                  color: Color.fromARGB(
                                      200, 255, 255, 255),
                                  fontSize: 80.0,
                                  fontWeight: FontWeight.bold)))
                    ]));
              });
        },
      );
  }
}
