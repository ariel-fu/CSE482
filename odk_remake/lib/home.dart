import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:odk_remake/models/excel_file.dart';
import 'package:odk_remake/screens/SavedExcelScreen.dart';
import 'package:odk_remake/screens/settings.dart';
import 'package:odk_remake/theme/theme_constants.dart';
import 'package:odk_remake/theme/theme_manager.dart';
import '../widgets/excel_item.dart';
import '../services/url_download.dart';
import '../screens/StartAFormScreen.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  void _navigateToSavedExcelScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedExcelScreen()),
    );
  }

  void _navigateToStartAFormScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StartAFormScreen()),
    );
  }

  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager =
        Provider.of<ThemeManager>(context); // Access ThemeManager

    return MaterialApp(
      title: 'Home Page',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: _HomePage(
        title: 'Home Page',
        navigateToSavedExcelScreen: _navigateToSavedExcelScreen,
        navigateToStartAFormScreen: _navigateToStartAFormScreen,
        navigateToSettingsScreen: _navigateToSettingsScreen,
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final String title;
  final void Function(BuildContext) navigateToSavedExcelScreen;
  final void Function(BuildContext) navigateToStartAFormScreen;
  final void Function(BuildContext) navigateToSettingsScreen;

  const _HomePage({
    Key? key,
    required this.title,
    required this.navigateToSavedExcelScreen,
    required this.navigateToSettingsScreen,
    required this.navigateToStartAFormScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ButtonData> buttons = [
      ButtonData(
        icon: Icons.folder,
        label: 'Files',
        onTap: () => navigateToSavedExcelScreen(context),
      ),
      ButtonData(
        icon: Icons.add_circle,
        label: 'Start a form',
        onTap: () => navigateToStartAFormScreen(context),
      ),
      ButtonData(
        icon: Icons.settings,
        label: 'Settings',
        onTap: () => navigateToSettingsScreen(context),
      ),
      ButtonData(
        icon: Icons.insert_drive_file,
        label: 'Blank',
        destinationPage: BlankScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Center(
        child: ButtonGrid(buttonDataList: buttons),
      ),
    );
  }
}

class ButtonData {
  final IconData icon;
  final String label;
  final Widget? destinationPage;
  final void Function()? onTap;

  ButtonData({
    required this.icon,
    required this.label,
    this.destinationPage,
    this.onTap,
  });
}

class ButtonGrid extends StatelessWidget {
  final List<ButtonData> buttonDataList;

  ButtonGrid({required this.buttonDataList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        children: buttonDataList.map((buttonData) {
          return ElevatedButton.icon(
            onPressed: buttonData.onTap ?? () {},
            icon: Icon(buttonData.icon, color: Colors.white),
            label:
                Text(buttonData.label, style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BlankScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blank')),
      body: Center(child: Text('Blank Page')),
    );
  }
}
