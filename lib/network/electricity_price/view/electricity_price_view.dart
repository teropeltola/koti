
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koti/look_and_feel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../functionalities/functionality/view/functionality_view.dart';
import '../electricity_price.dart';

class ElectricityPriceView extends StatefulWidget {
  const ElectricityPriceView({super.key});

  @override
  State<ElectricityPriceView> createState() => _ElectricityPriceViewState();
}

void _testFill(ElectricityPrice e) {
  DateTime now = DateTime.now();
  e.data.startingTime = DateTime(now.year, now.month, now.day, 1);

  double fillNumber = 45.0;
  double delta = 1.5;

  for (int i=0; i<48; i++) {
    delta = - delta * 1.01;
    fillNumber = fillNumber * 0.7 + i / 4 + delta;
    e.data.slotPrices.add(fillNumber);
  }
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

    _tooltipBehavior =  TooltipBehavior(
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
    ElectricityPriceTable prices = myElectricityPrice.get(DateTime.now());

    electricityChartData = prices.analyse();
    barColor.init(electricityChartData.minPrice, electricityChartData.maxPrice);

    chartData.clear();

    for (int i=0; i<prices.slotPrices.length; i++) {
      chartData.add(ChartData(
          DateTime(prices.startingTime.year, prices.startingTime.month, prices.startingTime.day, prices.startingTime.hour+i),
          prices.slotPrices[i],
          barColor.get(prices.slotPrices[i])));
    }

    currentPrice = prices.currentPrice();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: appTitle('Sähkön hinta')),
        body: SingleChildScrollView( child:
        Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Sähkön hinta nyt: ${currentPrice.toStringAsFixed(2)} c/kWh',
                textScaleFactor: 1.5),
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
                      series: <ChartSeries<ChartData, DateTime>>[
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
            padding: const EdgeInsets.all(10),
            child: Text('- Edullisin tunti: '
                '${_timePeriodFormat(electricityChartData.minPriceTime, 1)} '
                '(${electricityChartData.minPrice.toStringAsFixed(2)} c/kWh)',
                textScaleFactor: 1.2),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('- Kaksituntinen: '
                '${_timePeriodFormat(electricityChartData.min2hourPeriod,2)}'
                ' (${electricityChartData.min2hourPeriodPrice.toStringAsFixed(2)} c/kWh)',
                textScaleFactor: 1.2),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('- Kolmituntinen: '
                '${_timePeriodFormat(electricityChartData.min3hourPeriod,3)}'
                ' (${electricityChartData.min3hourPeriodPrice.toStringAsFixed(2)} c/kWh)',
                textScaleFactor: 1.2),
          ),

        ])
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

  late ElectricityPrice myElectricityPrice;

  ElectricityGridBlock(dynamic myFunctionality) : super(myFunctionality) {
    myElectricityPrice = myFunctionality as ElectricityPrice;
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {
    PriceChange priceChange = myElectricityPrice.data.priceChange();
    double currentPrice = myElectricityPrice.currentPrice();
    _BarColor colorPalette = _BarColor();
    colorPalette.init(myElectricityPrice.data.minPrice(), myElectricityPrice.data.maxPrice());
    Color backgroundColor = colorPalette.get(currentPrice);
    Color foregroundColor = properTextColor(backgroundColor);

    return ElevatedButton(
      style: buttonStyle(backgroundColor, foregroundColor),
      onPressed: () async {
          // if (!myElectricityPrice.isInitialized()) {
        // todo: sähkön hinta pitää hakea säännöllisesti joka päivä
            await myElectricityPrice.init();
          //}
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const ElectricityPriceView();
            },
          ));
          callback();
//        if (!context.mounted) return;
//        Navigator.pop(context);
        },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              const Text(
                'sähkön hinta',
                style: TextStyle(
                  fontSize: 12)),
              Text(
                  '${myElectricityPrice.currentPrice().toStringAsFixed(2)} c',
                  textScaleFactor: 1.4,
                  textAlign: TextAlign.center,
              ),
              Icon(
                  (priceChange == PriceChange.decline)
                   ? Icons.south_east
                   : (priceChange == PriceChange.increase)
                     ? Icons.north_east
                     : Icons.east,
              )
            ])
    );
  }
}


