import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class EditScenePage extends StatefulWidget {
  final Scene _scene;
  EditScenePage(this._scene);

  @override
  _EditScenePageState createState() => _EditScenePageState(_scene);
}

class _EditScenePageState extends State<EditScenePage> {
  Color _tempColor;
  Scene _scene;
  _EditScenePageState(Scene initialScene)
  {
    _scene = Scene(initialScene.id, initialScene.time, initialScene.color, initialScene.mode);
  }

  @override
  Widget build(BuildContext context) {
    final timeAsString = "${_scene.time.hour}:" + _scene.time.minute.toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(title: Text("Edit this scene")),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.pop(context, _scene);
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("Time: $timeAsString"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickTime,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _scene.color,
                radius: 35.0,
              ),
              title: Text("LED color"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickColor,
            ),
            DropdownButton<String>(
              value: _scene.mode,
              icon: Icon(Icons.keyboard_arrow_down),
              iconSize: 24,
              elevation: 16,
              isExpanded: true,
              onChanged: (String newMode) {
                setState(() {
                  _scene.mode = newMode;
                });
              },
              items: <String>['solid', 'pulse']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_scene.time));
    if (t != null)
      setState(() {
        final now = DateTime.now();
        _scene.time = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      });
  }

  _pickColor() async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text("choose LED color"),
          content: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: _scene.color,
            onMainColorChange: (color) => setState(() => _tempColor = color),
          ),
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _scene.color = _tempColor);
              },
            ),
          ],
        );
      },
    );
  }
}
