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

  String toJson() {
    final timeAsString = time.toIso8601String();
    final colorAsString = "ff" + color.red.toRadixString(16) + color.green.toRadixString(16) +
        color.blue.toRadixString(16);
    final brightness = color.alpha / 256.0;
    return "{" +
				"\"time\":\"$timeAsString\"," +
				"\"color\":\"$colorAsString\"," +
				"\"brightness\": $brightness," +
				"\"mode\":\"$mode\"" +
			  "}";
  }

  @override
  int compareTo(other) {
    if (this.time == null || other == null) {
      return null;
    }

    return this.time.compareTo(other.time);
  }
}
