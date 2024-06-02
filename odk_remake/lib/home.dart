import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:odk_remake/screens/SavedExcelScreen.dart';
import 'package:odk_remake/theme/theme_constants.dart';
import 'package:odk_remake/theme/theme_manager.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeManager =
        Provider.of<ThemeManager>(context); // Access ThemeManager

    return MaterialApp(
      title: 'Home Page',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: SavedExcelScreen(), // Directly navigate to SavedExcelScreen
    );
  }
}
