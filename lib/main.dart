import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart'
    show
        ArCoreController,
        ArCoreCube,
        ArCoreCylinder,
        ArCoreMaterial,
        ArCoreNode,
        ArCoreReferenceNode,
        ArCoreSphere,
        ArCoreView;
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('ARCORE IS AVAILABLE?');
  print(await ArCoreController.checkArCoreAvailability());
  print('\nAR SERVICES INSTALLED?');
  print(await ArCoreController.checkIsArCoreInstalled());
  runApp(HelloWorld());
}

class HelloWorld extends StatefulWidget {
  @override
  _HelloWorldState createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  final _screenshotController = ScreenshotController();
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xfff5f5f5),
        appBar: AppBar(
          title: const Text('Cerealis'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: _takeScreenshot,
            ),
          ],
        ),
        body: Screenshot(
          controller: _screenshotController,
          child: Container(
            color: Colors.white,
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
            )
          )
        ),
      ),
    );
  }

  void _takeScreenshot() async {
    final uint8List = await _screenshotController.capture();
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/image.png');
    if(uint8List != null) {
      await file.writeAsBytes(uint8List);
      await Share.shareFiles([file.path]);
    }
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    _addMonkey(controller);
  }

  void _addMonkey(ArCoreController controller) {
    final node = ArCoreReferenceNode(
        name: 'SnakeCentered',
        object3DFileName: 'SnakeCentered.sfb',
        position: vector.Vector3(0, 0, 0),
        scale: vector.Vector3(0.1, 0.1, 0.1));
    print("affichage singe");
    controller.addArCoreNode(node);
  }

  void _addSphere(ArCoreController controller) {
    final material = ArCoreMaterial(color: Color.fromARGB(120, 66, 134, 244));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(node);
  }

  void _addCylindre(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,
      position: vector.Vector3(0.0, -0.5, -2.0),
    );
    controller.addArCoreNode(node);
  }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
