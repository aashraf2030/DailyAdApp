part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLandingState extends HomeState {
  final List<AdData> ads;
  HomeLandingState(this.ads);
}

class HomeSearchState extends HomeState {
  final List<AdData> ads;
  HomeSearchState(this.ads);
}

class HomeAdsState extends HomeState {}

class HomeProfileState extends HomeState {}

class HomeAdminState extends HomeState {}

class HomeMoneyRequestState extends HomeState {}

class HomeAdRequestState extends HomeState {}