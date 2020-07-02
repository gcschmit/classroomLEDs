import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/widget/scene_list_item_widget.dart';

class SceneListWidget extends StatelessWidget {
  final List<Scene> scenesList;

  SceneListWidget(this.scenesList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: scenesList.length,
      itemBuilder: (BuildContext context, int index) {
        return SceneListItemWidget(scenesList[index]);
      },
    );
  }
}