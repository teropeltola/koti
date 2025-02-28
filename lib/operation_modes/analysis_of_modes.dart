import '../look_and_feel.dart';

class AnalysisItem {
  DateTime start;
  DateTime end;
  String operationModeName;

  AnalysisItem(this.start, this.end, this.operationModeName);

  AnalysisItem.empty() : this (DateTime(0),DateTime(0),'');

  bool notFound() {
    return start.year == 0;
  }
}


class AnalysisOfModes {
  List <AnalysisItem> items = [];

  int _currentIndex = 9999;

  void compress() {
    for (int i=items.length-2; i>=0; i--) {
      if (items[i].operationModeName == items[i+1].operationModeName) {
        items[i].end = items[i+1].end;
        items.removeAt(i+1);
      }
    }
  }

  void add(DateTime start, int durationInMinutes, String operationModeName) {

    if (items.isNotEmpty) {
      if (! items.last.end.add(const Duration(minutes: 1)).isAtSameMomentAs(start)) {
        log.error('AnalysisOfModes add error: not back to back time slots');
        return;
      }
    }
    items.add(AnalysisItem(start, start.add(Duration(minutes: durationInMinutes-1)), operationModeName));

  }

  int _findIndex(DateTime time) {
    if (items.isEmpty || time.isBefore(items[0].start)) {
      return -1;
    }
    for (int i=0; i<items.length; i++) {
      if (! time.isAfter(items[i].end)) {
        return i;
      }
    }
    return -1;
  }

  String operationName(DateTime time) {
    int index = _findIndex(time);
    if (index < 0) {
      return '';
    }
    else {
      return items[index].operationModeName;
    }
  }

  String setFirstOperationName(DateTime time) {
    int index = _findIndex(time);
    if (index < 0) {
      _currentIndex = 9999;
      return '';
    }
    else {
      _currentIndex = index;
      return items[index].operationModeName;
    }
  }

  AnalysisItem currentItem() {
    if (_currentIndex < items.length) {
      return items[_currentIndex];
    }
    else {
      return AnalysisItem.empty();
    }
  }

  AnalysisItem updateAndGetCurrentItem() {
    _currentIndex++;
    return currentItem();
  }

  bool isEmpty() {
    return items.isEmpty;
  }

  List <String> toStringList() {
    if (items.isEmpty) {
      return [];
    }

    List<String> modes = [];

    for (int i=0; i<items.length; i++) {
      modes.add('${_dateLine(items[i].start)} ${_time(items[i].start)}-${_time(items[i].end)}: ${items[i].operationModeName}');
    }

    return modes;
  }
  String _time(DateTime dateTime) {
    return '${dateTime.hour}.${dateTime.minute.toString().padLeft(2,'0')}';
  }
  String _dateLine(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  void clear() {
    items.clear();
    _currentIndex = 999;
  }

}
