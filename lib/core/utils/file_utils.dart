// core/utils/file_utils.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  static Future<String> get downloadsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'downloads');
  }

  static Future<File> saveFile(List<int> bytes, String fileName) async {
    final downloadsDir = await downloadsPath;
    final dir = Directory(downloadsDir);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(path.join(downloadsDir, fileName));
    return file.writeAsBytes(bytes);
  }

  static Future<List<FileSystemEntity>> getDownloadedFiles() async {
    final downloadsDir = await downloadsPath;
    final dir = Directory(downloadsDir);

    if (await dir.exists()) {
      return dir.list().toList();
    }

    return [];
  }
}