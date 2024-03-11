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
  Offset dragStartPosition = Offset(0, 0);
  Offset dragStartOffset = Offset(0, 0);
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
  Offset _getDocPosition(Offset position, double zoom,
      BoxConstraints constraints, Size docSize, Offset center) {
    double scale = zoom / 100;
    double translateX =
        (constraints.maxWidth / (2 * scale)) - (docSize.width / 2) - center.dx;
    double translateY = (constraints.maxHeight / (2 * scale)) -
        (docSize.height / 2) -
        center.dy;
    double originalX = (position.dx / scale) - translateX;
    double originalY = (position.dy / scale) - translateY;

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
      } else /*if (appData.toolSelected == "shape_drawing")*/ {
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
                        Offset docPosition = _getDocPosition(
                            event.localPosition,
                            appData.zoom,
                            constraints,
                            docSize,
                            _scrollCenter);
                        if (appData.toolSelected == "pointer_shapes") {
                          await appData.selectShapeAtPosition(docPosition,
                              event.localPosition, constraints, _scrollCenter);
                          if (appData.shapeSelected > -1) {
                            appData.getRecuadre(
                                appData.shapesList[appData.shapeSelected]);
                            dragStartPosition = appData
                                .shapesList[appData.shapeSelected].position;
                            dragStartOffset = docPosition - dragStartPosition;
                          }
                        } else if (appData.toolSelected == "shape_drawing" ||
                            appData.toolSelected == "shape_line") {
                          appData.setShapeSelected(-1);
                          appData.addNewShape(docPosition);
                        } else if (appData.toolSelected == "shape_multiline") {
                          appData.setShapeSelected(-1);
                          if (appData.multiclick) {
                            appData.multiclick = false;
                            appData.addNewShape(docPosition);
                          } else if (appData.isAltOptionKeyPressed) {
                            appData.multiclick = true;
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.addRelativePointToNewShape(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                            appData.addNewShapeToShapesList();
                          } else {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.addRelativePointToNewShape(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          }
                        } else if (appData.toolSelected == "shape_rectangle") {
                          appData.setShapeSelected(-1);
                          appData.addNewShape(docPosition);
                        }
                        //////////////////////////////////////
                        else if (appData.toolSelected == "shape_ellipsis") {
                          appData.setShapeSelected(-1);
                          appData.addNewShape(docPosition);
                        }
                        setState(() {});
                      },
                      onPointerMove: (event) {
                        Size docSize =
                            Size(appData.docSize.width, appData.docSize.height);
                        Offset docPosition = _getDocPosition(
                            event.localPosition,
                            appData.zoom,
                            constraints,
                            docSize,
                            _scrollCenter);

                        if (_isMouseButtonPressed) {
                          if (appData.toolSelected == "shape_drawing") {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.addRelativePointToNewShape(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          }
                          ///////////////
                          else if (appData.toolSelected == "shape_line" ||
                              appData.toolSelected == "shape_multiline") {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.moveLastVertice(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          } else if (appData.toolSelected ==
                              "shape_rectangle") {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.moveSquareVertices(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          } else if (appData.toolSelected == "shape_ellipsis") {
                            appData.newShape.setType("elipse");
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.moveLastVertice(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          }
                          ////////////////
                          else if (appData.toolSelected == "pointer_shapes" &&
                              appData.shapeSelected != -1) {
                            Offset newShapePosition =
                                docPosition - dragStartOffset;
                            appData.setShapePosition(newShapePosition);
                            appData.getRecuadre(
                                appData.shapesList[appData.shapeSelected]);
                            appData.forceNotifyListeners();
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
                        //////////
                        else if (appData.toolSelected == "shape_ellipsis") {
                          appData.addNewEllipseToShapeList();
                        } else if (appData.toolSelected == "shape_line") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addRelativePointToNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                          appData.addNewShapeToShapesList();
                        } else if (appData.toolSelected == "shape_rectangle") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addSquare(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                          appData.addNewShapeToShapesList();
                        }
                        ////////
                        else if (appData.toolSelected == "pointer_shapes" &&
                            appData.shapeSelected != -1) {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          Offset docPosition = _getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter);
                          Offset newShapePosition =
                              docPosition - dragStartOffset;
                          if (dragStartPosition != newShapePosition) {
                            appData.setShapePosition(newShapePosition);
                            appData.getRecuadre(
                                appData.shapesList[appData.shapeSelected]);
                            appData.forceNotifyListeners();
                          }
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
