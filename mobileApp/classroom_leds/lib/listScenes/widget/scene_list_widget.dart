import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/listScenes/widget/scene_list_item_widget.dart';
import 'package:classroom_leds/listScenes/util/server_util.dart';

class SceneListWidget extends StatefulWidget {
  final List<Scene> scenesList;
  SceneListWidget(this.scenesList);
  @override
  _SceneListWidgetState createState() => _SceneListWidgetState(scenesList);
}

class _SceneListWidgetState extends State<SceneListWidget> {
  List<Scene> scenesList;
  _SceneListWidgetState(this.scenesList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: scenesList.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          background: stackBehindDismiss(),
          key: ObjectKey(scenesList[index]),
          child: SceneListItemWidget(scenesList[index]),
          onDismissed: (direction) {
            var scene = scenesList.elementAt(index);
            //To delete
            deleteScene(index);
            //To show a snackbar with the UNDO button
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text("Scene deleted"),
                action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      //To undo deletion
                      undoDeletion(index, scene);
                    }),
              ),
            );
          },
        );
      },
    );
  }

  void deleteScene(index) {
    deleteSceneFromServer(scenesList[index].id);
    setState(() {
      scenesList.removeAt(index);
    });
  }

  void undoDeletion(index, item) {
    addSceneToServer(item);
    setState(() {
      scenesList.insert(index, item);
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
