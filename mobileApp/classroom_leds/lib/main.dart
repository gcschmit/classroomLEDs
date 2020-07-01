import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:http/http.dart' as http;

Future<LED> fetchLED() async {
  final response = await http.get('http://10.0.2.2:3000/leds/1');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return LED.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load LED');
  }
}

class LED {
  final int id;
  final String color;

  LED({this.id, this.color});

  factory LED.fromJson(Map<String, dynamic> json) {
    return LED(
      id: json['id'],
      color: json['color'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ColorSwatch _tempMainColor;
  Color _tempShadeColor;
  ColorSwatch _mainColor = Colors.blue;
  Color _shadeColor = Colors.blue[800];
  Future<LED> futureLED;

  @override
  void initState() {
    super.initState();
    futureLED = fetchLED();
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _mainColor = _tempMainColor);
                setState(() => _shadeColor = _tempShadeColor);
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    _openDialog(
      "Color picker",
      MaterialColorPicker(
        selectedColor: _shadeColor,
        onColorChange: (color) => setState(() => _tempShadeColor = color),
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
        onBack: () => print("Back button pressed"),
      ),
    );
  }

  void _openMainColorPicker() async {
    _openDialog(
      "Main Color picker",
      MaterialColorPicker(
        selectedColor: _mainColor,
        allowShades: false,
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
      ),
    );
  }

  void _openAccentColorPicker() async {
    _openDialog(
      "Accent Color picker",
      MaterialColorPicker(
        colors: accentColors,
        selectedColor: _mainColor,
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
        circleSize: 40.0,
        spacing: 10,
      ),
    );
  }

  void _openFullMaterialColorPicker() async {
    _openDialog(
      "Full Material Color picker",
      MaterialColorPicker(
        colors: fullMaterialColors,
        selectedColor: _mainColor,
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Material color picker",
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 62.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: _mainColor,
                  radius: 35.0,
                  child: const Text("MAIN"),
                ),
                const SizedBox(width: 16.0),
                CircleAvatar(
                  backgroundColor: _shadeColor,
                  radius: 35.0,
                  child: const Text("SHADE"),
                ),
              ],
            ),
            Center(
              child: FutureBuilder<LED>(
              future: futureLED,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _shadeColor = Color(int.parse(snapshot.data.color, radix: 16));
                  return Text(snapshot.data.color);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
              ),),
              const SizedBox(height: 32.0),
              OutlineButton(
                onPressed: _openColorPicker,
                child: const Text('Show color picker'),
              ),
              const SizedBox(height: 16.0),
              OutlineButton(
                onPressed: _openMainColorPicker,
                child: const Text('Show main color picker'),
              ),
              const Text('(only main color)'),
              const SizedBox(height: 16.0),
              OutlineButton(
                onPressed: _openAccentColorPicker,
                child: const Text('Show accent color picker'),
              ),
              const SizedBox(height: 16.0),
              OutlineButton(
                onPressed: _openFullMaterialColorPicker,
                child: const Text('Show full material color picker'),
              ),
          ],
        ),
      ),
    );
  }
}
