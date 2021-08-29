
import 'package:moolax/business_logic/models/rate.dart';
import 'package:moolax/services/web_api/web_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebApiImpl implements WebApi {
  final _host = 'api.exchangeratesapi.io';
  final path = 'latest';
  final Map<String, String> _header = {'Accept': 'application/json'};

  List<Rate> _rateCache;

  @override
  Future<List<Rate>> fetchExchangeRates() async {
    if (_rateCache == null) {
      final uri = Uri.https(_host, path);
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
          exchangeRate: rate.value as double));
    }
    return list;
  }
}