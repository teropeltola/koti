import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../logic/scale_converter.dart';
import '../look_and_feel.dart';

const double _minTemperature = 5.0;
const double _maxTemperature = 35.0;

List<double> _calculateScale(double currentTemp, double targetTemp) {
 return [5.0, 10, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21, 22, 23, 24, 25, 30, 35];

}

const double _sliderMargin = 16.0;
const double _expandedRatio = 0.9;
const double _sliderGapBetween = 88;

class TemperatureSettingWidget extends StatefulWidget {
  final double currentTarget;
  final double currentTemperature;
  final Function returnValue;
  const TemperatureSettingWidget({Key? key,
    required this.currentTarget,
    required this.currentTemperature,
    required this.returnValue}) : super(key: key);

  @override
  _TemperatureSettingWidgetState createState() =>
      _TemperatureSettingWidgetState();
}

class _TemperatureSettingWidgetState extends State<TemperatureSettingWidget> {
  double _positionValue = 0.0;
  double _currentTemperaturePosition = 0.0;
  ScaleConverter scale = ScaleConverter();

  double width = 1;

  @override
  void initState() {
    super.initState();
    scale.init(_calculateScale(widget.currentTemperature, widget.currentTarget));
    _positionValue =  scale.convertToPosition(widget.currentTarget);
    _currentTemperaturePosition = scale.convertToPosition(widget.currentTemperature);
  }

  double positionFromLeft (double tempPosition) {
    double sliderWidth = (width - 2 * _sliderMargin - _sliderGapBetween) *_expandedRatio;
    return _sliderMargin + sliderWidth * tempPosition / scale.maxIndex();
  }

  String _labelFormatterCallback(dynamic actualValue, String formattedText) {
    bool showNumber = (actualValue.round() % 2) == 0;
    return showNumber ? '${scale.convertToReal(actualValue).floor()}$degree' : '';
  }

  String _tooltipTextFormatterCallback(dynamic actualValue, String formattedText) {
    return '${scale.convertToReal(actualValue).round()}$degree';
  }

  @override
  Widget build(BuildContext context) {
    width = (MediaQuery.of(context).size.width);
    return Stack(
      children: [
        SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white,
              thumbColor:Colors.white,
              thumbRadius: 10,
              thumbStrokeWidth: 2,
              thumbStrokeColor: Colors.blue,
              tooltipBackgroundColor: Colors.blue,
              tooltipTextStyle: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
          ),
          child: SfSlider(
          value: _positionValue,
          onChanged: (dynamic newValue) async {
            _positionValue = newValue;
            // todo: target should be changed as integer and clean the rounding...
            await widget.returnValue(scale.convertToReal(newValue).round());
            setState(() {});
          },
          min: scale.minIndex(), //c.min(),
          max: scale.maxIndex(), //c.max(),
          interval: 1.0,
          showLabels: true,
          showTicks: true,
          enableTooltip: true,
          labelFormatterCallback: _labelFormatterCallback,
          tooltipTextFormatterCallback: _tooltipTextFormatterCallback,
          thumbIcon: Icon(
            Icons.thermostat,
            color: Colors.blue,
            size: 15.0),
        )
        ),
        Positioned(
          left: positionFromLeft(_currentTemperaturePosition),
          top: 8,
          child: Column( children: [
            Text('${widget.currentTemperature.toStringAsFixed(1)}$degree',
                 style: TextStyle(fontSize:8)),
            Icon(
              Icons.device_thermostat_sharp,
              color: Colors.green,
              size: 12
          ),
          ],
          )
        )
      ]
    );
  }
}
