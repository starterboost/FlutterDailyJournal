import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../elements/btn-round-icon.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
      ),
      body:Text("Home"),
      floatingActionButton: RoundIconButton( icon:Icons.add, onPressed: (){
        //go to the add page
        Navigator.pushNamed(context, '/add-slide');
      }));
  }
}