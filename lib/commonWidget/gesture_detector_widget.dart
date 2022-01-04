import 'dart:math';

import 'package:flutter/material.dart';

typedef MatrixGestureDetectorCallback = void Function(
    Matrix4 matrix,
    Matrix4 translationDeltaMatrix,
    Matrix4 scaleDeltaMatrix,
    Matrix4 rotationDeltaMatrix);

typedef _OnUpdate<T> = T Function(T oldValue, T newValue);

class _ValueUpdater<T> {
  final _OnUpdate<T> onUpdate;
  T value;

  _ValueUpdater({
    required this.value,
    required this.onUpdate,
  });

  T update(T newValue) {
    T updated = onUpdate(value, newValue);
    value = newValue;
    return updated;
  }
}

class GestureDetectorWidget extends StatefulWidget {
  final MatrixGestureDetectorCallback onMatrixUpdate;
  final Widget child;
  final bool? shouldTranslate;
  final bool? shouldScale;
  final bool? shouldRotate;
  final Alignment? focalPointAlignment;
  final GestureTapCallback? onTap;

  const GestureDetectorWidget({
    Key? key,
    required this.onMatrixUpdate,
    required this.child,
    this.shouldTranslate = true,
    this.shouldScale = true,
    this.shouldRotate = true,
    this.focalPointAlignment, this.onTap,
  }) : super(key: key);

  @override
  _GestureDetectorWidgetState createState() => _GestureDetectorWidgetState();
}

class _GestureDetectorWidgetState extends State<GestureDetectorWidget> {
  Matrix4 translationDeltaMatrix = Matrix4.identity();
  Matrix4 scaleDeltaMatrix = Matrix4.identity();
  Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  _ValueUpdater<Offset> translationUpdater = _ValueUpdater(
    value: Offset.zero,
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );
  _ValueUpdater<double> scaleUpdater = _ValueUpdater(
    value: 1.0,
    onUpdate: (oldVal, newVal) => newVal / oldVal,
  );
  _ValueUpdater<double> rotationUpdater = _ValueUpdater(
    value: 0.0,
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );

  void onScaleStart(ScaleStartDetails details) {
    translationUpdater.value = details.focalPoint;
    scaleUpdater.value = 1.0;
    rotationUpdater.value = 0.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    translationDeltaMatrix = Matrix4.identity();
    scaleDeltaMatrix = Matrix4.identity();
    rotationDeltaMatrix = Matrix4.identity();

    // handle matrix translating
    if (widget.shouldTranslate!) {
      Offset translationDelta = translationUpdater.update(details.focalPoint);
      translationDeltaMatrix = _translate(translationDelta);
      matrix = translationDeltaMatrix * matrix;
    }

    final focalPointAlignment = widget.focalPointAlignment;
    final focalPoint = focalPointAlignment == null ?
    details.localFocalPoint :
    focalPointAlignment.alongSize(context.size!);

    // handle matrix scaling
    if (widget.shouldScale! && details.scale != 1.0) {
      double scaleDelta = scaleUpdater.update(details.scale);
      scaleDeltaMatrix = _scale(scaleDelta, focalPoint);
      matrix = scaleDeltaMatrix * matrix;
    }

    // handle matrix rotating
    if (widget.shouldRotate! && details.rotation != 0.0) {
      double rotationDelta = rotationUpdater.update(details.rotation);
      rotationDeltaMatrix = _rotate(rotationDelta, focalPoint);
      matrix = rotationDeltaMatrix * matrix;
    }

    widget.onMatrixUpdate(
        matrix, translationDeltaMatrix, scaleDeltaMatrix, rotationDeltaMatrix);
  }


  Matrix4 _translate(Offset translation) {
    var dx = translation.dx;
    var dy = translation.dy;
    return Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  Matrix4 _scale(double scale, Offset focalPoint) {
    var dx = (1 - scale) * focalPoint.dx;
    var dy = (1 - scale) * focalPoint.dy;
    return Matrix4(scale, 0, 0, 0, 0, scale, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  Matrix4 _rotate(double angle, Offset focalPoint) {
    var c = cos(angle);
    var s = sin(angle);
    var dx = (1 - c) * focalPoint.dx + s * focalPoint.dy;
    var dy = (1 - c) * focalPoint.dy - s * focalPoint.dx;
    return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:widget.onTap,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: widget.child,
    );
  }
}
