import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedFilesView extends StatefulWidget {
  @override
  _SavedFilesViewState createState() => _SavedFilesViewState();
}

class _SavedFilesViewState extends State<SavedFilesView> {
  List<File> _savedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> files = directory.listSync();
      setState(() {
        _savedFiles = files.whereType<File>().toList();
      });
    } catch (e) {
      print('Error loading saved files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _savedFiles.isEmpty
          ? Center(
              child: Text('No files saved yet.'),
            )
          : ListView.builder(
              itemCount: _savedFiles.length,
              itemBuilder: (context, index) {
                File file = _savedFiles[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () {
                    // TODO
                  },
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SavedFilesView(),
  ));
}
