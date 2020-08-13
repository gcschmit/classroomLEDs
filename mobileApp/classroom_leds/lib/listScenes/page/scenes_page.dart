import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/listScenes/util/navigation_util.dart';
import 'package:classroom_leds/listScenes/util/server_util.dart';
import 'package:classroom_leds/listScenes/widget/scene_list_widget.dart';

class ScenesPage extends StatefulWidget {
  @override
  _ScenesPageState createState() => _ScenesPageState();
}

class _ScenesPageState extends State<ScenesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classroom LEDs"),
      ),
      body: StreamBuilder<Scene>(
        stream: SceneStream().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            print("new snapshot: " + snapshot.data.time.toString());
            return SceneListWidget([snapshot.data]);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        onPressed: () => onAddButtonPressed(context),
        label: Text("Add"),
      ),
    );
  }

  void onAddButtonPressed(BuildContext context) async {
    final scene = Scene(0, DateTime.now(), Colors.blue, "solid");
    final result = await navigateToEditScenePage(scene, context);

    if (result != null && result is Scene) {
      addSceneToServer(result);
    }
  }
}
