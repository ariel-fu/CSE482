import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:odk_remake/FormQuestionFormat.dart';
import 'package:odk_remake/FormQuestionWidget.dart';
import 'dart:io';

import 'package:odk_remake/TextQuestionWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool readExcel = false;
  List<FormQuestionFormat> formFormats = [];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> parseData(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        String type = row[0] == null ? "n/a" : row[0]!.value.toString();
        String name = row[1] == null ? "n/a" : row[1]!.value.toString();
        String label = row[2] == null ? "n/a" : row[2]!.value.toString();
        String parameters = row[13] == null ? "n/a" : row[13]!.value.toString();
        bool required =
            row[4] == null ? false : row[4]!.value.toString() == "yes";
        String relevant = row[5] == null ? "n/a" : row[5]!.value.toString();

        FormQuestionFormat? format;
        switch (type) {
          case "text":
            print("Input matches QuestionType.Text");
            format = FormQuestionFormat(
                questionType: QuestionType.Text,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "email":
            print("Input matches QuestionType.Text");
            format = FormQuestionFormat(
                questionType: QuestionType.Text,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "note":
            print("Input matches QuestionType.Text");
            format = FormQuestionFormat(
                questionType: QuestionType.Text,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "integer":
            print("Input matches QuestionType.Text");
            format = FormQuestionFormat(
                questionType: QuestionType.Text,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "numeric":
            print("Input matches QuestionType.Text");
            format = FormQuestionFormat(
                questionType: QuestionType.Text,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "date":
            print("Input matches QuestionType.Date");
            format = FormQuestionFormat(
                questionType: QuestionType.Date,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "time":
            print("Input matches QuestionType.Time");
            format = FormQuestionFormat(
                questionType: QuestionType.Time,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "select_one":
            print("Input matches QuestionType.SelectOne");
            format = FormQuestionFormat(
                questionType: QuestionType.SelectOne,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "likert_scale":
            print("Input matches QuestionType.SelectOne");
            format = FormQuestionFormat(
                questionType: QuestionType.SelectOne,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          case "select_multiple":
            print("Input matches QuestionType.SelectMultiple");
            format = FormQuestionFormat(
                questionType: QuestionType.SelectMultiple,
                name: name,
                label: label,
                parameters: parameters,
                required: required,
                relevant: relevant);
            break;
          default:
            print("Input type is not yet supported.");
        }

        if (format != null) {
          formFormats.add(format);
        }
      }
    }
    print(formFormats);
    readExcel = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!readExcel) {
      // Hard-code the data for now
      parseData('form_data/test/simple.xlsx');
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
