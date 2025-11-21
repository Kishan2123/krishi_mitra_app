import 'package:flutter/material.dart';
import '../models/market_price.dart';
import '../services/market_api_service.dart';
import '../widgets/market_price_card.dart';
import '../widgets/market_insights_card.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketApiService _marketApiService = MarketApiService();
  late Future<List<MarketPrice>> _pricesFuture;

  @override
  void initState() {
    super.initState();
    _pricesFuture = _marketApiService.fetchMarketPrices(limit: 80);
  }

  @override
  void dispose() {
    _marketApiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MarketPrice>>(
      future: _pricesFuture,
      builder: (context, snapshot) {
        final Widget priceSection;
        if (snapshot.connectionState == ConnectionState.waiting) {
          priceSection = const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          priceSection = Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unable to load market prices', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          final prices = (snapshot.data ?? []).take(6).toList();
          if (prices.isEmpty) {
            priceSection = const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No live market data available right now.'),
              ),
            );
          } else {
            priceSection = Column(
              children: prices
                  .map(
                    (price) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MarketPriceCard(
                        cropName: price.cropName,
                        currentPrice: price.currentPrice,
                        previousPrice: price.previousPrice,
                        market: price.market,
                        date: price.date,
                        demand: price.demand,
                      ),
                    ),
                  )
                  .toList(),
            );
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Market Prices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Live mandi prices and demand'),
              const SizedBox(height: 12),
              priceSection,
              const SizedBox(height: 12),
              const MarketInsightsCard(),
            ],
          ),
        );
      },
    );
  }

  void _reload() {
    setState(() {
      _pricesFuture = _marketApiService.fetchMarketPrices(limit: 80);
    });
  }
}
