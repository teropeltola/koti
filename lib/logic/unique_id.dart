import 'my_permanent_variable.dart';

const String _delimiter = '#';

MyPermanentVariable<int> _x = MyPermanentVariable('uniqueId', 0);

class UniqueId {
  String _id = '';

  UniqueId(String prefix) {
    //int numericId = DateTime.now().microsecondsSinceEpoch;
    int uniqueIndex = _x.value();
    _x.set(uniqueIndex+1);
    _id = '$prefix$_delimiter$uniqueIndex';
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

  String prefix() {
    List<String> stringList = _id.split(_delimiter);
    if (stringList.length != 2) {
      return '';
    }
    return stringList[0];
  }

  int index() {
    List<String> stringList = _id.split(_delimiter);
    if (stringList.length != 2) {
      return -1;
    }
    return int.parse(stringList[1]);
  }

}