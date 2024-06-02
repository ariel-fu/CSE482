import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  print("how often is this called?");
  Set<String> fileNamesInFirebase = {};
  Future<void> getAllFiles() async {
    try {
      // Query the Firestore collection to get all files
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('completed').get();

      // Iterate over the documents in the query snapshot
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Access the document ID (name)
        String documentId = documentSnapshot.id;
        fileNamesInFirebase.add(documentId);
        // Access the data of each document
        Object? data = documentSnapshot.data();
        // Do something with the data, for example, print it along with the document ID
        print('Document ID: $documentId, Data: $data');
      }
    } catch (e) {
      print('Error getting files: $e');
    }
  }

  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      await getAllFiles();
    }
  } on SocketException catch (_) {}
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedFileNames = prefs.getStringList('savedFileNames') ?? [];

  List<ExcelFile> files = [];
  for (var fileName in savedFileNames) {
    Directory directory = await getApplicationDocumentsDirectory();

    if (fileNamesInFirebase.contains(fileName)) {
      await prefs.setString(fileName, "sent");
    }
    String? status =
        prefs.getString(fileName); // Load status from SharedPreferences

    files.add(ExcelFile(
        name: fileName,
        path: '${directory.path}/$fileName',
        status: status ?? 'draft')); // Default to 'draft' if status is null
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

    if (filePath != null) {
      try {
        File file = File(filePath);
        // List<int> bytes = await file.readAsBytes();

        // Save the file to app directory
        Directory appDirectory = await getApplicationDocumentsDirectory();
        String savedFilePath = '${appDirectory.path}/$fileName';
        await file.copy(savedFilePath);

        List<String> savedFileNames =
            prefs.getStringList('savedFileNames') ?? [];
        savedFileNames.add(fileName);
        await prefs.setStringList('savedFileNames', savedFileNames);

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

Future<void> changeExcelFileName(ExcelFile file, String name) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(file.name, name);
}
