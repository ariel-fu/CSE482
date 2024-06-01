import 'package:flutter/material.dart';
import '../models/excel_file.dart';

class ExcelItem extends StatelessWidget {
  final ExcelFile excelFile;

  ExcelItem({required this.excelFile});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(excelFile.name),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _deleteExcelFile(context, excelFile),
      ),
      onTap: () {
        print("huh");
        // TODO: Implement onTap functionality
      },
    );
  }

  Future<void> _deleteExcelFile(BuildContext context, ExcelFile file) async {
    // Call deleteExcelFile function from excel_file.dart
    bool isDeleted = await deleteExcelFile(file);
    if (isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File deleted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file')),
      );
    }
  }
}
