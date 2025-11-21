import 'package:flutter/material.dart';
import '../widgets/market_price_card.dart';
import '../widgets/market_insights_card.dart';

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prices = _prices;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Prices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Live mandi prices and demand'),
          const SizedBox(height: 12),
          ...prices
              .map(
                (price) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MarketPriceCard(
                    cropName: price['crop'] as String,
                    currentPrice: price['current'] as double,
                    previousPrice: price['previous'] as double,
                    market: price['market'] as String,
                    date: price['date'] as String,
                    demand: price['demand'] as String,
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 12),
          const MarketInsightsCard(),
        ],
      ),
    );
  }
}

const _prices = [
  {
    'crop': 'Paddy',
    'current': 2140.0,
    'previous': 2080.0,
    'market': 'Ranchi Mandi',
    'date': 'Today 8:40 AM',
    'demand': 'High',
  },
  {
    'crop': 'Tomato',
    'current': 28.0,
    'previous': 31.0,
    'market': 'Kanke Mandi',
    'date': 'Today 7:20 AM',
    'demand': 'Medium',
  },
  {
    'crop': 'Wheat',
    'current': 2055.0,
    'previous': 2040.0,
    'market': 'Hazaribagh',
    'date': 'Yesterday 4:30 PM',
    'demand': 'Medium',
  },
];
