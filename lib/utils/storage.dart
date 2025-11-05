import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getDocFile(String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$fileName');
}

Future<List<Map<String, dynamic>>> loadJsonList(String fileName) async {
  try {
    final file = await getDocFile(fileName);
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      return data.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
}

Future<void> saveJsonList(String fileName, List<Map<String, dynamic>> list) async {
  try {
    final file = await getDocFile(fileName);
    final content = jsonEncode(list);
    await file.writeAsString(content);
  } catch (_) {
    // ignore
  }
}


