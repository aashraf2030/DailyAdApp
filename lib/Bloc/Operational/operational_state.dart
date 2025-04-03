part of 'operational_cubit.dart';

@immutable
abstract class OperationalState {}

class InitialOperational extends OperationalState {}

class DoneOperational extends OperationalState {}