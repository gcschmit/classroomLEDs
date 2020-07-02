import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:classroom_leds/model/scene.dart';

Future<List<Scene>> fetchScenes() async {
  final response = await http.get('http://10.0.2.2:3000/leds/1');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Scene> sceneList= List<Scene>.from(json.decode(response.body)['weekdaySchedule'].map((i) => Scene.fromJson(i)));
    print(json.decode(response.body)['weekdaySchedule']);
    sceneList.sort((a, b) { return a.compareTo(b); });
    return sceneList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load LED');
  }
}