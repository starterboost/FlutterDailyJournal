
import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  CancelButton({Key key, this.onPressed}):super(key:key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(child:Text("Cancel", style:TextStyle(color:Colors.white)),onPressed:this.onPressed);
  }
}