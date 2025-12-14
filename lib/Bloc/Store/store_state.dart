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

class StoreOrderSuccess extends StoreState {}

class StoreOrderError extends StoreState {
  final String message;
  StoreOrderError(this.message);
}
