import 'package:flutter/material.dart';
import '../widgets/market_price_card.dart';
import '../widgets/market_insights_card.dart';

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Updated: Today, 2:30 PM',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Market Price Cards
            const MarketPriceCard(),

            const SizedBox(height: 16),

            // Market Insights
            const MarketInsightsCard(),
          ],
        ),
      ),
    );
  }
}