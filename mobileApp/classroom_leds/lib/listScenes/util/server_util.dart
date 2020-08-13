import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:classroom_leds/model/scene.dart';

final String ip = "192.168.1.139"; // "10.0.2.2"

Future<List<Scene>> fetchScenesFromServer() async {
  final response = await http.get('http://$ip:3000/leds/1');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Scene> sceneList= List<Scene>.from(json.decode(response.body)['scenes'].map((i) => Scene.fromJson(i)));
    print(json.decode(response.body)['scenes']);
    sceneList.sort((a, b) { return a.compareTo(b); });
    return sceneList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load LED');
  }
}

void deleteSceneFromServer(int sceneID) async {
  final response = await http.delete('http://$ip:3000/leds/1/scenes/$sceneID');

  if (response.statusCode == 200) {
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to delete scene');
  }
}

void addSceneToServer(Scene scene) async {
  // set up POST request arguments
  String url = 'http://$ip:3000/leds/1/scenes';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = jsonEncode(scene);
  // make POST request
  final response = await http.post(url, headers: headers, body: json);
  if (response.statusCode != 201) {
    // If the server did not return a 201 response,
    // then throw an exception.
    throw Exception('Failed to add scene');
  }
}

void updateSceneOnServer(Scene scene) async {
  // set up POST request arguments
  String url = 'http://$ip:3000/leds/1/scenes/${scene.id}';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = jsonEncode(scene);
  // make PUT request
  final response = await http.put(url, headers: headers, body: json);
  if (response.statusCode != 200) {
    // If the server did not return a 200 response,
    // then throw an exception.
    throw Exception('Failed to update scene');
  }
}