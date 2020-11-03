import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ScoreStore {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/score.txt');
  }

  Future<int> readScore() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0.
      // File will not be there if first time running.
      // print('Error reading score');
      return 0;
    }
  }

  Future<File> writeScore(int score) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$score');
  }
}
