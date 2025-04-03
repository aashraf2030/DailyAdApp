import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'operational_state.dart';


class OperationalCubit extends Cubit<OperationalState>{

  final SharedPreferences prefs;
  late final AdsRepo repo;

  OperationalCubit(super.initialState, this.prefs)
  {
    repo = AdsRepo();
  }

  Future<bool> createNewAd(String name, String image, String imName,
      String path, int tier, int category,String keywords) async
  {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.createAd(session, id, name, image, imName, path,
        tier, category, keywords);

    emit(DoneOperational());

    return response == "Success";
  }

  Future<bool> editAd(String ad, String name, String? image, String imName,
      String path, int category,String keywords)
  async {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.editAd(session, id, ad, name, image, imName, path
        , category, keywords);

    emit(DoneOperational());

    return response == "Success";
  }

  Future<bool> watchAd(String ad)
  async {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.watch(session, id, ad);

    emit(DoneOperational());

    return response == "Success";
  }

  Future<bool> renewAd(String ad, String tier)
  async
  {
      emit(InitialOperational());
      final String id = prefs.getString("id")?? "";
      final String session = prefs.getString("session")?? "";

      final response = await repo.renew(session, id, ad, tier);

      print("Response : ${response}");

      emit(DoneOperational());

      return response == "Success";
  }
}
