import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../model/app-model.dart';
import '../elements/btn-round-icon.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context,widget,model){
        return Scaffold(
          appBar: new AppBar(
            title: new Text("Home"),
          ),
          body: ListView.builder( itemCount: model.images.length, 
            itemBuilder: (context, index){
              return Image.memory( model.images[index] );
          }),
          floatingActionButton: RoundIconButton( icon:Icons.add, onPressed: (){
            //go to the add page
            Navigator.pushNamed(context, '/add-slide');
          }));
      }
    );
  }
}