import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class ExcelFileManager extends StatefulWidget {
  @override
  _ExcelFileManagerState createState() => _ExcelFileManagerState();
}

class _ExcelFileManagerState extends State<ExcelFileManager> {
  File? _excelFile;
  bool _filePicked = false;
  TextEditingController _fileNameController = TextEditingController();

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _excelFile = File(result.files.single.path!);
        _filePicked = true;
      });
    }
  }

  Future<void> _saveExcelFile() async {
    if (_excelFile != null) {
      try {
        String fileName = _fileNameController.text.isNotEmpty
            ? _fileNameController.text
            : 'form';
        Directory directory = await getApplicationDocumentsDirectory();
        String newPath = directory.path + '/$fileName.xlsx';
        await _excelFile!.copy(newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel form saved'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save Excel form: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickExcelFile,
              child: Text('Pick Excel Form'),
            ),
            SizedBox(height: 20.0),
            if (_filePicked)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _fileNameController,
                      decoration: InputDecoration(
                        labelText: 'File Name',
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _saveExcelFile,
                    child: Text('Save Excel Form'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: ExcelFileManager(),
  ));
}
