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
  
  // دالة لجلب الإعلانات الثابتة فقط
  List<AdData> getFixedAds() {
    return ads.where((ad) => ad.isFixed).take(10).toList();
  }
  
  // دالة لجلب الإعلانات المتغيرة فقط
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
        // Get id and session - can be empty for guests
        // AuthInterceptor will handle adding token to header if session exists
        final session = prefs.getString("session") ?? "";
        final id = prefs.getString("id") ?? "";
        // Fetch all ads (category -1 means all categories, full=true means all ads including Dynamic)
        // This endpoint supports optional authentication (guests can view ads)
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
        // للمستخدم العادي: الدردشة
        // للمسؤول: لوحة الإدارة
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeAdminState());
        } else {
          // المستخدم العادي - المتجر (بدل الدردشة)
          emit(HomeStoreState());
        }
        break;

      case 5:
        // فحص بسيط من SharedPreferences (طبقة حماية إضافية)
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeAdRequestState());
        } else {
          // إذا لم يكن مسؤول، العودة للصفحة الرئيسية
          emit(HomeLandingState(ads));
          currentRoute = 0;
        }
        break;

      case 6:
        // فحص بسيط من SharedPreferences (طبقة حماية إضافية)
        final isAdmin = prefs.getBool("isAdmin") ?? false;
        if (isAdmin) {
          emit(HomeMoneyRequestState());
        } else {
          // إذا لم يكن مسؤول، العودة للصفحة الرئيسية
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
    // Get id and session - can be empty for guests
    // AuthInterceptor will handle adding token to header if session exists
    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";
    // Fetch all ads (category -1 means all categories, full=true means all ads including Dynamic)
    // This endpoint supports optional authentication (guests can view ads)
    adRepo.fetchCatAds(session, id, -1, true).then((x) {
      ads = x;
      emit(HomeLandingState(ads));
    }).catchError((error) {
      print("Error refreshing ads in HomeCubit: $error");
      emit(HomeLandingState(ads)); // Keep existing ads on error
    });
  }
}