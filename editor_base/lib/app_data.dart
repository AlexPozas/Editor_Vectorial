import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';

import 'util_shape.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';

import 'package:xml/xml.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  late BuildContext cont;
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape(); //shapesList
  List<Shape> removedShapesList = [];
  double strokeWeight = 1;
  List<Shape> shapesList = [];
  int shapeSelected = -1;
  bool recuadre = false;
  Color backgroundColor = CDKTheme.transparent;
  Offset mouseToPolygonDifference = Offset.zero;
  List<double> recuadreP = [];
  bool closeShape = false;
  Color strokeColor = CDKTheme.black;
  Color shapeFillColor = CDKTheme.transparent;
  int shapeSelectedPrevious = -1;
  bool multiclick = true;

  String fileName = "";
  String directoryPath = "";
  bool readyExample = false;
  late dynamic dataExample;
  Color oldBackColor = Colors.transparent;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setCloseShape(bool value) {
    closeShape = value;
    if (shapeSelected > -1) {
      shapesList[shapeSelected].closed = value;
      actionManager.register(ActionChangeClosed(this, shapeSelected, value));
    }
    notifyListeners();
  }

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void setShapeSelected(int index) {
    shapeSelected = index;

    if (index > -1) {
      getRecuadre(shapesList[index]);
      newShape.strokeWidth = shapesList[index].strokeWidth;
      strokeColor = shapesList[index].strokeColor;
    }
    notifyListeners();
  }

  void moveLastVertice(Offset point) {
    if (newShape.getVertices().length >= 2) {
      newShape.getVertices().removeLast();
    }
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  Future<void> addNewShapeFromClipboard() async {
    try {
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      String? t = clipboardData?.text;

      if (clipboardData != null) {
        Shape newShape = Shape.fromMap(json.decode(t!) as Map<String, dynamic>);
        shapesList.add(newShape);
        //actionManager.register(ActionAddNewShape(this, newShape));
      } else {}
    } catch (e) {
      print('Error al obtener datos del portapapeles: $e');
    }

    notifyListeners();
  }

  void addNewSquare(Offset position) {
    newShape.setPosition(position);
    newShape.setInitialPosition(newShape.position);
    notifyListeners();
  }

  void addSquare(Offset position) {
    newShape.addRelativePoint(Offset(position.dx, newShape.initialPosition.dy));
    newShape.addRelativePoint(Offset(position.dx, position.dy));
    newShape.addRelativePoint(Offset(newShape.initialPosition.dx, position.dy));
    newShape.addRelativePoint(
        Offset(newShape.initialPosition.dx, newShape.initialPosition.dy));
    notifyListeners();
  }

  void setFillColor(Color fillcolor) {
    if (shapeSelected > -1) {
      actionManager.register(ActionChangeFillColor(
          this, shapeSelected, shapesList[shapeSelected].fillColor, fillcolor));
    }

    shapeFillColor = fillcolor;
    newShape.setFillColor(fillcolor);
    notifyListeners();
  }

  void addNewShape(Offset position) {
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    newShape.setInitialPosition(newShape.position);
    newShape.setClosed(closeShape);
    newShape.setFillColor(shapeFillColor);
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      newShape.setStrokeColor(strokeColor);
      newShape.setStrokeWidth(strokeWeight);
      shapesList.add(newShape);

      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = ShapeDrawing();
      notifyListeners();
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    strokeWeight = value;
    notifyListeners();
  }

  void setShapeStrokeWidth(double newValue) {
    actionManager.register(ActionChangeStrokeWidth(
        this, shapeSelected, shapesList[shapeSelected].strokeWidth, newValue));
    shapesList[shapeSelected].strokeWidth = newValue;
    newShape.strokeWidth = newValue;
    getRecuadre(shapesList[shapeSelected]);
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    actionManager
        .register(ActionChangeBackgroundColor(this, oldBackColor, color));
    backgroundColor = color;
    notifyListeners();
  }

  void setStrokeColor(Color color) {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      actionManager.register(ActionChangeStrokeColor(
          this, shapeSelected, shapesList[shapeSelected].strokeColor, color));
    }
    newShape.setStrokeColor(color);
    strokeColor = color;

    notifyListeners();
  }

  Future<void> selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    shapeSelectedPrevious = shapeSelected;
    shapeSelected = -1;

    setShapeSelected(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  void setShapePosition(Offset position) {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      shapesList[shapeSelected].setPosition(position);
      actionManager.register(ActionChangePosition(
          this, shapeSelected, shapesList[shapeSelected].position, position));

      notifyListeners();
    }
  }

  void moveSquareVertices(Offset point) {
    if (newShape.getVertices().length >= 4) {
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
    }
    addSquare(point);
  }

  void deleteShapeFromList(int shapeIndex) {
    //shapesList.remove(shapesList[shapeIndex]);
    actionManager.register(
        ActionDeleteShape(this, shapeIndex, shapesList[shapeSelected]));
    setShapeSelected(-1);
    notifyListeners();
  }

  Future<void> copyToClipboard() async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(shapesList[shapeSelected].toMap())));
  }

  void updateShapePosition(Offset delta) {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      shapesList[shapeSelected].position += delta;
      notifyListeners();
    } else {
      setShapeSelected(-1);
      notifyListeners();
    }
  }

  void addNewEllipseToShapeList() {
    if (newShape.vertices.length >= 2) {
      ShapeEllipsis shape = ShapeEllipsis();
      shape.setAttributesFromOtherShape(newShape);
      shape.setStrokeColor(strokeColor);
      double strokeWidthConfig = shape.strokeWidth;
      shapesList.add(newShape);
      actionManager.register(ActionAddNewShape(this, shape));

      newShape = ShapeDrawing();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  Future<void> loadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        if (!file.existsSync()) {
          print("El archivo no existe.");
          return;
        }

        String resultString = await file.readAsString();
        try {
          Map<String, dynamic> jsonData = jsonDecode(resultString);

          if (jsonData.containsKey('drawings')) {
            List<dynamic> drawings = jsonData['drawings'];
            for (var item in drawings) {
              Shape newShape = Shape.fromMap(item);
              shapesList.add(newShape);
              notifyListeners();
            }
          } else {
            print("El archivo no contiene la clave 'drawings'.");
          }
        } catch (e) {
          print("Error al decodificar el JSON: $e");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveFileToJSON() async {
    if (directoryPath == "") {
      await getDirectoryPath();
    }
    List<dynamic> JSONShapesList = [];
    for (int shape = 0; shape < shapesList.length; shape++) {
      JSONShapesList.add(jsonEncode(shapesList[shape].toMap()));
    }

    String jsonString = '{"drawings": $JSONShapesList}';

    File file = File("$directoryPath/$fileName.json");
    print(file.path);
    IOSink writer;

    try {
      writer = file.openWrite();

      writer.write(jsonString);

      print('DONE!');
    } catch (e) {
      print('Error al escribir: $e');
    }
  }

  Future<void> getDirectoryPath() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      directoryPath = path;
    }
    print(directoryPath);
    notifyListeners();
  }

  saveToSVG() async {
    if (directoryPath == "") {
      await getDirectoryPath();
    }
    List<dynamic> JSONShapesList = [];
    for (int shape = 0; shape < shapesList.length; shape++) {
      JSONShapesList.add(jsonEncode(shapesList[shape].toMap()));
    }

    String jsonString = '{"drawings": $JSONShapesList}';

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  }

  createSvgFileWithShapes(List<Shape> shapes) {
    final svgDocument = XmlDocument([
      XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
      XmlElement(XmlName('svg'), [
        XmlAttribute(XmlName('width'),
            docSize.width.toString()), // Ajusta el ancho del SVG
        XmlAttribute(XmlName('height'),
            docSize.height.toString()), // Ajusta la altura del SVG
      ], [
        for (var shape in shapes)
          if (shape is ShapeEllipsis)
            XmlElement(XmlName('ellipse'), [
              XmlAttribute(XmlName('cx'),
                  '${shape.vertices[0].dx + shape.position.dx}'), // Posicion de inicio (x)
              XmlAttribute(XmlName('cy'),
                  '${shape.vertices[1].dy + shape.position.dy}'), // Posicion de inicio (y)
              XmlAttribute(XmlName('rx'),
                  '${shape.vertices[1].dx / 2 - shape.vertices[0].dx / 2}'), // Radio de x
              XmlAttribute(XmlName('ry'),
                  '${shape.vertices[1].dy / 2 - shape.vertices[0].dy / 2}'), // Radio de y
              XmlAttribute(XmlName('stroke'),
                  '#${shape.strokeColor.value.toRadixString(16).substring(2)}'), // Color de la línea
              XmlAttribute(XmlName('stroke-width'),
                  shape.strokeWidth.toString()), // Grosor de la línea
              XmlAttribute(
                  XmlName('stroke-opacity'),
                  (int.parse('0x${shape.strokeColor.value.toRadixString(16).substring(0, 2)}') /
                          255)
                      .toString() /*(hex/255).toString()*/), // Opacidad de la línea
              XmlAttribute(
                  XmlName('fill'),
                  shape.fillColor == Colors.transparent
                      ? 'none'
                      : '#${shape.fillColor.value.toRadixString(16).substring(2)}') // Color de relleno (si tiene)
            ])
          else
            XmlElement(
                shape.closed ? XmlName("polygon") : XmlName("polyline"), [
              XmlAttribute(
                  XmlName('points'),
                  shape.vertices
                      .map((e) =>
                          '${e.dx + shape.position.dx},${e.dy + shape.position.dy}')
                      .join(' ')), // vertices
              XmlAttribute(XmlName('stroke'),
                  '#${shape.strokeColor.value.toRadixString(16).substring(2)}'), // Color de la línea
              XmlAttribute(XmlName('stroke-width'),
                  shape.strokeWidth.toString()), // Grosor de la línea
              XmlAttribute(
                  XmlName('stroke-opacity'),
                  (int.parse('0x${shape.strokeColor.value.toRadixString(16).substring(0, 2)}') /
                          255)
                      .toString()), // Opacidad de la línea
              XmlAttribute(
                  XmlName('fill'),
                  shape.fillColor == Colors.transparent
                      ? 'none'
                      : '#${shape.fillColor.value.toRadixString(16).substring(2)}') // Color de relleno (si tiene)
            ]),
      ]),
    ]);

    final svgString = svgDocument.toXmlString(pretty: true);

    // Guarda el contenido SVG en un archivo
    final file = File('dataarchivo.svg');
    file.writeAsStringSync(svgString);
  }

  void getRecuadre(Shape shape) {
    if (shapesList.contains(shape)) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = 0;
      double maxY = 0;

      // Encuentra las coordenadas extremas del rectángulo que rodea a la forma
      for (Offset vertex in shape.vertices) {
        double x = vertex.dx + shape.position.dx;
        double y = vertex.dy + shape.position.dy;

        // Se actualiza minX con el valor mínimo entre x y el valor actual de minX.
        minX = x < minX ? x : minX;

        // Se actualiza minY con el valor mínimo entre y y el valor actual de minY.
        minY = y < minY ? y : minY;

        // Se actualiza maxX con el valor máximo entre x y el valor actual de maxX.
        maxX = x > maxX ? x : maxX;

        // Se actualiza maxY con el valor máximo entre y y el valor actual de maxY.
        maxY = y > maxY ? y : maxY;
      }

      // Añade el grosor del trazo para asegurar que el rectángulo lo rodea completamente
      minX -= shape.strokeWidth / 2;
      minY -= shape.strokeWidth / 2;
      maxX += shape.strokeWidth / 2;
      maxY += shape.strokeWidth / 2;

      recuadreP.clear();
      recuadreP.addAll([minX, maxX, minY, maxY]);
      notifyListeners();
    }
  }
}
