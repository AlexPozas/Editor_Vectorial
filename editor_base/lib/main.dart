import 'dart:convert';
import 'dart:io' show Platform;
import 'package:editor_base/app_data_actions.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_data.dart';
import 'layout.dart';

void main() async {
  // For Linux, macOS and Windows, initialize WindowManager
  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    print(e);
  }

  AppData appData = AppData();

  runApp(Focus(
    onKey: (FocusNode node, RawKeyEvent event) {
      bool isControlPressed = (Platform.isMacOS && event.isMetaPressed) ||
          (Platform.isLinux && event.isControlPressed) ||
          (Platform.isWindows && event.isControlPressed);
      bool isShiftPressed = event.isShiftPressed;
      bool isZPressed = event.logicalKey == LogicalKeyboardKey.keyZ;

      if (event is RawKeyDownEvent) {
        if (isControlPressed && isZPressed && !isShiftPressed) {
          appData.actionManager.undo();
          return KeyEventResult.handled;
        } else if (isControlPressed && isShiftPressed && isZPressed) {
          appData.actionManager.redo();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = true;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyC &&
            event.isControlPressed) {
          // Copiar el polígono seleccionado al portapapeles
          try {
            Clipboard.setData(ClipboardData(
                text: jsonEncode(
                    appData.shapesList[appData.shapeSelected].toMap())));
          } catch (e) {
            // Manejar problemas al copiar el polígono al portapapeles
          }
        } else if (event.logicalKey == LogicalKeyboardKey.keyV &&
            event.isControlPressed) {
          // Pegar el polígono desde el portapapeles
          Clipboard.getData('text/plain').then((value) {
            print('Pegar');
            print(value);
            if (value != null) {
              try {
                final parsedMap = jsonDecode(value.text!);
                print(parsedMap);
                if (parsedMap['type'] == 'shape_drawing') {
                  final Shape parsedShape = ShapeDrawing();
                  Shape.fromMap(parsedMap); // Error

                  // Agregar el polígono a la lista de polígonos
                  appData.shapesList.add(parsedShape);
                  appData.actionManager
                      .register(ActionAddNewShape(appData, parsedShape));

                  appData.forceNotifyListeners;

                  print(appData.shapesList);
                }
              } catch (e) {
                print(e);
                // Manejar problemas al pegar el polígono desde el portapapeles
              }
            }
          });
        }
      } else if (event is RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = false;
        }
      }

      return KeyEventResult.ignored;
    },
    child: ChangeNotifierProvider(
      create: (context) => appData,
      child: const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor:
            "systemBlue", // systemBlue, systemPurple, systemPink, systemRed, systemOrange, systemYellow, systemGreen, systemGray
        child: Layout(),
      ),
    ),
  ));
}

// Show the window when it's ready
void showWindow(_) async {
  const size = Size(800.0, 600.0);
  windowManager.setSize(size);
  windowManager.setMinimumSize(size);
  await windowManager.setTitle('Vector Editor');
}
