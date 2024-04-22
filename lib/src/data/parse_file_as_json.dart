import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> parseFileAsJson(File serviceAccountJson) async {
  final fileLines = await serviceAccountJson.readAsLines();
  final fileContentString = fileLines.join();

  return jsonDecode(fileContentString);
}
