
import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {

  RoundIconButton({Key key, @required this.onPressed, @required this.icon, this.color = Colors.blue}):super(key:key);

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: this.color,
        child: IconButton( color: Colors.white, icon: Icon(this.icon), onPressed:this.onPressed),
    ));
  }
}