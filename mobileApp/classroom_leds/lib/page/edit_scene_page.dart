import 'package:flutter/material.dart';
import 'package:classroom_leds/model/scene.dart';

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
                Navigator.pop(context, Scene(0, DateTime.now(), Colors.red, title));
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
}
