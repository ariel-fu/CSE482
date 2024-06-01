import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for accessing clipboard
import 'package:odk_remake/models/excel_file.dart';
import 'package:odk_remake/screens/settings.dart';
import 'package:odk_remake/theme/theme_constants.dart';
import '../widgets/excel_item.dart';
import '../services/url_download.dart';
import 'form.dart' as odk_remake;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:odk_remake/theme/theme_manager.dart'; // Import for theme management

class SavedExcelScreen extends StatefulWidget {
  @override
  _SavedExcelScreenState createState() => _SavedExcelScreenState();
}

class _SavedExcelScreenState extends State<SavedExcelScreen> {
  List<ExcelFile> _savedFiles = [];
  List<ExcelFile> _selectedFiles = [];
  bool isDraft = false;

  @override
  void initState() {
    _loadSavedFiles();
    super.initState();
  }

  void _markDraftExcel(ExcelFile file) {
    setState(() {
      file.status = 'draft';
    });
  }

  void _markCompletedExcelFile(ExcelFile file) {
    setState(() {
      file.status = 'completed';
    });
  }

  void _markNewExcelFile(ExcelFile file) {
    setState(() {
      file.status = 'new';
    });
  }

  void _markSentExcelFile(ExcelFile file) {
    setState(() {
      file.status = 'sent';
    });
  }

  void checkDraft(bool isDraft, ExcelFile file) {
    setState(() {
      if (isDraft) {
        file.status = 'draft';
      }
    });
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
    TextEditingController _urlController =
        TextEditingController(); // Controller for URL input
    final ClipboardData? clipboardData =
        await Clipboard.getData('text/plain'); // Get text from clipboard
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
              if (pastedText != null && pastedText.isNotEmpty)
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
                String url = _urlController.text;
                Navigator.of(context).pop();
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
    final themeManager = Provider.of<ThemeManager>(context); 

    return MaterialApp(
      theme: lightTheme, 
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Forms'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.add),
              onSelected: _handleAddAction,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'local',
                    child: Text('Get from Local Storage'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            children: List.generate(4, (index) {
              IconData iconData = Icons.article_rounded;
              String buttonText = '';
              Color buttonTextColor = Colors.white;
              if (index == 0) {
                iconData = Icons.article_rounded;
                buttonText = 'Drafts';
                buttonTextColor = Colors.white;
              } else if (index == 1) {
                iconData = Icons.check_circle_rounded;
                buttonText = 'Completed';
                buttonTextColor = Colors.white;
              } else if (index == 2) {
                iconData = Icons.edit;
                buttonText = 'New';
                buttonTextColor = Colors.white;
              } else if (index == 3) {
                iconData = Icons.send;
                buttonText = 'Sent';
                buttonTextColor = Colors.white;
              }
              return ElevatedButton.icon(
                onPressed: () {
                  if (index == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListButtons(
                                type: 'Drafts',
                                savedFiles: _savedFiles,
                                toggleSelected: _toggleSelected,
                                selectedFiles: _selectedFiles)));
                  } else if (index == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListButtons(
                                type: 'Completed Forms',
                                savedFiles: _savedFiles,
                                toggleSelected: _toggleSelected,
                                selectedFiles: _selectedFiles)));
                  } else if (index == 2) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListButtons(
                                type: 'New Forms',
                                savedFiles: _savedFiles,
                                toggleSelected: _toggleSelected,
                                selectedFiles: _selectedFiles)));
                  } else if (index == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListButtons(
                                type: 'Sent Forms',
                                savedFiles: _savedFiles,
                                toggleSelected: _toggleSelected,
                                selectedFiles: _selectedFiles)));
                  }
                },
                icon: Icon(iconData),
                label: Text(
                  buttonText,
                  style: TextStyle(color: buttonTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  iconColor: Colors.white,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ListButtons extends StatefulWidget {
  final String type;
  final List<ExcelFile> savedFiles;
  final Function toggleSelected;
  final List<ExcelFile> selectedFiles;

  ListButtons({
    required this.type,
    required this.savedFiles,
    required this.toggleSelected,
    required this.selectedFiles,
  });

  @override
  _ListButtonsState createState() => _ListButtonsState();
}

class _ListButtonsState extends State<ListButtons> {
  Future<void> _startForm(ExcelFile file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> _loadAnswersFromPrefs(SharedPreferences prefs) {
      Map<String, dynamic> answers = {};
      List<String>? savedAnswers = prefs.getStringList("drafts");
      if (savedAnswers != null) {
        for (dynamic answer in savedAnswers) {
          List<String> splitAnswer = answer.split(":");
          if (splitAnswer.length == 2) {
            if (splitAnswer[1].startsWith("[") && splitAnswer[1].endsWith("]")) {
              answers[splitAnswer[0]] = splitAnswer[1]
                  .substring(1, splitAnswer[1].length - 1)
                  .split(', ');
            } else {
              answers[splitAnswer[0]] = splitAnswer[1];
            }
          } else {
            answers[splitAnswer[0]] = splitAnswer.sublist(1).join(':').trim();
          }
        }
      }
      return answers;
    }

    switch (widget.type) {
      case 'Drafts':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => (odk_remake.Form(
                    excelFile: file, answers: _loadAnswersFromPrefs(prefs)))));
        break;
      case 'Completed Forms':
      case 'New Forms':
      case 'Sent Forms':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    (odk_remake.Form(excelFile: file, answers: {}))));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ExcelFile> filteredFiles = widget.savedFiles.where((file) {
      switch (widget.type) {
        case 'Drafts':
          return file.status == 'draft';
        case 'Completed Forms':
          return file.status == 'completed';
        case 'New Forms':
          return file.status == 'new';
        case 'Sent Forms':
          return file.status == 'sent';
        default:
          return false;
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type),
      ),
      body: ListView.builder(
        itemCount: filteredFiles.length,
        itemBuilder: (context, index) {
          ExcelFile file = filteredFiles[index];

          return Dismissible(
            key: Key(file.name),
            onDismissed: (direction) {
              setState(() {
                deleteExcelFile(file);
                widget.savedFiles.remove(file);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${file.name} dismissed"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: Text(file.name),
              onTap: () {
                _startForm(file);
              },
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  _startForm(file);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
