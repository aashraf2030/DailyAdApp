import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/ad_models.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState>{
  final SharedPreferences prefs;
  final AdsRepo adRepo;
  
  HomeCubit(super.initialState, this.prefs, this.adRepo)
  {
    emit(HomeLoadingState());
    changeRoute(0);
  }

  int currentRoute = 0;

  List<AdData> ads = [];
  
  
  List<AdData> getFixedAds() {
    return ads.where((ad) => ad.isFixed).take(10).toList();
  }
  
  
  List<AdData> getDynamicAds() {
    return ads.where((ad) => !ad.isFixed).toList();
  }

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
        
        
        adRepo.fetchCatAds(session, id, -1, true).then((x) {
          ads = x;
          emit(HomeLandingState(ads));
        }).catchError((error) {
          print("Error fetching ads in HomeCubit: $error");
          emit(HomeLandingState([]));
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
        
        
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeAdminState());
        } else {
          
          emit(HomeStoreState());
        }
        break;

      case 5:
        
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeAdRequestState());
        } else {
          
          emit(HomeLandingState(ads));
          currentRoute = 0;
        }
        break;

      case 6:
        
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeMoneyRequestState());
        } else {
          
          emit(HomeLandingState(ads));
          currentRoute = 0;
        }
        break;

      case 7:
        emit(HomeStoreState());
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
    
    
    adRepo.fetchCatAds(session, id, -1, true).then((x) {
      ads = x;
      emit(HomeLandingState(ads));
    }).catchError((error) {
      print("Error refreshing ads in HomeCubit: $error");
      emit(HomeLandingState(ads)); 
    });
  }
}