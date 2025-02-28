
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koti/look_and_feel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../estate/estate.dart';
import '../../../functionalities/functionality/view/functionality_view.dart';
import '../../../logic/electricity_price_data.dart';
import '../electricity_price.dart';
import '../trend_electricity.dart';

class ElectricityPriceView extends StatefulWidget {
  final ElectricityPrice electricityPrice;
  const ElectricityPriceView({super.key, required this.electricityPrice});

  @override
  State<ElectricityPriceView> createState() => _ElectricityPriceViewState();
}

class _ElectricityPriceViewState extends State<ElectricityPriceView> {

  List<ChartData> chartData = [];
  ElectricityChartData electricityChartData = ElectricityChartData();
  double currentPrice = 0.0;
  _BarColor barColor = _BarColor();

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        header: 'sähkön hinta',
        builder: (dynamic data, dynamic point, dynamic series,
            int pointIndex, int seriesIndex) {
          return Container(
              child: Text(
                  'Sähkön hinta\n'
                      '${data.x.hour.toStringAsFixed(2)}-${(data.x.hour+1).toStringAsFixed(2)}:\n'
                      '${data.y.toStringAsFixed(2)} c/kWh',
                  style: const TextStyle(color:Colors.white,
                      fontSize: 20)
              )
          );
        }
    );

    regenerateData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void regenerateData()  {
    ElectricityPriceData prices = widget.electricityPrice.getElectricityData(DateTime.now());

    electricityChartData = prices.analyse();
    barColor.init(electricityChartData.minPrice.price, electricityChartData.maxPrice.price);

    chartData.clear();

    for (var item in prices.prices) {
      DateTime time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
      double price = item.totalPrice;
      if (price != noValueDouble) {
        print ('${time.day}. ${time.hour}:${time.minute} ${item.totalPrice}');
        chartData.add(ChartData(
            time,
            item.totalPrice,
            barColor.get(item.totalPrice)));
      }
    }

    currentPrice = prices.currentPrice();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: appIconAndTitle(myEstates.currentEstate().name,ElectricityPrice.functionalityName)),
        body: SingleChildScrollView( child:
        Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Sähkön hinta nyt: ${currentPrice.toStringAsFixed(2)} c/kWh',
                textScaler: const TextScaler.linear(1.5),
            ),
          ),
          Center(
              child: Container(
                  child: SfCartesianChart(
                      tooltipBehavior: _tooltipBehavior,

                      primaryXAxis: DateTimeCategoryAxis(
                        dateFormat: DateFormat.H(),
                        intervalType: DateTimeIntervalType.hours,
                        interval: 2,
                      ),
                      primaryYAxis: NumericAxis(
                          rangePadding: ChartRangePadding.additional,
                          //decimalPlaces: 2,
                          //  minimum: electricityChartData.yAxisMin,
                          //  maximum: electricityChartData.yAxisMax,
                          //  interval: electricityChartData.yAxisInterval,
                          numberFormat: NumberFormat("#0.00")
                      ),
                      series: <CartesianSeries<ChartData, DateTime>>[
                        // Renders column chart
                        ColumnSeries<ChartData, DateTime>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, _) => data.color

                        )
                      ]
                  )
              )
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text('- Edullisin tunti: '
                '${_timePeriodFormat(electricityChartData.minPrice.time, 1)} '
                '(${electricityChartData.minPrice.price.toStringAsFixed(2)} c/kWh)',
                textScaler: const TextScaler.linear(1.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text('- Kaksituntinen: '
                '${_timePeriodFormat(electricityChartData.min2hourPeriod.time,2)}'
                ' (${electricityChartData.min2hourPeriod.price.toStringAsFixed(2)} c/kWh)',
                textScaler: const TextScaler.linear(1.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text('- Kolmituntinen: '
                '${_timePeriodFormat(electricityChartData.min3hourPeriod.time,3)}'
                ' (${electricityChartData.min3hourPeriod.price.toStringAsFixed(2)} c/kWh)',
                textScaler: const TextScaler.linear(1.2),
            ),
          ),
        ]),
        ),
        bottomNavigationBar: Container(
          height: bottomNavigatorHeight,
          alignment: AlignmentDirectional.topCenter,
          color: myPrimaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: const Icon(
                            Icons.list_alt,
                            color: myPrimaryFontColor,
                            size: 40),
                        tooltip: 'kaikki spot tiedot',
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context)  {

                                  return ElectricityPriceDumpView(
                                      electricityPrice: widget.electricityPrice
                                  );
                                },
                              )
                          );
                        }
                    ),
                  ]),
            )
    );
  }
}

String _hourString(int inputHour) {
  return (inputHour % 24).toStringAsFixed(2);
}
String _timePeriodFormat(DateTime dT, int hours) {
  return '${_hourString(dT.hour)}-${_hourString(dT.hour+hours)}';
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final DateTime x;
  final double y;
  final Color color;
}

const List<Color> _colorPalette = [
  Colors.green,
  Colors.lightGreen,
  Colors.yellowAccent,
  Colors.yellow,
  Colors.orangeAccent,
  Colors.orange,
  Colors.deepOrange,
  Colors.red,
];
class _BarColor {
  List <double> limits = [];
  void init(double min, double max) {
    for (int i=0; i < _colorPalette.length-1; i++) {
      limits.add(min+(max-min)/_colorPalette.length*(i+1));
    }
  }

  Color get(double value) {
    for (int i=0; i < limits.length; i++) {
      if (value <= limits[i]) {
        return _colorPalette[i];
      }
    }
    return _colorPalette.last;
  }
}

class ElectricityGridBlock extends FunctionalityView {

  ElectricityPrice myElectricityPrice() {
    return myFunctionality() as ElectricityPrice;
  }

  ElectricityGridBlock();

  ElectricityGridBlock.fromJson(Map<String, dynamic> json)  {
    super.fromJson(json);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {
    ElectricityPrice electricityPrice = myElectricityPrice();
    PriceChange priceChange = electricityPrice.electricity.data.priceChange();
    double currentPrice = electricityPrice.currentPrice();
    _BarColor colorPalette = _BarColor();
    colorPalette.init(
        electricityPrice.electricity.data.minPrice(),
        electricityPrice.electricity.data.maxPrice()
    );
    Color backgroundColor = colorPalette.get(currentPrice);
    Color foregroundColor = properTextColor(backgroundColor);

    return ElevatedButton(
      style: buttonStyle(backgroundColor, foregroundColor),
      onPressed: () async {

          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return ElectricityPriceView(electricityPrice: electricityPrice);
            },
          ));
          callback();
        },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              const Text(
                ElectricityPrice.functionalityName,
                style: TextStyle(
                  fontSize: 10)),
              Text(
                  currencyCentInText(electricityPrice.currentPrice()),
                  textScaler: const TextScaler.linear(1.2),
                  textAlign: TextAlign.center,
              ),
              Icon(
                  (priceChange == PriceChange.decline)
                   ? Icons.south_east
                   : (priceChange == PriceChange.increase)
                     ? Icons.north_east
                     : Icons.east,
                size: 20
              )
            ])
    );
  }
}



class ElectricityPriceDumpView extends StatefulWidget {
  final ElectricityPrice electricityPrice;
  const ElectricityPriceDumpView({Key? key, required this.electricityPrice}) : super(key: key);

  @override
  State<ElectricityPriceDumpView> createState() => _ElectricityPriceDumpViewState();
}


class _ElectricityPriceDumpViewState extends State<ElectricityPriceDumpView> {

  ElectricityPriceData electricityPriceData = ElectricityPriceData();

  @override
  void initState() {
    super.initState();
    electricityPriceData = widget.electricityPrice.getElectricityData();
  }

  Widget _displayElectricityPrice(ElectricityTotalPriceItem electricityPriceItem) {
    if (electricityPriceItem.totalPrice == noValueDouble) {
      return Row(children: <Widget>[
        Text('${dumpTimeString(DateTime.fromMillisecondsSinceEpoch(
          electricityPriceItem.timestamp))}: -')
      ]);
    }
    else {
      return Row(children: <Widget>[
        Text(dumpTimeString(DateTime.fromMillisecondsSinceEpoch(
            electricityPriceItem.timestamp))),
        Text(': ${currencyCentInText(electricityPriceItem.totalPrice)} '),
        Text('(${currencyCentInText(
            electricityPriceItem.electricityPrice)} + ${currencyCentInText(
            electricityPriceItem.transferPrice)})'),
      ]
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appIconAndTitle('Sähkön hinta','listaus'),
        backgroundColor: myPrimaryColor,
        iconTheme: const IconThemeData(color:myPrimaryFontColor)
      ),// new line
      body: SingleChildScrollView( child: Column(children: <Widget>[
        for (int index=1; index<electricityPriceData.prices.length; index++)
          _displayElectricityPrice(electricityPriceData.prices[index]),
      ]
        )
      ),
      bottomNavigationBar: Container(
              height: bottomNavigatorHeight,
              alignment: AlignmentDirectional.topCenter,
              color: myPrimaryColor,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.share,
                            color:myPrimaryFontColor,
                            size:40),
                        tooltip: 'jaa näyttö somessa',
                        onPressed: () async {}
                    ),
                  ]),
            )
    );
  }
}




