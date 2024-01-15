import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatefulWidget {
  const LayoutSidebarFormat({super.key});

  @override
  LayoutSidebarFormatState createState() => LayoutSidebarFormatState();
}

class LayoutSidebarFormatState extends State<LayoutSidebarFormat> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
    final GlobalKey<CDKDialogPopoverArrowedState> DialogKey = GlobalKey();
    final GlobalKey<CDKDialogPopoverArrowedState> DialogKey2 = GlobalKey();
    GlobalKey<CDKButtonColorState> strokedKey =
        GlobalKey<CDKButtonColorState>();
    GlobalKey<CDKButtonColorState> strokedKey2 =
        GlobalKey<CDKButtonColorState>();
    ValueNotifier<Color> _valueColorNotifier = ValueNotifier(CDKTheme.black);
    ValueNotifier<Color> _valueColorNotifier2 = ValueNotifier(CDKTheme.black);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Coordinates:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Offset X", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.shapeSelected != -1
                            ? appData
                                .shapesList[appData.shapeSelected].position.dx
                            : 0.00,
                        enabled: appData.shapeSelected != -1 ? true : false,
                        increment: 1,
                        decimals: 2,
                        onValueChanged: (value) {
                          appData.shapesList[appData.shapeSelected]
                              .setInitialPosition(Offset(
                                  value,
                                  appData.shapesList[appData.shapeSelected]
                                      .position.dy));
                          appData.getRecuadre(
                              appData.shapesList[appData.shapeSelected]);
                          appData.shapesList[appData.shapeSelected].position =
                              Offset(
                                  value,
                                  appData.shapesList[appData.shapeSelected]
                                      .position.dy);
                          appData.notifyListeners();
                        },
                      )),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Offset Y", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.shapeSelected != -1
                            ? appData
                                .shapesList[appData.shapeSelected].position.dy
                            : 0.00,
                        enabled: appData.shapeSelected != -1 ? true : false,
                        increment: 1,
                        decimals: 2,
                        onValueChanged: (value) {
                          appData.shapesList[appData.shapeSelected]
                              .setInitialPosition(Offset(
                                  appData.shapesList[appData.shapeSelected]
                                      .position.dx,
                                  value));
                          appData.getRecuadre(
                              appData.shapesList[appData.shapeSelected]);
                          appData.shapesList[appData.shapeSelected].position =
                              Offset(
                                  appData.shapesList[appData.shapeSelected]
                                      .position.dx,
                                  value);
                          appData.notifyListeners();
                        },
                      )),
                ]),
                const SizedBox(height: 16),
                Text("Stroke and fill:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Stroke width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.strokeWeight,
                        min: 0.01,
                        max: 100,
                        units: "px",
                        increment: 0.5,
                        decimals: 2,
                        onValueChanged: (value) {
                          appData.setNewShapeStrokeWidth(value);
                          if (appData.shapeSelected != -1) {
                            appData.shapesList[appData.shapeSelected]
                                .setStrokeWidth(value);
                          }
                        },
                      )),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Stroke color:", style: font)),
                    const SizedBox(width: 4),
                    ValueListenableBuilder<Color>(
                        valueListenable: _valueColorNotifier,
                        builder: (context, value, child) {
                          return CDKButtonColor(
                              key: strokedKey,
                              color: appData.strokeColor,
                              onPressed: () {
                                CDKDialogsManager.showPopoverArrowed(
                                    key: DialogKey,
                                    context: context,
                                    anchorKey: strokedKey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ValueListenableBuilder<Color>(
                                        valueListenable: _valueColorNotifier,
                                        builder: (context, value, child) {
                                          return CDKPickerColor(
                                            color: value,
                                            onChanged: (color) {
                                              appData.setStrokeColor(color);
                                              if (appData.shapeSelected != -1) {
                                                appData.shapesList[
                                                        appData.shapeSelected]
                                                    .setStrokeColor(color);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ));
                              });
                        })
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text(
                        "Close Shape:",
                        style: font,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    CDKButtonCheckBox(
                      value: appData.shapeSelected > -1
                          ? appData.shapesList[appData.shapeSelected].closed
                          : appData.closeShape,
                      onChanged: (value) {
                        appData.setCloseShape(!appData.closeShape);
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Fill Color:", style: font)),
                    const SizedBox(width: 4),
                    ValueListenableBuilder<Color>(
                        valueListenable: _valueColorNotifier2,
                        builder: (context, value, child) {
                          return CDKButtonColor(
                              key: strokedKey2,
                              color: appData.shapeFillColor,
                              onPressed: () {
                                CDKDialogsManager.showPopoverArrowed(
                                    key: DialogKey2,
                                    context: context,
                                    anchorKey: strokedKey2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ValueListenableBuilder<Color>(
                                        valueListenable: _valueColorNotifier2,
                                        builder: (context, value, child) {
                                          return CDKPickerColor(
                                            color: value,
                                            onChanged: (color) {
                                              appData.setFillColor(color);
                                              if (appData.shapeSelected != -1) {
                                                appData.shapesList[
                                                        appData.shapeSelected]
                                                    .setFillColor(color);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ));
                              });
                        })
                  ],
                ),
              ]);
        },
      ),
    );
  }
}
