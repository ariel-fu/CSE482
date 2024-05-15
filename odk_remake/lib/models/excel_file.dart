import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcelFile {
  final String name;
  final String path;
  String status; // Updated property

  ExcelFile({
    required this.name,
    required this.path,
    required this.status,
  });
}

Future<List<ExcelFile>> loadSavedFiles() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedFileNames = prefs.getStringList('savedFileNames') ?? [];

  List<ExcelFile> files = [];
  for (var fileName in savedFileNames) {
    Directory directory = await getApplicationDocumentsDirectory();
    String? status = prefs.getString(fileName); // Load status from SharedPreferences
    files.add(ExcelFile(name: fileName, path: '${directory.path}/$fileName', status: status ?? 'draft')); // Default to 'draft' if status is null
  }
  return files;
}

Future<void> addExcelFile() async {
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

        List<String> savedFileNames = prefs.getStringList('savedFileNames') ?? [];
        savedFileNames.add(fileName);
        await prefs.setStringList('savedFileNames', savedFileNames);

        // Set default status to 'draft' when adding a new file
        await prefs.setString(fileName, 'new');
      } catch (e) {
        print('Error saving file: $e');
      }
    } else {
      print('Error: File name or path are null');
    }
  }
}

Future<bool> deleteExcelFile(ExcelFile file) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFileNames = prefs.getStringList('savedFileNames') ?? [];

    if (savedFileNames.contains(file.name)) {
      savedFileNames.remove(file.name);
      await prefs.setStringList('savedFileNames', savedFileNames);
    }

    File fileToDelete = File(file.path);
    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
      return true;
    }
    return false;
  } catch (e) {
    print('Error deleting file: $e');
    return false;
  }
}


Future<void> saveSavedFiles(List<ExcelFile> savedFiles) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.remove('savedFileNames');

  List<String> savedFileNames = savedFiles.map((file) => file.name).toList();
  await prefs.setStringList('savedFileNames', savedFileNames);
  // No need to copy files, we are storing their names only
}

Future<void> markCompletedExcelFile(ExcelFile file) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(file.status, 'completed');
}

Future<void> markDraftExcelFile(ExcelFile file) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(file.status, 'draft');
}

Future<void> markNewExcelFile(ExcelFile file) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(file.status, 'new');
}

Future<void> markSentExcelFile(ExcelFile file) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(file.status, 'sent');
}