import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/json/electricity_price_parameters.dart';

void main() {
  group('ElectricityPriceParameters', () {
    test('fromJson and toJson', () {
      final Map<String, dynamic> jsonData = {
        'basicElectricityParameters': {
          'electricityTax': 10.5,
          'spotAddress': 'Test Spot Address',
        },
        'electricity': [
          {'eName': 'Electricity 1', 'eTemplateName': 'Template 1', 'par1': 2},
          {'eName': 'Electricity 2', 'eTemplateName': 'Template 2', 'par1': 8.0},
        ],
        'eDistribution': [
          {'dName': 'Distribution 1', 'dTemplateName': 'Template 1', 'par1': 3.0, 'par2': 4.0, 'par3': 1, 'par4': 2},
          {'dName': 'Distribution 2', 'dTemplateName': 'Template 2', 'par1': 2.5, 'par2': 3.5, 'par3': 2, 'par4': 3},
        ],
      };

      final electricityPriceParameters = ElectricityPriceParameters.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = electricityPriceParameters.toJson();

      expect(electricityPriceParameters.basicElectricityParameters.electricityTax, 10.5);
      expect(electricityPriceParameters.electricity.length, 2);
      expect(electricityPriceParameters.electricity[0].par1, 2.0);
      expect(electricityPriceParameters.eDistribution.length, 2);

      expect(toJsonData['basicElectricityParameters']['electricityTax'], 10.5);
      expect(toJsonData['electricity'].length, 2);
      expect(toJsonData['eDistribution'].length, 2);
    });

  test('fromJson and toJson 2', () {
    final Map<String, dynamic> jsonData = {
      'basicElectricityParameters': {
        'electricityTax': 10.5,
        'spotAddress': 'Test Spot Address',
      },
      'electricity': [
        {'eName': 'Electricity 1', 'eTemplateName': 'Template 1', 'par1': 5.0},
        {'eName': 'Electricity 2', 'eTemplateName': 'Template 2', 'par1': 8.0},
      ],
      'eDistribution': [
        {'dName': 'Distribution 1', 'dTemplateName': 'Template 1', 'par1': 3.0,  'par3': 1, 'par4': 2},
        {'dName': 'Distribution 2', 'par1': 2.5, 'par2': 3.5, 'par3': 2.0, 'par4': ''},
      ],
    };

    final electricityPriceParameters = ElectricityPriceParameters.fromJson(jsonData);
    final Map<String, dynamic> toJsonData = electricityPriceParameters.toJson();

    expect(electricityPriceParameters.basicElectricityParameters.electricityTax, 10.5);
    expect(electricityPriceParameters.electricity.length, 2);
    expect(electricityPriceParameters.eDistribution.length, 2);

    expect(toJsonData['basicElectricityParameters']['electricityTax'], 10.5);
    expect(toJsonData['electricity'].length, 2);
    expect(toJsonData['eDistribution'].length, 2);
  });
  });

group('BasicElectricityParameters', () {
    test('fromJson and toJson', () {
      final Map<String, dynamic> jsonData = {
        'electricityTax': 10.5,
        'spotAddress': 'Test Spot Address',
      };

      final basicElectricityParameters = BasicElectricityParameters.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = basicElectricityParameters.toJson();

      expect(basicElectricityParameters.electricityTax, 10.5);
      expect(basicElectricityParameters.spotAddress, 'Test Spot Address');

      expect(toJsonData['electricityTax'], 10.5);
      expect(toJsonData['spotAddress'], 'Test Spot Address');
    });
  });

  group('Electricity', () {
    test('fromJson and toJson', () {
      final Map<String, dynamic> jsonData = {
        'eName': 'Electricity 1',
        'eTemplateName': 'Template 1',
        'par1': 5.0,
      };

      final electricity = Electricity.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = electricity.toJson();

      expect(electricity.eName, 'Electricity 1');
      expect(electricity.eTemplateName, 'Template 1');
      expect(electricity.par1, 5.0);

      expect(toJsonData['eName'], 'Electricity 1');
      expect(toJsonData['eTemplateName'], 'Template 1');
      expect(toJsonData['par1'], 5.0);
    });

    test('fromJson and toJson 2', () {
      final Map<String, dynamic> jsonData = {
      };

      final electricity = Electricity.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = electricity.toJson();

      expect(electricity.eName, '');
      expect(electricity.eTemplateName, '');
      expect(electricity.par1, 0.0);
    });

    test('fromJson and toJson 3', () {
      final Map<String, dynamic> jsonData = {
        'eName': 'Electricity 1',
        'eTemplateName': 'Template 1',
        'par1': 5.0,
      };

      final electricity = Electricity.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = electricity.toJson();

      expect(electricity.eName, 'Electricity 1');
      expect(electricity.eTemplateName, 'Template 1');
      expect(electricity.par1, 5);

      expect(toJsonData['eName'], 'Electricity 1');
      expect(toJsonData['eTemplateName'], 'Template 1');
      expect(toJsonData['par1'], 5.0);
    });


  });

  group('EDistribution', () {
    test('fromJson and toJson', () {
      final Map<String, dynamic> jsonData = {
        'dName': 'Distribution 1',
        'dTemplateName': 'Template 1',
        'par1': 3.0,
        'par2': 4.0,
        'par3': 1,
        'par4': 2,
      };

      final eDistribution = EDistribution.fromJson(jsonData);
      final Map<String, dynamic> toJsonData = eDistribution.toJson();

      expect(eDistribution.dName, 'Distribution 1');
      expect(eDistribution.dTemplateName, 'Template 1');
      expect(eDistribution.par1, 3.0);
      expect(eDistribution.par2, 4.0);
      expect(eDistribution.par3, 1);
      expect(eDistribution.par4, 2);

      expect(toJsonData['dName'], 'Distribution 1');
      expect(toJsonData['dTemplateName'], 'Template 1');
      expect(toJsonData['par1'], 3.0);
      expect(toJsonData['par2'], 4.0);
      expect(toJsonData['par3'], 1);
      expect(toJsonData['par4'], 2);
    });
  });
}
