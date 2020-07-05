import 'package:flutter/material.dart';

class Scene implements Comparable {
  final int id;
  DateTime time;
  Color color;
  String mode;

  Scene(this.id, this.time, this.color, this.mode);

  Scene.fromJson(Map<String, dynamic> json)
    : id = json['id'],
        time = DateTime.parse(json['time']),
        color = Color(int.parse(json['color'], radix: 16))
            .withAlpha((json['brightness'] * 255).toInt()),
        mode = json['mode'];

  Map<String, dynamic>  toJson() =>
    {
      'id': id,
      'time': time.toIso8601String(),
      'color': "ff" + color.red.toRadixString(16).padLeft(2, '0') +
        color.green.toRadixString(16).padLeft(2, '0') +
        color.blue.toRadixString(16).padLeft(2, '0'),
      'brightness': color.alpha / 255.0,
      'mode': mode,
    };

  @override
  int compareTo(other) {
    if (this.time == null || other == null) {
      return null;
    }

    return this.time.compareTo(other.time);
  }
}
