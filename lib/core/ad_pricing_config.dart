class AdPricingConfig {
  static const Map<int, double> pricingTiers = {
    1000: 34.5,
    2000: 55.0,
    5000: 125.0,
    10000: 210.0,
    20000: 350.0,
    30000: 480.0,
    50000: 700.0,
    75000: 860.0,
    100000: 980.0,
  };

  static double getPriceForViews(int views) {
    if (pricingTiers.containsKey(views)) {
      return pricingTiers[views]!;
    }
    // Fallback logic if needed, or return standard rate
    // For now, defaulting to key lookup or 0.0
    return 0.0;
  }

  static List<int> get availableViews => pricingTiers.keys.toList();
}
