import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarShapes extends StatefulWidget {
  const LayoutSidebarShapes({super.key});

  @override
  LayoutSidebarShapesState createState() => LayoutSidebarShapesState();
}

class LayoutSidebarShapesState extends State<LayoutSidebarShapes> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
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
                    return GestureDetector(
                      child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.transparent,
                          child: Text(
                              'Shape $index  ${appData.shapesList[index].strokeWidth}px')),
                      onTap: () {
                        appData.getRecuadre(appData.shapesList[index]);
                        appData.recuadre = true;
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
