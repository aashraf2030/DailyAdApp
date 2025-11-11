import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/ad_models.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState>{
  final SharedPreferences prefs;
  
  HomeCubit(super.initialState, this.prefs)
  {
    adRepo = AdsRepo();
    emit(HomeLoadingState());
    changeRoute(0);
  }

  int currentRoute = 0;
  late final AdsRepo adRepo;

  List<AdData> ads = [];

  int changeRoute (int i)
  {
    if (currentRoute == i && state is! HomeLoadingState) return i;
    currentRoute = i;
    switch (i)
    {
      case 0:
        emit(HomeLoadingState());
        final session = prefs.getString("session") ?? "";
        final id = prefs.getString("id") ?? "";
        // جلب Fixed Ads فقط للعرض في الـ Slider
        // category: -1 = Fixed Ads only
        adRepo.fetchCatAds(session, id, -1, true).then((x) {
          ads = x;
          emit(HomeLandingState(ads));
        });
        break;

      case 1:
        emit(HomeSearchState(ads));
        break;

      case 2:
        emit(HomeAdsState());
        break;

      case 3:
        emit(HomeProfileState());
        break;

      case 4:
        emit(HomeAdminState());
        break;

      case 5:
        emit(HomeAdRequestState());
        break;

      case 6:
        emit(HomeMoneyRequestState());
        break;

      default:
        emit(HomeLandingState(ads));
    }


    return i;
  }

  void refresh()
  {
    emit(HomeLoadingState());
    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";
    // تحديث Fixed Ads للـ Slider
    adRepo.fetchCatAds(session, id, -1, true).then((x) {
      ads = x;
      emit(HomeLandingState(ads));
    });
  }
}