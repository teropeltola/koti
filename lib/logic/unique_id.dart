import '../look_and_feel.dart';

const String _delimiter = '#';

int _x = 0;

class UniqueId {
  String _id = '';

  UniqueId(String prefix) {
    int numericId = DateTime.now().microsecondsSinceEpoch;
    _x++;
    _id = '$prefix$_delimiter$_x';
  }

  UniqueId.fromString(String id) {
    _id = id;
  }

  String get() {
    return _id;
  }

  void set(String id) {
    _id = id;
  }

  /*
  DateTime creationTime() {
    List<String> stringList = _id.split(_delimiter);
    if (stringList.length != 2) {
      return DateTime(0);
    }
    try {
      int number = int.parse(stringList[1]);
      return DateTime.fromMicrosecondsSinceEpoch(number);
    }
    catch (e, st) {
      log.handle(e, st, 'UniqueId creationTime exception');
      return DateTime(0);
    }
  }
*/
  String prefix() {
    List<String> stringList = _id.split(_delimiter);
    if (stringList.length != 2) {
      return '';
    }
    return stringList[0];
  }

}