import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../elements/btn-cancel.dart';

import '../elements/btn-round-icon.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/app-model.dart';

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
        body: ScopedModelDescendant<AppModel>(
          builder:( context, widget, model ){
            if( model.preview is ImageSlide ){
              return _ImageSlidePreview( image: model.preview as ImageSlide );
            }

            return Container();
          }
        ),
        floatingActionButton: RoundIconButton(icon:Icons.check,onPressed:(){
          Navigator.popUntil(context, ( route ){
            return route.isFirst;
          });
        }),
      );
  }
}

class _ImageSlidePreview extends StatelessWidget {
  _ImageSlidePreview({Key key, @required this.image})
      : super(key: key);
  final ImageSlide image;

  @override
  Widget build(BuildContext context) {
    return Image.memory( image.data );
  }
}
