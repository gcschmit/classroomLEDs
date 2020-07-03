import 'package:classroom_leds/util/server_util.dart';
import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/util/navigation_util.dart';

class SceneListItemWidget extends StatefulWidget {
  final Scene scene;
  SceneListItemWidget(this.scene);
  @override
  _SceneListItemWidgetState createState() => _SceneListItemWidgetState(scene);
}

class _SceneListItemWidgetState extends State<SceneListItemWidget> {
  Scene scene;

  _SceneListItemWidgetState(this.scene);

  @override
  Widget build(BuildContext context) {
    final time = scene.time.hour.toString() + ":" +
        scene.time.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => onScenePressed(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("$time: ${scene.mode}", style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 6),
            CircleAvatar(
              backgroundColor: scene.color,
              radius: 35.0,
            ),
          ],
        ),
      ),
    );
  }

  void onScenePressed(BuildContext context) async {
    final result = await navigateToEditScenePage(scene, context);

    if (result != null && result is Scene) {
      updateSceneOnServer(result);
      setState(() {
        scene = result;
      });
    }
  }
}
