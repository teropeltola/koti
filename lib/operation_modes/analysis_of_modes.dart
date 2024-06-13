import '../look_and_feel.dart';
import 'operation_modes.dart';

class AnalysislItem {
  DateTime start;
  DateTime end;
  String operationModeName;

  AnalysislItem(this.start, this.end, this.operationModeName);
}


class AnalysisOfModes {
  List <AnalysislItem> items = [];

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
      if (! items.last.end.add(Duration(minutes: 1)).isAtSameMomentAs(start)) {
        log.error('AnalysisOfModes illegal addition');
        return;
      }
    }
    items.add(AnalysislItem(start, start.add(Duration(minutes: durationInMinutes-1)), operationModeName));

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

}