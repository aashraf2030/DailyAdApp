import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/ad_models.dart';

part 'ad_state.dart';

class AdCubit extends Cubit<AdState> {
  final SharedPreferences prefs;
  final AdsRepo repo;

  AdCubit(super.initialState, this.prefs, this.repo);

  bool isGuest() {
    return prefs.getBool("guest") ?? false;
  }

  Future<List<AdData>> getUserAds() async {
    if (isGuest()) {
      if (!isClosed) {
        emit(AdDoneState([]));
      }
      return [];
    }

    emit(AdLoadingState());

    final id = prefs.getString("id") ?? "";
    final session = prefs.getString("session") ?? "";

    try {
      final response = await repo.getUserAds(session, id);
      if (!isClosed) {
        emit(AdDoneState(response));
      }
      return response;
    } on Exception{
      emit(AdErrorState());
      return [];
    }
  }

  Future<List<AdData>> fetchAds(int category, {bool? full, String? adType}) async {
    emit(AdLoadingState());

    // Get id and session - can be empty for guests
    // AuthInterceptor will handle adding token to header if session exists
    final id = prefs.getString("id") ?? "";
    final session = prefs.getString("session") ?? "";

    try {
      // This endpoint supports optional authentication (guests can view ads)
      // If user is guest, id and session will be empty strings
      // Laravel's OptionalJwtMiddleware will handle this correctly
      // adType: 'Dynamic' to fetch only Dynamic ads, null to fetch all types
      final response = await repo.fetchCatAds(session, id, category, full, adType: adType);
      if (!isClosed) {
        emit(AdDoneState(response));
      }
      return response;
    } on Exception catch (e) {
      print("Error fetching ads: $e");
      if (!isClosed) {
        emit(AdErrorState());
      }
      return [];
    }
  }
}
