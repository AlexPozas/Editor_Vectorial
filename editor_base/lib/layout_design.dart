import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';
import 'util_custom_scroll_vertical.dart';
import 'util_custom_scroll_horizontal.dart';

class LayoutDesign extends StatefulWidget {
  const LayoutDesign({super.key});

  @override
  LayoutDesignState createState() => LayoutDesignState();
}

class LayoutDesignState extends State<LayoutDesign> {
  final GlobalKey<UtilCustomScrollHorizontalState> _keyScrollX = GlobalKey();
  final GlobalKey<UtilCustomScrollVerticalState> _keyScrollY = GlobalKey();
  Offset _scrollCenter = const Offset(0, 0);
  bool _isMouseButtonPressed = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initShaders();
  }

  Future<void> initShaders() async {
    await LayoutDesignPainter.initShaders();
    setState(() {});
  }

  // Retorna l'area de scroll del document
  Size _getScrollArea(AppData appData) {
    return Size(((appData.docSize.width * appData.zoom) / 100) + 50,
        ((appData.docSize.height * appData.zoom) / 100) + 50);
    // Force 50 pixels padding (to show 25 pixels rulers)
  }

  // Retorna el desplacament del document respecte el centre de la pantalla
  Offset _getDisplacement(Size scrollArea, BoxConstraints constraints) {
    return Offset(((scrollArea.width - constraints.maxWidth) / 2),
        ((scrollArea.height - constraints.maxHeight) / 2));
  }

  // Retorna la posició x,y al document, respecte on s'ha fet click
  Offset getDocumentPosition(
    Offset position,
    double zoom,
    double viewportWidth,
    double viewportHeight,
    double documentWidth,
    double documentHeight,
    double centerX,
    double centerY,
  ) {
    // Calcula la escala relativa al zoom proporcionado
    double scale = zoom / 100;

    // Calcula las transformaciones de traslación para centrar el documento en el viewport
    double translateX =
        (viewportWidth / (2 * scale)) - (documentWidth / 2) - centerX;
    double translateY =
        (viewportHeight / (2 * scale)) - (documentHeight / 2) - centerY;

    // Aplica las transformaciones inversas para obtener la posición original en el documento
    double originalX = (position.dx / scale) - translateX;
    double originalY = (position.dy / scale) - translateY;

    // Devuelve la posición original en el documento
    return Offset(originalX, originalY);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      AppData appData = Provider.of<AppData>(context);
      CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

      Size scrollArea = _getScrollArea(appData);
      Offset scrollDisplacement = _getDisplacement(scrollArea, constraints);

      double tmpScrollX = _scrollCenter.dx;
      double tmpScrollY = _scrollCenter.dy;
      if (_keyScrollX.currentState != null) {
        if (scrollArea.width < constraints.maxWidth) {
          _keyScrollX.currentState!.setOffset(0);
        } else {
          tmpScrollX = _keyScrollX.currentState!.getOffset() *
              (scrollDisplacement.dx * 100 / appData.zoom);
        }
      }

      if (_keyScrollY.currentState != null) {
        if (scrollArea.height < constraints.maxHeight) {
          _keyScrollY.currentState!.setOffset(0);
        } else {
          tmpScrollY = _keyScrollY.currentState!.getOffset() *
              (scrollDisplacement.dy * 100 / appData.zoom);
        }
      }

      _scrollCenter = Offset(tmpScrollX, tmpScrollY);

      // Choose cursor
      MouseCursor cursorShown = MouseCursor.defer;
      if (appData.toolSelected == "pointer_shapes") {
        cursorShown = SystemMouseCursors.basic;
      } else if (appData.toolSelected == "view_grab") {
        if (_isMouseButtonPressed) {
          cursorShown = SystemMouseCursors.grabbing;
        } else {
          cursorShown = SystemMouseCursors.grab;
        }
      } else if (appData.toolSelected == "shape_drawing") {
        cursorShown = SystemMouseCursors.precise;
      }

      return Stack(
        children: [
          GestureDetector(
              onPanEnd: (details) {
                _keyScrollX.currentState!.startInertiaAnimation();
                _keyScrollY.currentState!.startInertiaAnimation();
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (!_isMouseButtonPressed) {
                  if (appData.isAltOptionKeyPressed) {
                    appData.setZoom(appData.zoom + details.delta.dy);
                  } else {
                    if (details.delta.dx != 0) {
                      _keyScrollX.currentState!
                          .setTrackpadDelta(details.delta.dx);
                    }
                    if (details.delta.dy != 0) {
                      _keyScrollY.currentState!
                          .setTrackpadDelta(details.delta.dy);
                    }
                  }
                }
              },
              child: MouseRegion(
                  cursor: cursorShown,
                  child: Listener(
                      onPointerDown: (event) async {
                        _focusNode.requestFocus();
                        _isMouseButtonPressed = true;
                        Size docSize =
                            Size(appData.docSize.width, appData.docSize.height);
                        Offset docPosition = getDocumentPosition(
                            event.localPosition,
                            appData.zoom,
                            constraints.maxWidth,
                            constraints.maxHeight,
                            docSize.width,
                            docSize.height,
                            _scrollCenter.dx,
                            _scrollCenter.dy);
                        if (appData.toolSelected == "pointer_shapes") {
                          appData.selectShapeAtPosition(docPosition,
                              event.localPosition, constraints, _scrollCenter);
                          // TASK
                          if (appData.shapeSelected != -1) {
                            appData.getRecuadre(
                                appData.shapesList[appData.shapeSelected]);
                            appData.recuadre = true;
                            setState(() {});
                          }
                        }
                        if (appData.toolSelected == "shape_drawing") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addNewShape(getDocumentPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints.maxWidth,
                              constraints.maxHeight,
                              docSize.width,
                              docSize.height,
                              _scrollCenter.dx,
                              _scrollCenter.dy));
                        }
                        setState(() {});
                      },
                      onPointerMove: (event) {
                        if (_isMouseButtonPressed) {
                          if (appData.toolSelected == "shape_drawing") {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.addRelativePointToNewShape(
                                getDocumentPosition(
                                    event.localPosition,
                                    appData.zoom,
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                    docSize.width,
                                    docSize.height,
                                    _scrollCenter.dx,
                                    _scrollCenter.dy));
                          }
                        }
                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "view_grab") {
                          if (event.delta.dx != 0) {
                            _keyScrollX.currentState!
                                .setTrackpadDelta(event.delta.dx);
                          }
                          if (event.delta.dy != 0) {
                            _keyScrollY.currentState!
                                .setTrackpadDelta(event.delta.dy);
                          }
                        }
                      },
                      onPointerUp: (event) {
                        _isMouseButtonPressed = false;
                        if (appData.toolSelected == "shape_drawing") {
                          appData.addNewShapeToShapesList();
                        }
                        setState(() {});
                      },
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          if (!_isMouseButtonPressed) {
                            if (appData.isAltOptionKeyPressed) {
                              appData.setZoom(
                                  appData.zoom + pointerSignal.scrollDelta.dy);
                            } else {
                              _keyScrollX.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dx);
                              _keyScrollY.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dy);
                            }
                          }
                        }
                      },
                      child: CustomPaint(
                        painter: LayoutDesignPainter(
                          appData: appData,
                          theme: theme,
                          centerX: _scrollCenter.dx,
                          centerY: _scrollCenter.dy,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      )))),
          UtilCustomScrollHorizontal(
            key: _keyScrollX,
            size: constraints.maxWidth,
            contentSize: scrollArea.width,
            onChanged: (value) {
              setState(() {});
            },
          ),
          UtilCustomScrollVertical(
            key: _keyScrollY,
            size: constraints.maxHeight,
            contentSize: scrollArea.height,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      );
    });
  }
}
