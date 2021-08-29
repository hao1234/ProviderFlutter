
import 'package:moolax/business_logic/models/rate.dart';
import 'package:moolax/services/web_api/web_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebApiImpl implements WebApi {
  final _host = 'api.exchangeratesapi.io';
  final path = 'v1/latest';
  final Map<String, String> _header = {'Accept': 'application/json'};

  final queryParameters = {
    'access_key': '61704ee52d53f03674db889eb1401c69'
  };
  List<Rate> _rateCache;

  @override
  Future<List<Rate>> fetchExchangeRates() async {
    if (_rateCache == null) {
      final uri = Uri.http(_host, path, queryParameters);
      final result = await http.get(uri, headers: _header);
      final jsonObject = json.decode(result.body);
      _rateCache = _createRateListFromRawMap(jsonObject);
    } else {
      print('getting rates from cache');
    }
    return _rateCache;
  }

  List<Rate> _createRateListFromRawMap(Map jsonObject) {
    final Map rates = jsonObject['rates'];
    final String base = jsonObject['base'];
    List<Rate> list = [];
    list.add(Rate(baseCurrency: base, quoteCurrency: base, exchangeRate: 1.0));
    for (var rate in rates.entries) {
      list.add(Rate(baseCurrency: base,
          quoteCurrency: rate.key,
          exchangeRate: parseAmount(rate.value)));
    }
    return list;
  }

  double parseAmount(dynamic dAmount){

    double returnAmount = 0.00;
    String strAmount;

    try {

      if (dAmount == null || dAmount == 0) return 0.0;

      strAmount = dAmount.toString();

      if (strAmount.contains('.')) {
        returnAmount = double.parse(strAmount);
      }  // Didn't need else since the input was either 0, an integer or a double
    } catch (e) {
      return 0.000;
    }

    return returnAmount;
  }
}