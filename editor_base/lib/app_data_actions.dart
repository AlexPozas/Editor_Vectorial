// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
}

// Gestiona la llista d'accions per poder desfer i refer
class ActionManager {
  List<Action> actions = [];
  int currentIndex = -1;

  void register(Action action) {
    // Elimina les accions que estan després de l'índex actual
    if (currentIndex < actions.length - 1) {
      actions = actions.sublist(0, currentIndex + 1);
    }
    actions.add(action);
    currentIndex++;
    //action.redo();
  }

  void undo() {
    if (currentIndex >= 0) {
      actions[currentIndex].undo();
      currentIndex--;
    }
  }

  void redo() {
    if (currentIndex < actions.length - 1) {
      currentIndex++;
      actions[currentIndex].redo();
    }
  }
}

class ActionSetDocWidth implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocWidth(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(value, appData.docSize.height);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionSetDocHeight implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocHeight(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(appData.docSize.width, value);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }
}

class ActionMoveShape implements Action {
  final AppData appData;
  final Offset newPosition;
  final int shapeSelected;
  Shape shape = Shape();

  ActionMoveShape(this.appData, this.newPosition, this.shapeSelected) {
    shape = appData.shapesList[shapeSelected];
  }

  @override
  void redo() {
    shape.initialPosition = shape.position;
    shape.position = newPosition;
    appData.getRecuadre(appData.shapesList[appData.shapeSelected]);
    appData.forceNotifyListeners();
    print("MoveShape");
  }

  @override
  void undo() {
    shape.position = shape.initialPosition;
    appData.getRecuadre(appData.shapesList[appData.shapeSelected]);
    appData.forceNotifyListeners();
  }
}

class ActionChangeBackgroundColor implements Action {
  final AppData appData;
  final Color oldColor;
  final Color newColor;

  ActionChangeBackgroundColor(this.appData, this.oldColor, this.newColor);

  @override
  void undo() {
    appData.backgroundColor = oldColor;
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.backgroundColor = newColor;
    appData.notifyListeners();
  }
}

class ActionDeleteShape implements Action {
  final AppData appData;
  final int id;
  final Shape shape;

  ActionDeleteShape(this.appData, this.id, this.shape);

  @override
  void undo() {
    appData.shapesList.add(shape);
  }

  @override
  void redo() {
    appData.shapesList.remove(shape);
  }
}

class ActionChangeClosed implements Action {
  final AppData appData;
  final bool newValue;
  final int id;

  ActionChangeClosed(this.appData, this.id, this.newValue);

  @override
  void undo() {
    appData.shapesList[id].setClosed(!newValue);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setClosed(newValue);
    appData.notifyListeners();
  }
}

class ActionChangePosition implements Action {
  final AppData appData;
  final Offset oldPosition;
  final Offset newPosition;
  final int id;

  ActionChangePosition(
      this.appData, this.id, this.oldPosition, this.newPosition);

  @override
  void undo() {
    appData.shapesList[id].setPosition(oldPosition);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setPosition(newPosition);
    appData.notifyListeners();
  }
}

class ActionChangeStrokeWidth implements Action {
  final AppData appData;
  final double oldValue;
  final double newValue;
  final int id;

  ActionChangeStrokeWidth(this.appData, this.id, this.oldValue, this.newValue);

  @override
  void undo() {
    appData.shapesList[id].setStrokeWidth(oldValue);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setStrokeWidth(newValue);
    appData.notifyListeners();
  }
}

class ActionChangeStrokeColor implements Action {
  final AppData appData;
  final Color oldValue;
  final Color newValue;
  final int id;

  ActionChangeStrokeColor(this.appData, this.id, this.oldValue, this.newValue);

  @override
  void undo() {
    appData.shapesList[id].setStrokeColor(oldValue);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setStrokeColor(newValue);
    appData.notifyListeners();
  }
}

class ActionChangeFillColor implements Action {
  final AppData appData;
  final Color oldValue;
  final Color newValue;
  final int id;

  ActionChangeFillColor(this.appData, this.id, this.oldValue, this.newValue);

  @override
  void undo() {
    appData.shapesList[id].setFillColor(oldValue);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setFillColor(newValue);
    appData.notifyListeners();
  }
}
