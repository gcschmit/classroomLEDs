import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class EditScenePage extends StatefulWidget {
  final Scene scene;
  EditScenePage(this.scene);

  @override
  _EditScenePageState createState() => _EditScenePageState(scene);
}

class _EditScenePageState extends State<EditScenePage> {
  final _titleTextController = TextEditingController();

  final _linkTextController = TextEditingController();

  final _linkFocusNode = FocusNode();

  Color _tempColor;

  final Scene scene;
  _EditScenePageState(this.scene);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit this scene")),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
            onPressed: () {
              String title = _titleTextController.text;
              String link = _linkTextController.text;

              Scaffold.of(context).hideCurrentSnackBar();
              if (isInputValid(title, link)) {
                Navigator.pop(
                    context, scene);
              } else {
                showInputError(context, title, link);
              }
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: _titleTextController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (textInput) {
                FocusScope.of(context).requestFocus(_linkFocusNode);
              },
              decoration: InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: "Title",
                  hintText: scene.mode,
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _linkTextController,
              focusNode: _linkFocusNode,
              decoration: InputDecoration(
                  icon: Icon(Icons.link),
                  labelText: "URL",
                  hintText: "Webpage link",
                  border: OutlineInputBorder()),
            ),
            ListTile(
              title: Text("Time: ${scene.time.hour}:${scene.time.minute}"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickTime,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: scene.color,
                radius: 35.0,
              ),
              title: Text("LED color"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _linkTextController.dispose();
    _linkFocusNode.dispose();
    super.dispose();
  }

  bool isInputValid(String title, String link) {
    return title.isNotEmpty && link.isNotEmpty;
  }

  void showInputError(BuildContext context, String title, String link) {
    if (title.isEmpty) {
      showSnackBar(context, "Title cannot be empty");
    } else if (link.isEmpty) {
      showSnackBar(context, "Link cannot be empty");
    }
  }

  void showSnackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(scene.time));
    if (t != null)
      setState(() {
        final now = DateTime.now();
        scene.time = DateTime(now.year, now.month, now.day, t.hour, t.minute);
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
            selectedColor: scene.color,
            onMainColorChange: (color) =>
                setState(() => _tempColor = color),
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
                setState(() => scene.color = _tempColor);
              },
            ),
          ],
        );
      },
    );
  }
}
