part of 'operational_cubit.dart';

@immutable
abstract class OperationalState {}

class InitialOperational extends OperationalState {}

class DoneOperational extends OperationalState {}

class AdPaymentLoading extends OperationalState {}

class AdPaymentRequired extends OperationalState {
  final String paymentUrl;
  final int orderId; 
  
  
  AdPaymentRequired(this.paymentUrl, this.orderId);
}

class AdApplePayRequired extends OperationalState {
  final int orderId;
  final String paymentId; 
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
  AdPaymentSuccess(this.message); 
}

class AdPaymentFailure extends OperationalState {
  final String error;
  AdPaymentFailure(this.error);
}


class AdCouponLoading extends OperationalState {}

class AdCouponValid extends OperationalState {
  final double discountAmount;
  final double newTotal;
  final String code;
  AdCouponValid(this.discountAmount, this.newTotal, this.code);
}

class AdCouponInvalid extends OperationalState {
  final String error;
  AdCouponInvalid(this.error);
}