import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image from Folder Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedImagePath;

  Future<void> _selectFolder(BuildContext context) async {
    Directory? directory = await FolderPicker.pick(
      context: context,
      rootDirectory: Directory('/'), // เริ่มต้นที่รากของระบบไฟล์
    );

    if (directory != null) {
      // คลิก Cancel จะได้ directory เป็น null
      List<FileSystemEntity> files = directory.listSync();

      // หาไฟล์รูปภาพในโฟลเดอร์
      List<File> imageFiles = files.whereType<File>().where((file) {
        return file.path.toLowerCase().endsWith('.jpg') ||
               file.path.toLowerCase().endsWith('.jpeg') ||
               file.path.toLowerCase().endsWith('.png');
      }).toList();

      if (imageFiles.isNotEmpty) {
        // แสดงไดเรกทอรีที่เลือกและเลือกไฟล์ภาพจากไดเรกทอรีนั้น
        File? selectedImage = await _selectImage(context, imageFiles);
        if (selectedImage != null) {
          setState(() {
            _selectedImagePath = selectedImage.path;
          });
        }
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No images found'),
              content: Text('The selected folder does not contain any image files.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<File?> _selectImage(BuildContext context, List<File> imageFiles) async {
    return await showDialog<File>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Image'),
          children: imageFiles.map<Widget>((File file) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, file);
              },
              child: Text(file.path.split('/').last),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image from Folder Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _selectFolder(context);
              },
              child: Text('Select Folder'),
            ),
            SizedBox(height: 20),
            _selectedImagePath != null
                ? Image.file(
                    File(_selectedImagePath!),
                    height: 200,
                    width: 200,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
