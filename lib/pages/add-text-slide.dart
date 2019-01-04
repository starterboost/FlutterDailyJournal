import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../elements/btn-cancel.dart';

class AddTextSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Enter Text"),
        actions: [
          CancelButton(onPressed:(){
            Navigator.popUntil(context, ( route ){
              if( route.isFirst ){
                return true;
              }else{
                return false;
              }
            });
          })
        ]
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _TextInput(onSubmit:(text){
              Navigator.pushNamed(context, "/add-text-color-slide");
            })
          ])
    );
  }
}

class AddTextColorSlidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Pick a Colour"),
        actions: [
          CancelButton(onPressed:(){
            Navigator.popUntil(context, ( route ){
              if( route.isFirst ){
                return true;
              }else{
                return false;
              }
            });
          })
        ]
      ),
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

class _TextInput extends StatefulWidget {
  _TextInput({Key key, this.onSubmit}):super(key:key);
  TextCallback onSubmit;

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
       child: TextField(
        autofocus: true,
        onEditingComplete: (){
          print("complete");
        },
        onSubmitted: widget.onSubmit,
       ),
    );
  }
}

class _AddTextSlideButton extends StatelessWidget {
  _AddTextSlideButton({Key key, this.text, @required this.onPressed})
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
