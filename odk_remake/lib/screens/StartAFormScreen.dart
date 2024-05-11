import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for accessing clipboard
import 'package:odk_remake/models/excel_file.dart';
import '../widgets/excel_item.dart';
import '../services/url_download.dart';
import 'form.dart' as odk_remake;

class StartAFormScreen extends StatefulWidget {
  @override
  _StartAFormScreenState createState() => _StartAFormScreenState();
}

class _StartAFormScreenState extends State<StartAFormScreen> {
  List<ExcelFile> _savedFiles = [];
  List<ExcelFile> _selectedFiles = [];

  @override
  void initState() {
    _loadSavedFiles();
    super.initState();
  }

  void _loadSavedFiles() async {
    _savedFiles = await loadSavedFiles(); // Load saved files from data file
    setState(() {});
  }

  void _startForm(ExcelFile file) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (odk_remake.Form(excelFile: file))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forms')),
      body: _savedFiles.isEmpty
          ? Center(
              child: Text('No files saved yet.'),
            )
          : Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: _savedFiles.length,
                  itemBuilder: (context, index) {
                    ExcelFile file = _savedFiles[index];
                    return Card(
                        // Add this
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            // Add this
                            color: Colors.grey.withOpacity(
                                0.5), // Change this to your desired color
                            width: 2, // Change this to your desired width
                          ),
                        ),
                        child: Container(
                          // Add this
                          height: 80, // And this
                          alignment: Alignment.center,
                          child: ListTile(
                            title: Text(file.name),
                            trailing: ElevatedButton(
                              onPressed: () => _startForm(file),
                              child: Text('Start'),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StartAFormScreen(),
  ));
}
