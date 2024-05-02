import 'dart:io';

import 'package:flutter/material.dart';

import 'package:odk_remake/FormQuestionFormat.dart';
import 'package:flutter/cupertino.dart';

import 'package:odk_remake/parseData.dart';
import 'package:survey_kit/survey_kit.dart' as survey_kit;


class Form extends StatelessWidget {
  const Form({super.key});

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
  // Order is automatically maintained
  Map<String, FormQuestionFormat> formFormats = {};
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

  Widget buildSurvey(List<survey_kit.Step> surveySteps) {
    return survey_kit.SurveyKit(
      onResult: (survey_kit.SurveyResult result) {
        print(result.finishReason);
        Navigator.pushNamed(context, '/');
      },
      task: survey_kit.NavigableTask(steps: surveySteps),
      showProgress: true,
      localizations: const <String, String>{
        'cancel': 'Cancel',
        'next': 'Next',
      },
      themeData: Theme.of(context).copyWith(
        primaryColor: Colors.cyan,
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 255, 255, 255),
          iconTheme: IconThemeData(
            color: Colors.cyan,
          ),
          titleTextStyle: TextStyle(
            color: Colors.cyan,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.cyan,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.cyan,
          selectionColor: Colors.cyan,
          selectionHandleColor: Colors.cyan,
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.cyan,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(150.0, 60.0),
            ),
            side: MaterialStateProperty.resolveWith(
              (Set<MaterialState> state) {
                if (state.contains(MaterialState.disabled)) {
                  return const BorderSide(
                    color: Colors.grey,
                  );
                }
                return const BorderSide(
                  color: Colors.cyan,
                );
              },
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            textStyle: MaterialStateProperty.resolveWith(
              (Set<MaterialState> state) {
                if (state.contains(MaterialState.disabled)) {
                  return Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey,
                      );
                }
                return Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.cyan,
                    );
              },
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.cyan,
                  ),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 28.0,
            color: Colors.black,
          ),
          displayMedium: TextStyle(
            fontSize: 28.0,
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 24.0,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
          bodySmall: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.cyan,
        )
            .copyWith(
              onPrimary: Color.fromARGB(255, 255, 255, 255),
            )
            .copyWith(background: Color.fromARGB(255, 255, 255, 255)),
      ),
      surveyProgressbarConfiguration: survey_kit.SurveyProgressConfiguration(
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;


    print('Current path: ${Directory.current.path}');

    // for each valid form format, create the widget
    if (!readExcel) {
      formFormats = parseQuestionFormatData('form_data/test/simple.xlsx');
      readExcel = true;
    }

    List<survey_kit.Step> steps = [];
    for(FormQuestionFormat formStep in formFormats.values) {
      steps.add(formStep.generateStep());
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
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            Expanded(
              child: buildSurvey(steps),
              
              )
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
