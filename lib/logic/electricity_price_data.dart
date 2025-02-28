
import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/electricity_price/trend_electricity.dart';
import '../look_and_feel.dart';


int constantSlotSize = 60; // constant parameter that can be patched
// eg. testing 1 or in future 15

class ElectricityTotalPriceItem {
  int timestamp = 0;
  double electricityPrice = noValueDouble;
  double transferPrice = noValueDouble;

  ElectricityTotalPriceItem();

  double get totalPrice => (electricityPrice != noValueDouble) && (transferPrice != noValueDouble)
      ? electricityPrice + transferPrice
      : noValueDouble;
}

class ElectricityPriceData {
  List <ElectricityTotalPriceItem> prices = [];
  ElectricityDistributionPrice _distributionPrice = ElectricityDistributionPrice();
  int slotSizeInMinutes = constantSlotSize;

  ElectricityPriceData();

  void storeElectricityPrice(List <TrendElectricity> electricityPrices) {
    prices.clear();
    for (var e in electricityPrices) {
      ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
      item.timestamp = e.timestamp;
      item.electricityPrice = e.price;
      prices.add(item);
    }
  }

  void storeTransferPrice(ElectricityDistributionPrice distributionPrice) {
    _distributionPrice = distributionPrice;
    if (prices.length <= 1) {
      // only the dummy item is present
      return;
    }
    if (_distributionPrice.constantTariff()) {
      for (var e in prices) {
        e.transferPrice = _distributionPrice.price(12); // parameter 'hour' is not used
      }
    }
    else {
      // fill transfer prices to the existing items
      for (var e in prices) {
        if (e.electricityPrice != noValueDouble) {
        e.transferPrice = _distributionPrice.price(
            DateTime.fromMillisecondsSinceEpoch(
                e.timestamp)
                .hour);
        }
      }

      // add possible tariff changes if they are between items
      int previousTariffChange = _distributionPrice.previousTariffChange(prices.last.timestamp);
      int startingIndex = prices.length-1;
      for (int index=startingIndex; index>=0; index--) {
        if (prices[index].totalPrice != noValueDouble) {
          while (previousTariffChange >= prices[index].timestamp) {
            // if the tariff change is exactly at the same time as the item timestamp then
            // just skip the tariff change => no need to add items
            if (previousTariffChange > prices[index].timestamp) {
              // tariff change during the slot => add new item for different tariffs
              ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
              item.timestamp = previousTariffChange;
              item.electricityPrice = prices[index].electricityPrice;
              item.transferPrice = _distributionPrice.price(DateTime
                  .fromMillisecondsSinceEpoch(previousTariffChange)
                  .hour);
              prices.insert(index + 1, item);
            }
            previousTariffChange = _distributionPrice.previousTariffChange(
                previousTariffChange - 1);
          }
        }
      }
    }
  }

  double priceAtTimestamp(int timestamp) {
    for (int index=prices.length-1; index>=0; index--) {
      if (prices[index].timestamp <= timestamp) {
        return prices[index].totalPrice;
      }
    }
    return noValueDouble;
  }

  double priceAtDateTime(DateTime dateTime) {
    return priceAtTimestamp(  dateTime.millisecondsSinceEpoch);
  }

  DateTime startingTime() {
    if (prices.isEmpty) {
      return DateTime(0);
    }
    else {
      return DateTime.fromMillisecondsSinceEpoch(prices[0].timestamp);
    }
  }
  //int slotSizeInMinutes = constantSlotSize;
  //List <double> slotPrices = [];

  int findIndex(DateTime myTime) {
    int timestamp = myTime.millisecondsSinceEpoch;

    for (int index=prices.length-1; index>=0; index--) {
      if (prices[index].timestamp <= timestamp) {
        return index;
      }
    }
    return -1;
  }

  DateTime crop(DateTime d) {
    switch (slotSizeInMinutes) {
      case 60:
        return DateTime(d.year, d.month, d.day, d.hour);
      case 15:
        return DateTime(d.year, d.month, d.day, d.hour, 15 * (d.minute ~/ 15));
      case 1:
        return DateTime(d.year, d.month, d.day, d.hour, d.minute);
      default:
        return DateTime(0);
    }
  }

  bool isEmpty() {
    return prices.isEmpty;
  }

  double averagePrice(int firstIndex, int durationInMinutes) {
    int index = firstIndex;
    int durationLeft = durationInMinutes * 60000; // durationLeft in milliseconds
    double weightedSum = 0.0;

    if (prices.isEmpty) {
      return noValueDouble;
    }

    while (durationLeft > 0) {
      if (prices[index].totalPrice == noValueDouble) {
        // no price data for this time period
        return noValueDouble;
      }
      int indexDuration = prices[index+1].timestamp - prices[index].timestamp;
      if (indexDuration < durationLeft) {
        weightedSum += prices[index].totalPrice * indexDuration;
        durationLeft -= indexDuration;
        index++;
        if (index >= prices.length-1) {
          // no price data because the time period is too long
          return noValueDouble;
        }
      }
      else {
        weightedSum += prices[index].totalPrice * durationLeft;
        durationLeft = 0;
      }
    }
    return weightedSum / durationInMinutes / 60000;
  }

  static final _fakeMin  = 123456789.123;

  PriceAndTime findMinPriceWithinDuration(int durationInMinutes) {
    PriceAndTime result = PriceAndTime();
    result.price = _fakeMin;
    for (int index = 0; index<prices.length-1; index++) {
      double price = averagePrice(index, durationInMinutes);
      if ((price != noValueDouble) && (price < result.price)) {
        result.time = DateTime.fromMillisecondsSinceEpoch(prices[index].timestamp);
        result.price = price;
      }
    }
    if (result.price == _fakeMin) {
      result.price = noValueDouble;
    }
    return result;
  }

  ElectricityChartData analyse() {
    ElectricityChartData e = ElectricityChartData();

    e.minPrice = findMinPriceWithinDuration(60);
    e.min2hourPeriod = findMinPriceWithinDuration(120);
    e.min3hourPeriod = findMinPriceWithinDuration(180);

    for (var item in prices) {
      if (item.totalPrice != noValueDouble) {
        if (item.totalPrice > e.maxPrice.price) {
          e.maxPrice.price = item.totalPrice;
          e.maxPrice.time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
        }
      }
    }

    e.yAxisMax = e.maxPrice.price;
    e.yAxisMin = 0; // e.minPrice;
    e.yAxisInterval = ((e.yAxisMax- e.yAxisMin) / 10);

    return e;
  }

  int _countPercentileIndex(double percentile) {
    return (percentile <= 0) ? 0 : (percentile >= 1) ? (prices.length-1) :
      (percentile * prices.length).ceil()-1;
  }

  double findPercentile(double percentile) {
    if (prices.isEmpty) {
      return 0.0;
    }
    List <double> sortedList = [];
    for (var item in prices) {
      sortedList.add(item.totalPrice);
    }
    sortedList.sort();
    int index = _countPercentileIndex(percentile);
    return sortedList[index];
  }

  double currentPrice() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return noValueDouble;
    }
    else {
      return prices[index].totalPrice;
    }
  }

  PriceChange priceChange() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return PriceChange.flat;
    }
    double currentPrice = prices[index].totalPrice;
    double delta = currentPrice * 0.1;
    double sum = 0.0;
    int count = 0;

    for (int i=index+1; i<prices.length; i++) {
      sum += prices[i].totalPrice;
      count++;
    }
    if (sum/count < currentPrice - delta) {
      return PriceChange.decline;
    }
    else if (sum/count > currentPrice + delta) {
      return PriceChange.increase;
    }
    else {
      return PriceChange.flat;
    }
  }

  double maxPrice() {
    return 30.0;
  }

  double minPrice() {
    return 5.0;
  }

  DateTime slotStartingTime(int index) {
    return DateTime.fromMillisecondsSinceEpoch(prices[index].timestamp);
  }

  DateTime lastMinuteOfPeriod() {
    return DateTime.fromMillisecondsSinceEpoch(prices.last.timestamp);
  }

  int nbrOfMinutes() {
    return startingTime().difference(lastMinuteOfPeriod()).inMinutes;
  }

  ElectricityPriceData  getData ([DateTime? startingTimeParameter])  {
    if (startingTimeParameter == null) {
      return this;
    }

    ElectricityPriceData result = ElectricityPriceData();
    result._distributionPrice = _distributionPrice;
    result.slotSizeInMinutes = slotSizeInMinutes;
    int startingIndex = findIndex(startingTimeParameter);
    if (startingIndex >= 0) {
        result.prices = prices.sublist(startingIndex);
    }
    return result;
  }
}

class PriceAndTime {
  double price = noValueDouble;
  DateTime time = DateTime(0);
}