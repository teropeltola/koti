
class RecordDataItem<T> {
  int millisecondsSinceEpoch = 0;
  late T data;

  RecordDataItem(this.millisecondsSinceEpoch, this.data);
}

class StatisticsCollection<T> {

  List<RecordDataItem<T>> items = [];
  StatisticsCollection() {
  }

  void record(T value) {
    items.add(RecordDataItem(DateTime.now().millisecondsSinceEpoch, value));
  }

  List <RecordDataItem<T>> getTrend() {
    return items;
  }
}