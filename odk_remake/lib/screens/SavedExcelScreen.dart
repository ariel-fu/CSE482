import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/excel_file.dart';
import '../widgets/excel_Item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedExcelScreen extends StatefulWidget {
  @override
  _SavedExcelScreenState createState() => _SavedExcelScreenState();
}

class _SavedExcelScreenState extends State<SavedExcelScreen> {
  List<ExcelFile> _savedFiles = [];

  @override
  void initState() {
    _loadSavedFiles();
    super.initState();
  }

  
  void _loadSavedFiles() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedFileNames = prefs.getStringList('savedFileNames');

      if (savedFileNames != null) {
        List<ExcelFile> files = [];
        for (var fileName in savedFileNames) {
          Directory directory = await getApplicationDocumentsDirectory();
          files.add(ExcelFile(name: fileName, path: '${directory.path}/$fileName'));
        }
        setState(() {
          _savedFiles = files;
        });
      }
  }




  Future<void> _addExcelFile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.single;
      String? fileName = platformFile.name;
      String? filePath = platformFile.path;

      if (fileName != null && filePath != null) {
        try {
          File file = File(filePath);
          
          List<int> bytes = await file.readAsBytes();

          // Save the file to app directory
          Directory appDirectory = await getApplicationDocumentsDirectory();
          String savedFilePath = '${appDirectory.path}/$fileName';
          await file.copy(savedFilePath);

          setState(() {
            _savedFiles.add(ExcelFile(name: fileName, path: savedFilePath));
            List<String> savedFileNames = _savedFiles.map((file) => file.name).toList();
            prefs.setStringList('savedFileNames', savedFileNames);
          });
        } catch (e) {
          print('Error saving file: $e');
        }
      } else {
        print('Error: File name or path are null');
      }
    }
  }

  Future<void> _deleteExcelFile(ExcelFile file) async {
    setState(() {
      _savedFiles.remove(file);
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedFileNames = prefs.getStringList('savedFilesNames');

      if (savedFileNames != null && savedFileNames.contains(file.name)) {
        savedFileNames.remove(file.name);
        await prefs.setStringList('savedFilesNames', savedFileNames);
      }

      File fileToDelete = File(file.name);
      if(await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<void> _saveSavedFiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('savedFileNames');

    List<String> savedFileNames = _savedFiles.map((file) => file.name).toList();
    await prefs.setStringList('savedFileNames', savedFileNames);
    // No need to copy files, we are storing their names only
  }


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Excel Files'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addExcelFile,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSavedFiles,
          ),
        ],
      ),
      body: _savedFiles.isEmpty
          ? Center(
              child: Text('No files saved yet.'),
            )
          : ListView.builder(
              itemCount: _savedFiles.length,
              itemBuilder: (context, index) {
                ExcelFile file = _savedFiles[index];
                return ExcelItem(
                  excelFile: file,
                  onDelete: () => _deleteExcelFile(file),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SavedExcelScreen(),
  ));
}
