import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/util/navigation_util.dart';

class SceneListItemWidget extends StatelessWidget {
  final Scene scene;

  SceneListItemWidget(this.scene);

  @override
  Widget build(BuildContext context) {
    final time = scene.time.hour.toString() + ":" +
        scene.time.minute.toString().padLeft(2, '0') + ":" +
        scene.time.second.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => navigateToViewScenePage(scene, context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(time, style: Theme.of(context).textTheme.headline6),
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
}
