import 'dart:async';
import 'dart:io';

import '../look_and_feel.dart';
import 'my_file_pathname.dart';

class EstateDataStorage {

  EstateDataStorage();
  final MyFilePathname _myPathname = MyFilePathname();

  String _estateFileName = 'notInitializedObservationFileName';
  String _fullFileName = 'notInitializedFullFileName';

  Future<void> init(String fileName) async {
    await _myPathname.init();
    setFileName(fileName);
  }

  void setFileName(String fileName) {
    _estateFileName = fileName;
    _fullFileName = _myPathname.name() + _estateFileName;
  }

  String getFileName() {
    return _estateFileName;
  }

  String getFullFileName() {
    return _fullFileName;
  }

  bool estateFileExists() {
    var estateFile = File(_fullFileName);
    return estateFile.existsSync();
  }

  String readObservationData() {
    var estateFile = File(_fullFileName);

    if (estateFile.existsSync()) {
      return estateFile.readAsStringSync();
    }
    log.error('Estate file ($_fullFileName) doesnt exist');
    return '';
  }

  Future<void> delete() async {
    var estateFile = File(_fullFileName);

    try {
      await estateFile.delete();
    } catch (e, st) {
      log.handle(e,st, 'deleting file $_fullFileName failed - exception');
    }
  }

  Future <void> storeEstateFile(String newEstateString)  async {

    var estateFile = File(_fullFileName);
    // Write the new line in the end of the file
    estateFile.writeAsStringSync(
          newEstateString, mode: FileMode.write);
  }
}
