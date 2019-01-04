import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../elements/btn-cancel.dart';

class AddPreviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text("Preview"), actions: [
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
        body: Text("Preview"),
        floatingActionButton: IconButton(icon:Icon(Icons.check),onPressed:(){
          Navigator.popUntil(context, ( route ){
            return route.isFirst;
          });
        }),
      );
  }
}

class _AddPreviewButton extends StatelessWidget {
  _AddPreviewButton({Key key, this.text, @required this.onPressed})
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
