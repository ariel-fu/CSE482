import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> downloadExcelFileAndAddToStorage(String url) async {
  try {
    // Send HTTP GET request
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Get temporary directory path
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Create file name
      String fileName = url.split('/').last;

      // Write response body to file
      File file = File('$tempPath/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      // Check if the file is XLSX or XLS
      if (fileName.toLowerCase().endsWith('.xlsx') || fileName.toLowerCase().endsWith('.xls')) {
        // Add file name to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        List<String>? savedFileNames = prefs.getStringList('savedFileNames') ?? [];
        savedFileNames.add(fileName);
        await prefs.setStringList('savedFileNames', savedFileNames);
      } else {
        // Delete the downloaded file if it's not a valid Excel file
        await file.delete();
        throw Exception('Invalid file format. Only XLSX or XLS files are supported.');
      }
    } else {
      throw Exception('Failed to download file');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<void> deleteFile(String filePath) async {
  try {
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    throw Exception('Error deleting file: $e');
  }
}
