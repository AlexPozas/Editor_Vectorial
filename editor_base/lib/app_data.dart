import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape(); //shapesList
  double strokeWeight = 1;
  List<Shape> shapesList = [];
  int shapeSelected = -1;
  bool recuadre = false;
  Color backgroundColor = CDKTheme.transparent;

  List<double> recuadreP = [];

  Color strokeColor = CDKTheme.black;

  int shapeSelectedPrevious = -1;

  void forceNotifyListeners() {
    super.notifyListeners();
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

    notifyListeners();
  }

  void selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    setShapeSelected(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  void addNewShape(Offset position) {
    newShape = Shape();
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    newShape.setInitialPosition(newShape.position);
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
      newShape = Shape();
      notifyListeners();
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    strokeWeight = value;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  }

  void setStrokeColor(Color color) {
    newShape.setStrokeColor(color);
    strokeColor = color;
    notifyListeners();
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

      print([minX, maxX, minY, maxY]);

      recuadreP.clear();
      recuadreP.addAll([minX, maxX, minY, maxY]);
      notifyListeners();
    }
  }
}
