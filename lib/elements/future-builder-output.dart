import 'package:flutter/material.dart';


Widget Function(BuildContext, AsyncSnapshot<E>) futureBuilderOutput<E>( Function(E) onOutput ){
  return ( context, snapshot ){
    if (snapshot.hasError) {
      return Text(snapshot.error);
    } else if (!snapshot.hasData) {
      return CircularProgressIndicator();
    } else {
      return onOutput(snapshot.data);
    }
  };
}