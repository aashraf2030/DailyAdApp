abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<dynamic> products;
  StoreLoaded(this.products);
}

class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}

class StoreCartUpdated extends StoreState {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  StoreCartUpdated(this.cartItems, this.totalPrice);
}

class StoreOrderSuccess extends StoreState {
  final Map<String, dynamic> data;
  StoreOrderSuccess(this.data);
}

class StoreOrderError extends StoreState {
  final String message;
  StoreOrderError(this.message);
}

class StorePaymentRequired extends StoreState {
  final String paymentUrl;
  final int orderId;
  StorePaymentRequired(this.paymentUrl, this.orderId);
}

class StoreApplePayRequired extends StoreState {
  final String clientSecret;
  final int orderId;
  final double amount;
  final String currency;
  final String merchantId; // Add if needed specifically
  
  StoreApplePayRequired({
    required this.clientSecret,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.merchantId = "merchant.com.dailyAd.app", // Default or config
  });
}

class StorePaymentSuccess extends StoreState {
  final int orderId;
  StorePaymentSuccess(this.orderId);
}
