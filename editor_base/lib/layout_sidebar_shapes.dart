import 'package:editor_base/SidebarShapePainter.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class MiniatureShape extends StatelessWidget {
  final Shape shape;

  MiniatureShape(this.shape);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50, // Ajusta el ancho según sea necesario
      height: 50, // Ajusta la altura según sea necesario
      child: CustomPaint(
        painter: SidebarShapePainter(shape),
      ),
    );
  }
}

class LayoutSidebarShapes extends StatefulWidget {
  const LayoutSidebarShapes({Key? key}) : super(key: key);

  @override
  LayoutSidebarShapesState createState() => LayoutSidebarShapesState();
}

class LayoutSidebarShapesState extends State<LayoutSidebarShapes> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Text('List of shapes'),
            SizedBox(
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appData.shapesList.length,
                itemBuilder: (context, index) {
                  bool isSelected = appData.shapeSelectedPrevious == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        appData.getRecuadre(appData.shapesList[index]);
                        appData.recuadre = true;
                        appData.shapeSelectedPrevious = index;
                        appData.shapeSelected = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: isSelected ? Colors.blue : Colors.transparent,
                      child: Row(
                        children: [
                          // Ajusta el espacio entre la miniatura y el texto
                          Text(
                              'Shape $index  ${appData.shapesList[index].strokeWidth}px'),
                          SizedBox(width: 8),
                          MiniatureShape(appData.shapesList[index]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
