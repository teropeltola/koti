import '../functionalities/electricity_price/trend_electricity.dart';
import 'electricity_price_data.dart';

class ElectricityPriceAgent {
  String estateId = '';
  ElectricityPriceData electricityPriceData = ElectricityPriceData();

  ElectricityPriceAgent();

  void update(List<TrendElectricity> electricityTrendData) {
    electricityPriceData.updateElectricityPrice(electricityTrendData);
  }
}

class PriceCollection {
  List<ElectricityPriceAgent> estateData = [];

  // returns existing data if estateId exists, otherwise creates new
  ElectricityPriceAgent getEstateData(String estateId) {
    for (var estate in estateData) {
      if (estate.estateId == estateId) {
        return estate;
      }
    }
    return ElectricityPriceAgent();
  }

  void updateEstateData(String estateId, List<TrendElectricity> estateTrendData) {
    ElectricityPriceAgent currentEstateData = getEstateData(estateId);

    currentEstateData.update(estateTrendData);
  }

  void createPriceAgent(String estateId, ElectricityTariff tariff, ElectricityDistributionPrice distributionPrice) {
    ElectricityPriceAgent estate = getEstateData(estateId);
    estate.electricityPriceData.tariff = tariff;
    estate.electricityPriceData.distributionPrice = distributionPrice;
    if (estate.estateId == '') {
      estate.estateId = estateId;
      estateData.add(estate);
    }
  }
}
