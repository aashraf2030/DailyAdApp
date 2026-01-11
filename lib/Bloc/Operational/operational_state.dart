part of 'operational_cubit.dart';

@immutable
abstract class OperationalState {}

class InitialOperational extends OperationalState {}

class DoneOperational extends OperationalState {}

class AdPaymentLoading extends OperationalState {}

class AdPaymentRequired extends OperationalState {
  final String paymentUrl;
  final int orderId; // Could be String or int depending on backend, backend sends order_id but payment_id usually string
  // Backend initialize response returns 'order_id' as int inside data.
  
  AdPaymentRequired(this.paymentUrl, this.orderId);
}

class AdApplePayRequired extends OperationalState {
  final int orderId;
  final String paymentId; // Corresponds to backend ad_payment id
  final String clientSecret;
  final double amount;
  final String currency;

  AdApplePayRequired({
    required this.orderId,
    required this.paymentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
  });
}

class AdPaymentSuccess extends OperationalState {
  final String message;
  AdPaymentSuccess(this.message); // e.g., "تم إنشاء الإعلان بنجاح"
}

class AdPaymentFailure extends OperationalState {
  final String error;
  AdPaymentFailure(this.error);
}