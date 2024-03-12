import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';

abstract class Shape {
  Offset position = const Offset(0, 0);
  String type = "shape";
  Size scale = const Size(1, 1);
  Color strokeColor = CDKTheme.black;
  Color fillColor = Colors.transparent;
  bool closed = false;
  double strokeWidth = 1;
  Offset initialPosition = Offset(0, 0);
  Offset endPosition = Offset(0, 0);
  double rotation = 0;
  List<Offset> vertices = [];

  Shape();

  void setType(String t) {
    this.type = t;
  }

  void setFillColor(Color c) {
    fillColor = c;
  }

  void setClosed(bool close) {
    closed = close;
  }

  void setStrokeWidth(double newWeight) {
    strokeWidth = newWeight;
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

  void setScale(Size newScale) {
    scale = newScale;
  }

  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

/////////
  List getVertices() {
    return vertices;
  }

//////////////
  void changeAllPropieties(Shape changeTo) {
    setPosition(changeTo.position);
    setScale(changeTo.scale);
    setStrokeColor(changeTo.strokeColor);
    setStrokeWidth(changeTo.strokeWidth);
    setInitialPosition(changeTo.initialPosition);
    setRotation(changeTo.rotation);
    vertices.clear();
    vertices = changeTo.vertices;
  }

  // Converteix la forma en un mapa per serialitzar
  Map<String, dynamic> toMap() {
    return {
      'type': 'shape_drawing',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': strokeWidth,
        'strokeColor': strokeColor.value,
        'fillColor': fillColor.value,
        'closed': closed,
      }
    };
  }

  // Crea una forma a partir d'un mapa
  static Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_drawing') {
      throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = ShapeDrawing()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setStrokeColor(Color(objectMap['strokeColor']))
      ..setFillColor(Color(objectMap['fillColor']))
      ..setClosed(objectMap['closed']);

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }
    return shape;
  }
}

////////////////////
class ShapeDrawing extends Shape {}

class ShapeLine extends Shape {}

class ShapeMultiline extends Shape {}

class ShapeRectangle extends Shape {}

class ShapeEllipsis extends Shape {
  void setAttributesFromOtherShape(Shape oldShape) {
    this.strokeColor = oldShape.strokeColor;
    this.endPosition = oldShape.endPosition;
    this.scale = oldShape.scale;
    this.position = oldShape.position;
    this.initialPosition = oldShape.initialPosition;
    this.fillColor = oldShape.fillColor;
    this.strokeWidth = oldShape.strokeWidth;
    this.vertices = oldShape.vertices;
    this.rotation = oldShape.rotation;
  }
}
