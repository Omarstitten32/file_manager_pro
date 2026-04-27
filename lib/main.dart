import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await Permission.manageExternalStorage.status.isDenied) {
    await Permission.manageExternalStorage.request();
  }
  runApp(FileManagerPro());
}

class FileManagerPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager Pro',
      theme: ThemeData.dark(),
      home: FileBrowser(),
    );
  }
}

class FileBrowser extends StatefulWidget {
  @override
  _FileBrowserState createState() => _FileBrowserState();
}

class _FileBrowserState extends State<FileBrowser> {
  Directory currentDir = Directory('/storage/emulated/0');
  List<FileSystemEntity> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() {
    setState(() {
      try {
        items = currentDir.listSync();
        items.sort((a, b) {
          bool aIsDir = a is Directory;
          bool bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.split('/').last.toLowerCase().compareTo(b.path.split('/').last.toLowerCase());
        });
      } catch (e) {
        items = [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    });
  }

  void enterDirectory(Directory dir) {
    setState(() {
      currentDir = dir;
      loadItems();
    });
  }

  void goBack() {
    if (currentDir.path != '/storage/emulated/0' && currentDir.path != '/') {
      setState(() {
        currentDir = currentDir.parent;
        loadItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentDir.path),
        leading: (currentDir.path != '/storage/emulated/0')
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: goBack)
            : null,
      ),
      body: items.isEmpty
          ? Center(child: Text('No files or folders'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                FileSystemEntity item = items[index];
                bool isDir = item is Directory;
                String name = item.path.split('/').last;
                return ListTile(
                  leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
                  title: Text(name),
                  onTap: () {
                    if (isDir) {
                      enterDirectory(item as Directory);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File: $name')));
                    }
                  },
                );
              },
            ),
    );
  }
}
