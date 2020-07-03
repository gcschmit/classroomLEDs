import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:classroom_leds/page/edit_scene_page.dart';
//import 'package:classroom_leds/page/view_scene_page.dart';

Future navigateToEditScenePage(Scene scene, BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => EditScenePage(scene)),
  );
}

Future navigateToAddScenePage(BuildContext context) {
  /*return Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => AddScenePage()),
  );*/
}
