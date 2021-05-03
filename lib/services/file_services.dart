import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Temp File Services
// Part of TIMELIST JOURNAL (by Logan Giese)

class FileServices {

  // Get the temporary files path
  static Future<String> get _tempPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  // Get a File object for a temp file with the specified location (ex. "/file.txt")
  static Future<File> getFile(String location) async {
    final path = await _tempPath;
    return File('$path$location');
  }

  // Write a string to a temp file at the specified location
  static Future<File> writeString(String location, String data) async {
    final file = await getFile(location);
    return file.writeAsString('$data');
  }

  // Delete a temp file at the specified location (if it exists)
  static Future<File> deleteFile(String location) async {
    final file = await getFile(location);
    bool exists;
    exists = await file.exists().then((result) => exists = result);
    if (exists)
      return file.delete();
    else
      return null;
  }

}
