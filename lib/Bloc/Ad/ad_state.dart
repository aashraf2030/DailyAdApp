part of 'ad_cubit.dart';

@immutable
abstract class AdState {}

class AdInitialState extends AdState {}

class AdLoadingState extends AdState
{
  AdLoadingState({this.size = 10});
  final int size;
}

class AdDoneState extends AdState
{
  AdDoneState(this.data);
  final List<AdData> data;
}

class AdErrorState extends AdState {}
