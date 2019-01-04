import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
      ),
      body:Text("Home"),
      floatingActionButton: IconButton( icon: Icon(Icons.add), onPressed:(){
        //go to the add page
        Navigator.pushNamed(context, '/add-slide');
      }),
    );
  }
}