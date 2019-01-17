import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/app-model.dart';
import '../elements/btn-round-icon.dart';
import '../transitions/transition1.dart';

class HomePage extends StatefulWidget {

  HomePage({this.pathAdd});
  final String pathAdd;

  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  bool _enableAddSlide = true;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, iwidget, model) {
      return SafeArea(
          child: Scaffold(
              body: Container(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(flex: 3, child: PageSlideEntries(model: model)),
                      Expanded(flex: 2, child: PageSlideCalendar(model: model))
                    ]),
              ),
              //   Column(
              //   crossAxisAlignment: CrossAxisAlignment.stretch,
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     //PageSlideEntries(model:model),
              //     Container(color:Colors.blue),
              // ]),
              floatingActionButton: widget.pathAdd != null ? AnimatedContainer(
                  transform: Matrix4.identity()
                    ..scale(_enableAddSlide ? 1.0 : 0.0),
                  duration: Duration(milliseconds: 500),
                  //scale: _enableAddSlide ? 1.0 : 0.0,
                  child: RoundIconButton(
                      color: Colors.red,
                      icon: Icons.add,
                      onPressed: () {
                        //go to the add page
                        Navigator.pushNamed(context, widget.pathAdd );
                      })): null ));
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
  static const double _ViewportFraction = 1.0;
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
                  height: constraints.maxHeight,
                  color: Colors.orange,
                  child: Stack(children: [
                    entry.images.length >= 2
                        ? Center(
                            child: Container(
                                constraints: BoxConstraints.expand(),
                                child: Transition1(
                                    image1: entry.images
                                        .elementAt(0 % entry.images.length),
                                    image2: entry.images
                                        .elementAt(1 % entry.images.length))))
                        : Container(),
                    Container(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child:Align(
                            alignment: Alignment.bottomCenter,
                          child:Text(
                            DateFormat.d().format(entry.date),
                            style: TextStyle(
                                color: Color.fromARGB(200, 255, 255, 255),
                                fontSize: 80.0,
                                fontWeight: FontWeight.bold)))))
                  ]));
            });
      },
    );
  }
}

class PageSlideCalendar extends StatefulWidget {
  PageSlideCalendar({@required this.model});
  final AppModel model;

  _PageSlideCalendarState createState() => _PageSlideCalendarState();
}

class _PageSlideCalendarState extends State<PageSlideCalendar> {
  PageController _controller;
  static const double _ViewportFraction = 1.0;
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
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.white,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Text("Jan 2019")),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "Sun"),
                              DateWidget(text: "Mon"),
                              DateWidget(text: "Tues"),
                              DateWidget(text: "Wed"),
                              DateWidget(text: "Thurs"),
                              DateWidget(text: "Fri"),
                              DateWidget(text: "Sat")
                            ])),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "1"),
                              DateWidget(text: "2"),
                              DateWidget(text: "3"),
                              DateWidget(text: "4"),
                              DateWidget(text: "5"),
                              DateWidget(text: "6"),
                              DateWidget(text: "7")
                            ])),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "8"),
                              DateWidget(text: "9"),
                              DateWidget(text: "10"),
                              DateWidget(text: "11"),
                              DateWidget(text: "12"),
                              DateWidget(text: "13"),
                              DateWidget(text: "14")
                            ])),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "15"),
                              DateWidget(text: "16"),
                              DateWidget(text: "17"),
                              DateWidget(text: "18"),
                              DateWidget(text: "19"),
                              DateWidget(text: "20"),
                              DateWidget(text: "21")
                            ])),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "22"),
                              DateWidget(text: "23"),
                              DateWidget(text: "24"),
                              DateWidget(text: "25"),
                              DateWidget(text: "26"),
                              DateWidget(text: "27"),
                              DateWidget(text: "28")
                            ])),
                        Expanded(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              DateWidget(text: "29"),
                              DateWidget(text: "30"),
                              DateWidget(text: "31"),
                              DateWidget(text: ""),
                              DateWidget(text: ""),
                              DateWidget(text: ""),
                              DateWidget(text: "")
                            ])),
                        Expanded(flex: 2, child: Container())
                      ]));
            });
      },
    );
  }
}

class DateWidget extends StatelessWidget {
  DateWidget({this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Center(
              child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: Colors.red),
                    child: Center(child: Text(this.text)),
                  )))),
    );
  }
}
