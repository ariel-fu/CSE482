import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for accessing clipboard
import 'package:odk_remake/models/excel_file.dart';
import 'package:odk_remake/screens/completed.dart';
import 'package:odk_remake/screens/settings.dart';
// import 'package:odk_remake/screens/settings.dart';
import '../widgets/excel_item.dart';
import '../services/url_download.dart';
import 'form.dart' as odk_remake;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odk_remake/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:odk_remake/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class SavedExcelScreen extends StatefulWidget {
  @override
  _SavedExcelScreenState createState() => _SavedExcelScreenState();
}

class _SavedExcelScreenState extends State<SavedExcelScreen> {
  List<ExcelFile> _savedFiles = [];
  List<ExcelFile> _selectedFiles = [];
  bool isDraft = false;
  late Timer _timer; // Timer instance

  @override
  void initState() {
    _loadSavedFiles();
    // Start the timer to periodically call _loadSavedFiles()
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
       _loadSavedFiles();
       setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
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

  // void navigateToForm(ExcelFile file) {
  //   Navigator.push(context,
  //     //MaterialPageRoute(builder: (context) => Form()));
  // }

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
          title: const Text('Enter URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
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
                  child: const Text('Paste'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call function to handle getting file from URL
                String url = _urlController.text;
                Navigator.of(context).pop();
                // Call the function to download and add Excel file from URL
                downloadExcelFileAndAddToStorage(url);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            
            actions: [
              // Replace IconButton with PopupMenuButton
              PopupMenuButton<String>(
                icon: const Icon(Icons.add), // Set the icon for the dropdown button
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
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _navigateToSettingsScreen(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(
                20.0), // Add padding from the walls of the screen
            child: GridView.count(
              crossAxisCount: 2, // Display 2 buttons in each row
              mainAxisSpacing: 10.0, // Add vertical spacing between buttons
              crossAxisSpacing: 10.0, // Add horizontal spacing between buttons
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
                    shadowColor: themeManager.themeMode == ThemeMode.dark 
                    ? Colors.white.withOpacity(0.5) 
                    : Colors.black.withOpacity(0.5),
                    elevation: 5.0,
                  ),
                );
              }),
            ),
          )),
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
    Map<String, dynamic> loadAnswersFromPrefs(SharedPreferences prefs) {
      Map<String, dynamic> answers = {};

      List<String>? savedAnswers =
          prefs.getStringList("answers of ${file.name}");

      if (savedAnswers != null) {
        for (String answer in savedAnswers) {
          List<String> splitAnswer = answer.split(":");
          if (splitAnswer.length >= 2) {
            // Changed to >= 2 to handle multiple colons correctly
            String key = splitAnswer[0];
            String value = splitAnswer
                .sublist(1)
                .join(':')
                .trim(); // Join back the split values

            if (value.startsWith("[") && value.endsWith("]")) {
              answers[key] = value.substring(1, value.length - 1).split(', ');
            } else {
              answers[key] = value;
            }
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
                    excelFile: file, answers: loadAnswersFromPrefs(prefs)))));
        break;
      case 'Completed Forms':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => (Completed(
                    excelFile: file, answers: loadAnswersFromPrefs(prefs)))));
        break;
      case 'New Forms':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    (odk_remake.Form(excelFile: file, answers: {}))));
        break;
      case 'Sent Forms':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => (Completed(
                    excelFile: file, answers: loadAnswersFromPrefs(prefs)))));
        break;
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context); // Access the current theme

  List<ExcelFile> filteredFiles = widget.savedFiles.where((file) {
    switch (widget.type) {
      case 'Drafts':
        return file.status == 'draft';
      case 'Completed Forms':
        return file.status == 'completed' || file.status == 'waiting';
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
      automaticallyImplyLeading: false,
      title: Text(widget.type),
      actions: [
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        )
      ]
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: filteredFiles.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          ExcelFile file = filteredFiles[index];
          String buttonLabel;

          // Determine the button label based on the file status
          switch (file.status) {
            case 'draft':
              buttonLabel = 'Continue';
              break;
            case 'completed':
            case 'waiting':
              buttonLabel = 'Continue';
              break;
            case 'sent':
              buttonLabel = 'View';
              break;
            default:
              buttonLabel = 'Start';
          }

          return Dismissible(
            key: Key(file.name),
            onDismissed: (direction) {
              setState(() {
                deleteExcelFile(file);
                widget.savedFiles.remove(file);
              });
              if (mounted) { // Check if the widget is mounted before calling showSnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${file.name} dismissed"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text(
                  file.name,
                  style: TextStyle(
                    color: file.status == 'waiting' ? Colors.red : null,
                  ),
                ),
                subtitle: Text(
                  file.status,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  _startForm(file);
                },
                trailing: ElevatedButton(
                  onPressed: () {
                    _startForm(file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor, // Use the theme's button color
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

}
