// ScaleConverter is a class to convert real values to position values and vice versa.
// Position values are 0, 1, ..., max
// real values are stored in the realValues list.
// The first purpose is to use it for a Slider to show and set the double
// value. This way we can have non linear Slider values.

class ScaleConverter {
  List<double> realValues = [];

  double min() => realValues.isEmpty ? 0 : realValues[0];
  double max() => realValues.isEmpty ? 0 : realValues.last;

  double minIndex() => 0.0;
  double maxIndex() => realValues.length-1;

  void init(List <double> realValuesArray) {
    realValues = realValuesArray;
  }

  double convertToPosition(double realValue) {
    if (realValue <= realValues[0]) {
      return 0.0;
    }
    else if (realValue >= realValues.last) {
      return (realValues.length-1).toDouble();
    }
    else {
      for (int i=1; i<realValues.length; i++) {
        if (realValue < realValues[i]) {
          double distanceInReal = (realValues[i] - realValues[i - 1]);
          return (i - 1 + (realValue-realValues[i-1]/distanceInReal));
        }
      }
      return realValues.last;
    }
  }

  double convertToReal(double positionValue) {
    if (positionValue <= 0.0) {
      return realValues[0];
    }
    else if (positionValue >= realValues.length-1) {
      return realValues.last;
    }
    else {
      int index = positionValue.floor();
      double decimals = positionValue-positionValue.floorToDouble();
      return realValues[index] + (realValues[index+1]-realValues[index])*decimals;
    }
  }

}

