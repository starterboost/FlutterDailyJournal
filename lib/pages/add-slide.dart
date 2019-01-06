import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Add Slide"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        _AddSlideButton(text: "Add Text", onPressed:(){
          Navigator.pushNamed(context, '/add-text-slide');
        }),
        _AddSlideButton(text: "Add Image", onPressed:(){
          Navigator.pushNamed(context, '/add-image-slide');
        })
      ])
    );
  }
}

class _AddSlideButton extends StatelessWidget {
  _AddSlideButton({Key key, this.text, @required this.onPressed}) : super(key: key);
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onPressed,
      child: Container(
        height: 150.0,
        decoration: BoxDecoration(color:Colors.red,border:Border.all(color:Colors.red[100],width:1.0)),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal:20.0),
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon( Icons.add ),
                Container(width:10),
                Text(this.text)
              ] 
            ),
          )
        ),
      ),
    );
  }
}
