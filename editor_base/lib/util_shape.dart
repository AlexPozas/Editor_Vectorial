import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';

class Shape {
  Offset position = const Offset(0, 0);
  List<Offset> vertices = [];
  double strokeWidth = 1;
  Color strokeColor = CDKTheme.black;
  bool closed = false;
  Offset initialPosition = Offset(0, 0);
  Color fillColor = CDKTheme.black;

  Shape();

  void setFillColor(Color c) {
    fillColor = c;
  }

  void setClosed(bool close) {
    closed = close;
  }

  void setStrokeColor(Color newColor) {
    strokeColor = newColor;
  }

  void setInitialPosition(Offset newIniPosition) {
    initialPosition = newIniPosition;
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
  }

  void changeAllPropieties(Shape changeTo) {
    setPosition(changeTo.position);
    setStrokeColor(changeTo.strokeColor);
    setStrokeWidth(changeTo.strokeWidth);
    setInitialPosition(changeTo.initialPosition);
    vertices.clear();
    vertices = changeTo.vertices;
  }
}
