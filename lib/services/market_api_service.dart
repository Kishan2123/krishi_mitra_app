import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/market_price.dart';

class MarketApiService {
  MarketApiService({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('AGMARKNET_API_KEY');

  final http.Client _client;
  final String _apiKey;

  static const _host = 'api.data.gov.in';
  static const _resourcePath = '/resource/9ef84268-d588-465a-a308-a864a43d0070';

  Future<List<MarketPrice>> fetchMarketPrices({
    String state = 'Jharkhand',
    List<String>? commodities,
    int limit = 60,
  }) async {
    _ensureApiKey();
    final params = <String, String>{
      'api-key': _apiKey,
      'format': 'json',
      'limit': '$limit',
      'state': state,
    };

    if (commodities != null && commodities.length == 1) {
      params['commodity'] = commodities.first;
    }

    final uri = Uri.https(_host, _resourcePath, params);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch market prices (status ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final records = (decoded['records'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

    final grouped = _groupByCommodityAndMarket(records);
    grouped.sort(
      (a, b) => (b.arrivalDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.arrivalDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );

    return grouped;
  }

  List<MarketPrice> _groupByCommodityAndMarket(List<Map<String, dynamic>> records) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final record in records) {
      final commodity = (record['commodity'] as String? ?? '').trim();
      final market = (record['market'] as String? ?? '').trim();
      if (commodity.isEmpty || market.isEmpty) continue;

      final key = '$commodity::$market';
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final prices = <MarketPrice>[];
    for (final entry in grouped.entries) {
      final entries = entry.value;
      entries.sort(
        (a, b) => _arrivalDate(b).compareTo(_arrivalDate(a)),
      );

      final latest = entries.first;
      final previous = entries.length > 1 ? entries[1] : entries.first;
      final previousPrice = MarketPrice.toDouble(previous['modal_price']);

      prices.add(
        MarketPrice.fromAgmarknet(
          latest,
          previousPrice: previousPrice,
        ),
      );
    }

    return prices;
  }

  DateTime _arrivalDate(Map<String, dynamic> record) =>
      MarketPrice.parseArrivalDate(record['arrival_date'] as String?) ?? DateTime.fromMillisecondsSinceEpoch(0);

  void _ensureApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('AGMARKNET_API_KEY is not configured.');
    }
  }

  void dispose() {
    _client.close();
  }
}
