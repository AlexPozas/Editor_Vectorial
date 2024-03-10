import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({super.key});

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
  //Para backgroundColor
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final GlobalKey<CDKDialogPopoverArrowedState> _anchorArrowedButton =
      GlobalKey(); /////////
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(CDKTheme.black);
  Color backColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    _preloadedColorPicker = _buildPreloadedColorPicker(appData);

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Document properties:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.docSize.width,
                        min: 1,
                        max: 2500,
                        units: "px",
                        increment: 100,
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setDocWidth(value);
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
                        child: Text("Height:", style: font)),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: CDKFieldNumeric(
                          value: appData.docSize.height,
                          min: 1,
                          max: 2500,
                          units: "px",
                          increment: 100,
                          decimals: 0,
                          onValueChanged: (value) {
                            appData.setDocHeight(value);
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Background color:", style: font)),
                    const SizedBox(width: 4),
                    CDKButtonColor(
                      key: _anchorColorButton,
                      color: appData.backgroundColor,
                      onPressed: () {
                        _showPopoverColor(context, _anchorColorButton, appData);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("File actions:", style: fontBold),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: CDKButton(
                        child: Text('Load File'),
                        onPressed: () {
                          appData.loadFile();
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: CDKButton(
                          key: _anchorArrowedButton,
                          onPressed: () {
                            if (appData.fileName == "") {
                              _showPopoverArrowed(
                                  context, _anchorArrowedButton, appData);
                            } else {
                              appData.saveFileToJSON();
                            }
                          },
                          child: appData.fileName == ""
                              ? Text('Save as')
                              : Text('Save')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: CDKButton(
                          onPressed: () {
                            print("export svg");
                            appData.createSvgFileWithShapes(appData.shapesList);
                          },
                          child: Text('Export as SVG')),
                    ),
                  ],
                )
              ]);
        },
      ),
    );
  }

  Widget _buildPreloadedColorPicker(AppData data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          return CDKPickerColor(
            color: value,
            onChanged: (color) {
              data.backgroundColor = color;
              backColor = color;
              data.notifyListeners();
            },
          );
        },
      ),
    );
  }

  void _showPopoverColor(
      BuildContext context, GlobalKey anchorKey, AppData data) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();

    if (anchorKey.currentContext == null) {
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
        key: key,
        context: context,
        anchorKey: anchorKey,
        isAnimated: true,
        isTranslucent: true,
        child: _preloadedColorPicker,
        onHide: () {
          data.setBackgroundColor(backColor);
        });
  }

  _showPopoverArrowed(BuildContext context, GlobalKey anchorKey, AppData data) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
    if (anchorKey.currentContext == null) {
      // ignore: avoid_print
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
      key: key,
      context: context,
      anchorKey: anchorKey,
      isAnimated: true,
      isTranslucent: false,
      onHide: () {
        // ignore: avoid_print
        print("hide arrowed $key");
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("File name:", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
                width: 100,
                child: CDKFieldText(
                  placeholder: 'File Name',
                  isRounded: false,
                  onSubmitted: (value) {
                    if (value == "") {
                      print("The FileName can't be empty");
                    } else {
                      data.fileName = value;
                      print("FileName submitted: $value");
                      data.saveFileToJSON();
                      key.currentState?.hide();
                    }
                  },
                  focusNode: FocusNode(),
                )),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
