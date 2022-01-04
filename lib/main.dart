//2
/*
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Test(),
    );
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String? _image;

  Future pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    setState(() {
      _image = image.path;
    });
  }

  Matrix4? transform;
  @override
  void initState() {
    super.initState();
    transform = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        child: MaterialButton(
          onPressed: ()  {
            _showPicker(context);
          },
          child: const Text(
            "Select Photo",
            style: TextStyle(color: Colors.black),
          ),
          color: Colors.amber,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: MatrixGestureDetector(
          onMatrixUpdate: (m, rs, ry, rx){
            setState(() {
              transform = m;
            });
          },
          child: Container(
            transform: transform,
            height: 200,
            width: 200,
            child: _image != null ? Container(
              alignment: Alignment.center,
              child: Image.file(
                  File(_image!)
              ),
            ) : Container(
              alignment: Alignment.center,
              child: const Text("Please Select Photo"),
            ),
          ),
        ),
      ),
    );
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () async {
                      bool _permissionReady = await _checkPermission();
                      if (!_permissionReady) {
                        _checkPermission().then((hasGranted) {
                          _permissionReady = hasGranted;
                        });
                      } else {
                        pickImage(ImageSource.gallery);
                      }
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<bool> _checkPermission() async {
    var permission = Permission.storage;
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}*/
//3 done with plugin
/*import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ZoomableWidget(),
    );
  }
}

class ZoomableWidget extends StatefulWidget {
  const ZoomableWidget({
    Key? key,
  }) : super(key: key);

  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();
  bool? _showFrontSide;
  bool? _flipXAxis;

  @override
  void initState() {
    super.initState();
    _showFrontSide = true;
    _flipXAxis = true;
  }

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
        setState(() {
          matrix = m;
        });
      },
     */ /* child: Transform(
        transform: matrix,
        child: Container(
          height: 100,
          width: 100,
          color: Colors.green,
          child: const Icon(
            Icons.print,
            size: 300,
          ),
        ),
      ),*/ /*
      child: Transform(
        transform: matrix,
        child: _buildFlipAnimation(),
      ),
    );
  }

  Widget _buildFlipAnimation() {
    return GestureDetector(
      onTap: _switchCard,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: __transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        child: _showFrontSide! ? _buildFront() : _buildRear(),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
      ),
    );
  }

  void _switchCard() {
    setState(() {
      _showFrontSide = !_showFrontSide!;
    });
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_showFrontSide) != widget!.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: _flipXAxis!
              ? (Matrix4.rotationY(value)..setEntry(3, 0, tilt))
              : (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  Widget _buildFront() {
    return __buildLayout(
      key: const ValueKey(true),
      backgroundColor: Colors.blue,
      faceName: "Front",
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
          child: FlutterLogo(),
        ),
      ),
    );
  }

  Widget _buildRear() {
    return __buildLayout(
      key: ValueKey(false),
      backgroundColor: Colors.blue.shade700,
      faceName: "Rear",
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
          child:
              Center(child: Text("Flutter", style: TextStyle(fontSize: 50.0))),
        ),
      ),
    );
  }

  Widget __buildLayout(
      {Key? key, Widget? child, String? faceName, Color? backgroundColor}) {
    return Container(
      key: key,
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(faceName!.substring(0, 1), style: const TextStyle(fontSize: 80.0)),
      ),
    );
  }
}*/

//4 without plugin

import 'package:flutter/material.dart';
import 'package:image_demo/core/image_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body:ImageZoom(),
      ),
    );
  }
}

/*class ZoomPage extends StatefulWidget {
  const ZoomPage({Key? key}) : super(key: key);

  @override
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Resizeable Demo Image"),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (ScaleStartDetails details) {
            print("===>onScaleStart:" + details.toString());
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            print("===>onScaleUpdate:" + details.toString());
          },
          child: InteractiveViewer(
            minScale: 0.1,
            maxScale: double.infinity,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            constrained: false,
            child: Container(height: 100, width: 100, color: Colors.blue,child: const Icon(Icons.ac_unit_rounded)),
          ),
        ));
  }
}*/
