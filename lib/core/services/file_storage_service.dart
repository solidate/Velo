import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> saveMediaFile(File sourceFile, String filename) async {
    final path = await _localPath;
    final mediaDir = Directory('$path/media/exercises');
    
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final newPath = p.join(mediaDir.path, filename);
    return sourceFile.copy(newPath);
  }

  Future<File?> getMediaFile(String filename) async {
    final path = await _localPath;
    final file = File('$path/media/exercises/$filename');
    return (await file.exists()) ? file : null;
  }
  
  Future<void> deleteMediaFile(String filename) async {
     final path = await _localPath;
     final file = File('$path/media/exercises/$filename');
     if (await file.exists()) {
       await file.delete();
     }
  }
}
