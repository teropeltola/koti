
class OverloadGuard<T> {
  DateTime _earlierCallTime = DateTime(0);
  late T _earlierValue;
  final Duration _waitingPeriod;

  OverloadGuard(this._earlierValue, this._waitingPeriod);

  bool updateIsAllowed(T newValue) {
    if ((newValue != _earlierValue) || (_earlierCallTime.add(_waitingPeriod).isBefore(DateTime.now()))) {
      _earlierCallTime = DateTime.now();
      _earlierValue = newValue;
      return true;
    }
    else {
      return false;
    }
  }
}