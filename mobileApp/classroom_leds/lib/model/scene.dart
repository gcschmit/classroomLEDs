import 'package:flutter/material.dart';

class Scene implements Comparable {
  final int id;
  final DateTime time;
  final Color color;
  final String mode;

  Scene({this.id, this.time, this.color, this.mode});

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
        id: json['id'],
        time: DateTime.parse(json['time']),
        color: Color(int.parse(json['color'], radix: 16))
            .withAlpha((json['brightness'] * 255).toInt()),
        mode: json['mode']);
  }

  @override
  int compareTo(other) {
    if (this.time == null || other == null) {
      return null;
    }

    return this.time.compareTo(other.time);
  }
}
