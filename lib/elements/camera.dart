import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

import './future-builder-output.dart';

typedef FileCallback = Function( File );
class CameraWidget extends StatelessWidget {
  CameraWidget({Key key, this.onCapture}) : super(key: key);
  final FileCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: availableCameras(),
        builder: futureBuilderOutput((data) {
          return _CamerasViewWidget(cameras: data,onCapture:onCapture);
        }));
  }
}

class _CamerasViewWidget extends StatefulWidget {
  _CamerasViewWidget({Key key, @required this.cameras, @required this.onCapture}) : super(key: key);
  final List<CameraDescription> cameras;
  final FileCallback onCapture;

  @override
  _CamerasViewWidgetState createState() => _CamerasViewWidgetState();
}

class _CamerasViewWidgetState extends State<_CamerasViewWidget> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return InkWell(
        onTap: () async {
          print('onTap');
          Directory refTempDir = await getTemporaryDirectory();
          String pathDir = refTempDir.path;
          String name = DateTime.now().microsecondsSinceEpoch.toString();

          String pathOutput = "$pathDir/$name";
          await controller.takePicture( pathOutput );
          //callback to say photo has been taken
          widget.onCapture( File( pathOutput ) );
        },
        child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller)));
  }
}
