import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../look_and_feel.dart';

const String _parameterFileName = 'https://mosahybrid.com/data/documents/electricity.json';

class ElectricityPriceParameters {
  ElectricityPriceParameters({
    required this.basicElectricityParameters,
    required this.electricity,
    required this.eDistribution,
  });
  late final BasicElectricityParameters basicElectricityParameters;
  late final List<Electricity> electricity;
  late final List<EDistribution> eDistribution;

  ElectricityPriceParameters.fromJson(Map<String, dynamic> json){
    basicElectricityParameters = BasicElectricityParameters.fromJson(json['basicElectricityParameters']);
    electricity = List.from(json['electricity']).map((e)=>Electricity.fromJson(e)).toList();
    eDistribution = List.from(json['eDistribution']).map((e)=>EDistribution.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['basicElectricityParameters'] = basicElectricityParameters.toJson();
    data['electricity'] = electricity.map((e)=>e.toJson()).toList();
    data['eDistribution'] = eDistribution.map((e)=>e.toJson()).toList();
    return data;
  }

  ElectricityPriceParameters.empty() {
    basicElectricityParameters = BasicElectricityParameters();
    electricity = [];
    eDistribution =[];
  }

  bool found() {
    return ((basicElectricityParameters.spotAddress.isNotEmpty) || (electricity.isNotEmpty) || (eDistribution.isNotEmpty));
  }

  void init() {
    _initiateParameterReading(this);
  }

  List <String> electricityAgreementNames() {
    List <String> eAgreementNames = [''];
    for (int i = 0; i<electricity.length; i++) {
      eAgreementNames.add(electricity[i].eName);
    }
    return eAgreementNames;
  }

  List <String> eDistributionNames() {
    List <String> eDistributionNames = [''];
    for (int i = 0; i<eDistribution.length; i++) {
      eDistributionNames.add(eDistribution[i].dName);
    }
    return eDistributionNames;
  }

  bool electricityAgreementIsSpot(int nameIndex) {
    int index = nameIndex-1;
    if (index < 0) {
      return false;
    }
    else {
      return electricity[index].eTemplateName == 'eSpot';
    }
  }

  double vatMultiplier() {
    return basicElectricityParameters.vatMultiplier;
  }

  double vatOf(double withVat) {
    return withVat - (withVat / basicElectricityParameters.vatMultiplier);
  }

}

class BasicElectricityParameters {
  BasicElectricityParameters({
    this.electricityTax = 0.0,
    this.spotAddress = '',
    this.spotSize = 60,
    this.vatMultiplier = 1.255
  });
  late double electricityTax;
  late String spotAddress;
  late int spotSize;
  late double vatMultiplier;

  BasicElectricityParameters.fromJson(Map<String, dynamic> json){
    electricityTax = _readDouble(json, 'electricityTax');
    spotAddress = json['spotAddress'] ?? '';
    spotSize = json['spotSize'] ?? 60;
    vatMultiplier = json[ 'vatMultiplier'] ?? 1.255;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['electricityTax'] = electricityTax;
    data['spotAddress'] = spotAddress;
    data['spotSize'] = spotSize;
    data['vatMultiplier'] = vatMultiplier;
    return data;
  }
}

class Electricity {
  Electricity({
     this.eName = '',
     this.eTemplateName = '',
     this.par1 = 0.0,
  });
  late final String eName;
  late final String eTemplateName;
  late final double par1;

  Electricity.fromJson(Map<String, dynamic> json){
    eName = json['eName'] ?? '';
    eTemplateName = json['eTemplateName'] ?? '';
    par1 = _readDouble(json,'par1');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['eName'] = eName;
    data['eTemplateName'] = eTemplateName;
    data['par1'] = par1;
    return data;
  }
}

class EDistribution {
  EDistribution({
     this.dName = '',
     this.dTemplateName = '',
     this.par1 = 0.0,
     this.par2 = 0.0,
     this.par3 = 0.0,
     this.par4 = 0.0,
  });
  late final String dName;
  late final String dTemplateName;
  late final double par1;
  late final double par2;
  late final double par3;
  late final double par4;

  EDistribution.fromJson(Map<String, dynamic> json){
    dName = json['dName'];
    dTemplateName = json['dTemplateName'] ?? '';
    par1 = _readDouble(json,'par1');
    par2 = _readDouble(json,'par2');
    par3 = _readDouble(json,'par3');
    par4 = _readDouble(json,'par4');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dName'] = dName;
    data['dTemplateName'] = dTemplateName;
    data['par1'] = par1;
    data['par2'] = par2;
    data['par3'] = par3;
    data['par4'] = par4;
    return data;
  }

}

double _readDouble(Map<String, dynamic> json, String jsonParameterName) {
  dynamic par = json[jsonParameterName] ?? 0.0;

  if (par is double) {
    return par;
  }
  else if (par is int) {
    return par.toDouble();
  }
  return 0.0;
}

void _initiateParameterReading(ElectricityPriceParameters e) async {
  e = await readElectricityPriceParameters();
}

Future <ElectricityPriceParameters> readElectricityPriceParameters() async {
  try {
    final response = await http.get(Uri.parse(_parameterFileName));
    if (response.statusCode == 200) {
      String responseString = response.body.toString();
      ElectricityPriceParameters priceParameters =
      ElectricityPriceParameters.fromJson(
          json.decode(responseString));

      return priceParameters;
    }
    log.log('Error ${response.statusCode} in electricity price parameter reading.');
  }
  catch (e, st) {
    log.handle(e, st, 'Exception in electricity price parameter reading');
  }
  return ElectricityPriceParameters.empty();
}

ElectricityPriceParameters electricityPriceParameters = ElectricityPriceParameters.empty();


