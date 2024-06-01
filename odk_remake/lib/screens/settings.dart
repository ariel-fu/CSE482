import 'package:flutter/material.dart';
import 'package:odk_remake/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class TTSUtil {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> speak(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final isTTSEnabled = prefs.getBool('ttsEnabled') ?? false;
    if (isTTSEnabled) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTTSEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadTTSSetting();
  }

  Future<void> _loadTTSSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTTSEnabled = prefs.getBool('ttsEnabled') ?? false;
    });
  }

  Future<void> _updateTTSSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTTSEnabled = value;
      prefs.setBool('ttsEnabled', value);
    });
    if (value) {
      await TTSUtil.speak('Text to speech is now enabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: Text('Enable Text to Speech'),
              value: _isTTSEnabled,
              onChanged: (bool value) {
                _updateTTSSetting(value);
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Add the functionality
                print('Button pressed');
              },
              child: Text('New Button'),
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeManager.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

