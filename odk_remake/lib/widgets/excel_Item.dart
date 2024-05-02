import 'package:flutter/material.dart';
import '../models/excel_file.dart';

class ExcelItem extends StatelessWidget {

  final ExcelFile excelFile;

  ExcelItem({required this.excelFile, required Future<void> Function() onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(excelFile.name),
      trailing: IconButton(
        icon: Icon(Icons.file_download),
        onPressed: () {
          // TODO
        },
      ),
      onTap: () {
        // TODO
      },
    );
  }
} 