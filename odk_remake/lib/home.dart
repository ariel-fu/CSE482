import 'package:flutter/material.dart';

import 'screens/form.dart' as odk_remake;
import 'screens/SavedExcelScreen.dart';
import 'screens/StartAFormScreen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomePage(title: 'Home Page'),
    );
  }
}

class _HomePage extends StatelessWidget {
  _HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Files'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SavedExcelScreen())),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text('Start a form'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StartAFormScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
