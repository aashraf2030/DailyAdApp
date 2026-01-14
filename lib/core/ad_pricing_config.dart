class AdPricingConfig {
  static double pricePerView = 0.025;
  static int minViews = 500;
  static String currency = "ر.س";

  // Updates the configuration from backend response
  static void updateConfig(Map<String, dynamic> data) {
    if (data.containsKey('price_per_view')) {
      pricePerView = double.tryParse(data['price_per_view'].toString()) ?? 0.025;
    }
    if (data.containsKey('min_views')) {
      minViews = int.tryParse(data['min_views'].toString()) ?? 500;
    }
    if (data.containsKey('currency')) {
      currency = data['currency'];
    }
  }

  static double calculatePrice(int views) {
    return views * pricePerView;
  }
}
