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
import 'package:untitled/api_service.dart';
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
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();
  late ArCoreController arCoreController;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
      );
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();
  late ArCoreController arCoreController;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cerealis'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: _takeScreenshot,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                openDialog(context);
              },
            )
          ],
        ),
        body: Screenshot(
            controller: _screenshotController,
            child: Container(
                child: Center(
                    child: ArCoreView(
                      onArCoreViewCreated: _onArCoreViewCreated,
                    )
                )
            )
        )
    );
  }


    void _takeScreenshot() async {
    final uint8List = await _screenshotController.capture(delay: Duration(milliseconds: 10));
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


  Future<void> openDialog(BuildContext context) async {
    return await showDialog(context: context,
    builder: (context){
      return AlertDialog(
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                validator: (value){
                  return value!.isNotEmpty ? null : "Invalid field";
                },
                decoration: InputDecoration(hintText: "Name"),
              ),
              TextFormField(
                controller: email,
                validator: (value){
                  return value!.isNotEmpty ? null : "Invalid field";
                },
                decoration: InputDecoration(hintText: "Email"),
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: (){
              if(_formKey.currentState!.validate()){
                postCustomer(name: name.text, email: email.text).whenComplete(() => Navigator.pop(context));
              }
            })
        ],
      );
    });
  }

  Future<bool> postCustomer({required String name, required String email}) async {
    return await ApiService.postUser(name: name, email: email);
  }
}
