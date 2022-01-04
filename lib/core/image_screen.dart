import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_demo/commonWidget/gesture_detector_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageZoom extends StatefulWidget {
  const ImageZoom({Key? key}) : super(key: key);

  @override
  _ImageZoomState createState() => _ImageZoomState();
}

class _ImageZoomState extends State<ImageZoom> {
  Matrix4 matrixImage = Matrix4.identity();
  Matrix4 matrixText = Matrix4.identity();
  final textController = TextEditingController();
  String? _galleryImage;
  String? _cameraImage;
  bool? _showFrontSide;
  String? text;
  bool? isTextDone;
  String? textstyle;
  var list = [
    "RobotoBlack",
    "RobotoBold",
    "RobotoBlackItalic",
    "RobotoBoldItalic",
    "RobotoItalic",
    "RobotoLight",
    "RobotoLightItalic",
    "RobotoMedium",
    "RobotoMediumItalic",
    "RobotoRegular",
    "RobotoThin",
    "RobotoThinItalic"
  ];

  @override
  void initState() {
    super.initState();
    _showFrontSide = true;
    isTextDone = false;
  }

  Future pickCameraImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    setState(() {
      _cameraImage = image.path;
    });
  }

  Future pickGalleryImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    setState(() {
      _galleryImage = image.path;
    });
  }

  void _switchCard() {
    setState(() {
      _showFrontSide = !_showFrontSide!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
            child: MaterialButton(
              onPressed: () {
                _showPicker(context);
              },
              child: const Text(
                "Select Photo",
                style: TextStyle(color: Colors.black),
              ),
              color: Colors.amber,
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    controller: textController,
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      setState(() {
                        isTextDone = true;
                        text = textController.text;
                      });
                      textController.clear();
                    })
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.amber,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GestureDetectorWidget(
                onMatrixUpdate: (Matrix4 matrix4,
                    Matrix4 translationDeltaMatrix,
                    Matrix4 scaleDeltaMatrix,
                    Matrix4 rotationDeltaMatrix) {
                  setState(() {
                    matrixImage = matrix4;
                  });
                },
                onTap: _switchCard,
                child: Transform(
                  transform: matrixImage,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: __transitionBuilder,
                    layoutBuilder: (widget, list) =>
                        Stack(children: [widget!, ...list]),
                    child: _showFrontSide! ? _buildFront() : _buildRear(),
                    switchInCurve: Curves.easeInBack,
                    switchOutCurve: Curves.easeInBack.flipped,
                  ),
                )),
          ),
          GestureDetectorWidget(
            onMatrixUpdate: (Matrix4 matrix4, Matrix4 translationDeltaMatrix,
                Matrix4 scaleDeltaMatrix, Matrix4 rotationDeltaMatrix) {
              setState(() {
                matrixText = matrix4;
              });
            },
            child: Transform(
              transform: matrixText,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: isTextDone!
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                                elevation: 16,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Center(
                                          child: Text("Select Font Style")),
                                      const SizedBox(height: 20),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: list.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Center(
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          textstyle =
                                                              list[index];
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          Text(list[index]))),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          text!,
                          style: TextStyle(
                              fontSize: 34,
                              fontFamily: textstyle ?? "RobotoThin"),
                        ),
                      )
                    : const Text("Enter Your Text",
                        style: TextStyle(fontSize: 34)),
              ),
            ),
          )
        ],
      ),
    );
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
                        pickGalleryImage(ImageSource.gallery);
                      }
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    pickCameraImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
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
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  Widget __buildLayout({Key? key, Widget? child, Color? backgroundColor}) {
    return Container(
      key: key,
      child: child,
    );
  }

  Widget _buildFront() {
    return __buildLayout(
      key: const ValueKey(true),
      child: Container(
          alignment: Alignment.center,
          child: _galleryImage != null
              ? Container(
                  alignment: Alignment.center,
                  child: Image.file(File(_galleryImage!)),
                )
              : Container(
                  alignment: Alignment.center,
                  child: const Text("Please Select Photo From Gallery"),
                )),
    );
  }

  Widget _buildRear() {
    return __buildLayout(
      key: const ValueKey(false),
      child: Container(
          alignment: Alignment.center,
          child: _cameraImage != null
              ? Container(
                  alignment: Alignment.center,
                  child: Image.file(File(_cameraImage!)),
                )
              : Container(
                  alignment: Alignment.center,
                  child: const Text("Please Select Photo Camera"),
                )),
    );
  }
}
