import 'dart:io';
import 'dart:core';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FilePrinter extends LogOutput {
  Future<String> _localPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  void writeData(String data) async {
    var path = await _localPath();
    final File file = File('$path/diamond_logs.txt');

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    try {
      file.writeAsStringSync('$data', mode: FileMode.append, flush: true);
    } catch (err) {
      print(err);
    }
  }

  @override
  void output(OutputEvent event) {
    // TODO: implement output
    String data = '';
    for (int ii = 0; ii < event.lines.length; ii++) {
      data += event.lines[ii];
    }
    data += "\n\n\n\n";
    this.writeData(data);
  }
}
