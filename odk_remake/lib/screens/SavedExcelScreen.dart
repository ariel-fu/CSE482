import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for accessing clipboard
import 'package:odk_remake/models/excel_file.dart';
import '../widgets/excel_item.dart';
import '../services/url_download.dart';

class SavedExcelScreen extends StatefulWidget {
  @override
  _SavedExcelScreenState createState() => _SavedExcelScreenState();
}

class _SavedExcelScreenState extends State<SavedExcelScreen> {
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

  Future<void> _addExcelFile() async {
    await addExcelFile(); // Add Excel file from data file
    // Reload the files
    List<ExcelFile> updatedFiles = await loadSavedFiles();
    setState(() {
      _savedFiles = updatedFiles;
    });
  }

  Future<void> _deleteExcelFile(ExcelFile file) async {
    await deleteExcelFile(file); // Delete Excel file from data file
    List<ExcelFile> updatedFiles = await loadSavedFiles();
    setState(() {
      _savedFiles = updatedFiles; // Update the list of saved files
    });
  }

  Future<void> _saveSavedFiles(List<ExcelFile> files) async {
    await saveSavedFiles(files); // Save files to data file
    List<ExcelFile> updatedFiles = await loadSavedFiles();
    setState(() {
      _savedFiles = updatedFiles; // Update the list of saved files
    });
  }

  void _toggleSelected(ExcelFile file) {
    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
      } else {
        _selectedFiles.add(file);
      }
    });
  }

  void _deleteSelectedFiles() async {
    for (var file in _selectedFiles) {
      await _deleteExcelFile(file);
    }
    _selectedFiles.clear();
  }

  void _handleAddAction(String value) {
    if (value == 'local') {
      _addExcelFile();
    } else if (value == 'url') {
      _showURLDialog();
    }
  }

  // Function to show the URL input dialog
  Future<void> _showURLDialog() async {
    TextEditingController _urlController = TextEditingController(); // Controller for URL input
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain'); // Get text from clipboard
    String? pastedText = clipboardData?.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'Enter URL',
                ),
              ),
              if (pastedText != null && pastedText.isNotEmpty) // Show paste option if clipboard has text
                TextButton(
                  onPressed: () {
                    setState(() {
                      _urlController.text = pastedText!;
                    });
                  },
                  child: Text('Paste'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call function to handle getting file from URL
                String url = _urlController.text;
                Navigator.of(context).pop();
                // Call the function to download and add Excel file from URL
                downloadExcelFileAndAddToStorage(url);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Forms'),
        actions: [
          // Replace IconButton with PopupMenuButton
          PopupMenuButton<String>(
            icon: Icon(Icons.add), // Set the icon for the dropdown button
            onSelected: _handleAddAction,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'local',
                  child: Text('Get from Local Storage'),
                ),
                PopupMenuItem<String>(
                  value: 'url',
                  child: Text('Get from URL'),
                ),
              ];
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedFiles, // Delete selected files
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveSavedFiles(_savedFiles),
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
                return CheckboxListTile(
                  title: Text(file.name),
                  value: _selectedFiles.contains(file),
                  onChanged: (_) => _toggleSelected(file),
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
