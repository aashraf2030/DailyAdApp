import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/ad_models.dart';


part 'ad_state.dart';


class AdCubit extends Cubit<AdState>
{
  AdCubit(super.initialState, this.prefs)
  {
    repo = AdsRepo();
  }

  final SharedPreferences prefs;
  late final AdsRepo repo;

  Future<List<AdData>> getUserAds() async
  {
    emit(AdLoadingState());

    final id = prefs.getString("id")?? "";
    final session = prefs.getString("session")?? "";

    try
    {
      final response = await repo.getUserAds(session, id);

      emit(AdDoneState(response));
      return response;
    }
    on Exception catch (e)
    {
      emit(AdErrorState());
      return [];
    }
  }

  Future<List<AdData>> fetchAds(int category, {bool? full}) async
  {
    emit(AdLoadingState());

    final id = prefs.getString("id")?? "";
    final session = prefs.getString("session")?? "";

    try
    {
      final response = await repo.fetchCatAds(session, id, category, full);

      emit(AdDoneState(response));
      return response;
    }
    on Exception catch (e)
    {
      emit(AdErrorState());
      return [];
    }
  }
}