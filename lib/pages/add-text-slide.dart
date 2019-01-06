import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../elements/btn-cancel.dart';
import '../model/app-model.dart';

class AddTextSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, widget, model) {
        return Scaffold(
            appBar: new AppBar(title: new Text("Enter Text"), actions: [
              CancelButton(onPressed: () {
                Navigator.popUntil(context, (route) {
                  if (route.isFirst) {
                    return true;
                  } else {
                    return false;
                  }
                });
              })
            ]),
            body: ConstrainedBox(
                constraints: new BoxConstraints.expand(),
                child: _TextInput(onSubmit: (text) {
                  model.preview = new TextSlide(text: text);
                  Navigator.pushNamed(context, "/add-text-color-slide");
                })));
      },
    );
  }
}

class AddTextColorSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, widget, model) {
      return Scaffold(
          appBar: new AppBar(title: new Text("Pick a Colour"), actions: [
            CancelButton(onPressed: () {
              Navigator.popUntil(context, (route) {
                if (route.isFirst) {
                  return true;
                } else {
                  return false;
                }
              });
            })
          ]),
          body: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this would produce 2 rows.
            crossAxisCount: 3,
            // Generate 100 Widgets that display their index in the List
            children: List.generate(100, (index) {
              Color color = [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow
              ][index % 4];
              return Container(
                  decoration: BoxDecoration(color: color),
                  child: InkWell(
                      onTap: () {
                        print("Selected child $index");
                        TextSlide slide = model.preview as TextSlide;
                        slide.color = color;
                        model.preview = slide;
                        Navigator.pushNamed(context, "/add-preview");
                      },
                      child: Center(
                        child: Text(
                          'Item $index',
                          style: Theme.of(context).textTheme.headline,
                        ),
                      )));
            }),
          ));
    });
  }
}

class _TextInput extends StatefulWidget {
  _TextInput({Key key, this.onSubmit}) : super(key: key);
  final TextCallback onSubmit;

  __TextInputState createState() => __TextInputState();
}

typedef TextCallback = Function(String val);

class __TextInputState extends State<_TextInput> {
  final _controller = TextEditingController();

  void initState() {
    super.initState();

    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    _controller.dispose();
    super.dispose();
  }

  _onChange() {
    print("Second text field: ${_controller.text}");
    _controller.text = "Hello";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.red),
      child: Center(
        child: TextField(
          cursorWidth: 0.0,
          textAlign: TextAlign.center,
          style: TextStyle(color:Colors.white,fontSize: 20.0),
          decoration: InputDecoration(labelStyle:TextStyle(color:Colors.white),border: InputBorder.none, filled: true),
          autofocus: true,
          onEditingComplete: () {
            print("complete");
          },
          onSubmitted: widget.onSubmit,
        ),
      ),
    );
  }
}
