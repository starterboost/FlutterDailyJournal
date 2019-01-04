import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../elements/btn-cancel.dart';

class AddImageSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text("Select Image"), actions: [
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
            return Container(
              decoration: BoxDecoration(color:[
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow
              ][index % 4]),
              child: InkWell( 
                onTap: (){
                  print("Selected child $index");
                  Navigator.pushNamed( context, "/add-preview" );
                },
                child:Center(
                child: Text(
                  'Item $index',
                  style: Theme.of(context).textTheme.headline,
                ),
            )));
          }),
        ));
  }
}

class _AddImageSlideButton extends StatelessWidget {
  _AddImageSlideButton({Key key, this.text, @required this.onPressed})
      : super(key: key);
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(color: Colors.red),
        child: Center(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(Icons.add),
            Container(width: 10),
            Text(this.text)
          ]),
        )),
      ),
    );
  }
}
