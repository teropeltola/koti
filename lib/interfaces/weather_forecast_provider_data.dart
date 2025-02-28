import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../look_and_feel.dart';

var inputData = {
  "locationNameKey" : "paikka",
  "weatherData" : [
    {
      "name" : "yr.no",
      "pageTemplate" : "https://www.yr.no/en/forecast/daily-table/2-658225/%paikka%",
      "titleTemplate" : "yr.no - %paikka%",
      "parameterKeys" : ["paikka"]
    },
    {
      "name" : "weather.com",
      "pageTemplate" : "https://weather.com/fi-FI/weather/today/l/f06a0a973cc86361c99cb45d2879d2049e5b25f0984d98c4459c0ad8a31ae1c4",
      "titleTemplate" : "weather.com - %paikka%",
      "parameterKeys" : ["paikka"]
    },
    {
      "name" : "sääennuste.fi",
      "pageTemplate" : "https://saaennuste.fi/?place=%paikka%",
      "titleTemplate" : "sääennuste - %paikka%",
      "parameterKeys" : ["paikka"]
    },
    {
      "name" : "foreca",
      "pageTemplate" : "https://foreca.fi/Finland/%paikka%/%kaupunginosa%",
      "titleTemplate" : "foreca - %kaupunginosa%",
      "parameterKeys" : ["paikka", "kaupunginosa"]
    },
  ]
};

class _editingSupport {
  String value = '';
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  bool edited = false;
}

class WeatherForecastProviderItem {
  String name = '';
  String pageTemplate = '';
  String titleTemplate = '';
  List <String> parameterKeys = [];

  // work items durings editing
  /*
  Map <String, String> parameters = {};
  List <FocusNode> _focusNodes = [];
  List <TextEditingController> _myControllers = [];
*/
  List <_editingSupport> edit = [];

  void _initParameters() {
    for (var p in parameterKeys) {
      edit.add(_editingSupport());
    /*
      parameters[p] = '';
      _focusNodes.add(FocusNode());
      _myControllers.add(TextEditingController());

       */
    }

  }

  WeatherForecastProviderItem(this.name, this.pageTemplate, this.titleTemplate,
      this.parameterKeys) {
    _initParameters();
  }

  String _format(String initTemplate, Map<String, String> values) {
    String formattedText = initTemplate;
    try {
      values.forEach((key, value) {
        formattedText = formattedText.replaceAll('%$key%', value);
      });
    }
    catch (e, st) {
      log.error('WeatherForecastProvider syntax error: $initTemplate', e, st);
      formattedText = '';
    }
    return formattedText;
  }

  Map<String, String> _mapper() {
    Map<String, String> map = {};
    for (int i = 0; i<parameterKeys.length; i++) {
      map[parameterKeys[i]] = edit[i].value;
    }
    return map;
  }

  String internetPageAddress() {
    return _format(pageTemplate, _mapper());
  }

  String title() {
    return _format(titleTemplate, _mapper());
  }

  String getValue(String key) {
    int index = parameterKeys.indexOf(key);
    if (index < 0) {
      return '';
    }
    else {
      return edit[index].value;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = name;
    json['pageTemplate'] = pageTemplate;
    json['titleTemplate'] = titleTemplate;
    json['parameterKeys'] = parameterKeys;
    return json;
  }

  WeatherForecastProviderItem.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    pageTemplate = json['pageTemplate'] ?? '';
    titleTemplate = json['titleTemplate'] ?? '';
    parameterKeys = json['parameterKeys'] ?? [];

    _initParameters();
  }

  List <Widget> parameterListWidget() {
    List <Widget> list = [];

    for (int index = 0; index < parameterKeys.length; index++) {
      list.add(
          Container(
            margin: myContainerMargin,
            child: Row(children: [
            Expanded(
                flex: 2,
                child: AutoSizeText('${parameterKeys[index]}:', maxLines: 1,)
            ),
            Expanded(
              flex: 5,
              child: TextField(
                  key: Key('${parameterKeys[index]} key'),
                  focusNode: edit[index].focusNode,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  controller: edit[index].controller,
                  maxLines: 1,
                  onChanged: (String newText) {
                    edit[index].value = newText;
                    edit[index].edited = true;
                  },
                  onEditingComplete: () {
                    edit[index].focusNode.unfocus();
                  }),
            )
          ])
          )
      );
    }
    return list;
  }

  void setParValue(String parKey, String parValue) {
    int index = parameterKeys.indexOf(parKey);
    if (index >= 0) {
      if (!edit[index].edited) {
        edit[index].value = parValue;
        edit[index].controller.text = parValue;
      }
    }
  }
}

class WeatherForecastProviderData {
  List <WeatherForecastProviderItem> items = [];
  String locationNameKey = '';

  WeatherForecastProviderData();

  void get() {
    items = fromJson(inputData);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['locationNameKey'] = locationNameKey;
    json['weatherData'] = items.map((e)=>e.toJson()).toList();
    return json;
  }

  List <WeatherForecastProviderItem> fromJson(Map<String, dynamic> json) {
    locationNameKey = json['locationNameKey'] ?? '';
    return List.from(json['weatherData']).map((e)=>WeatherForecastProviderItem.fromJson(e)).toList();
  }

  WeatherForecastProviderData.fromJson( Map<String, dynamic> json) {
    items = fromJson(json);
  }

  int itemCount() {
    return items.length;
  }

  void setLocationValue(String newValue) {
    for (var i in items) {
      i.setParValue(locationNameKey, newValue);
    }
  }

  String locationName(int index) {
    return items[index].getValue(locationNameKey);
  }
}

