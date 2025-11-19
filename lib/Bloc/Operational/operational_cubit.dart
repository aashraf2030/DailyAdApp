import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

part 'operational_state.dart';


class OperationalCubit extends Cubit<OperationalState>{

  final SharedPreferences prefs;
  final AdsRepo repo;

  OperationalCubit(super.initialState, this.prefs, this.repo);

  bool isGuest()
  {
    return prefs.getBool("guest") ?? false;
  }

  /// Check if an ad belongs to the current user
  bool isMyAd(String? adUserId) {
    if (isGuest() || adUserId == null) {
      return false;
    }
    final currentUserId = prefs.getString("id");
    return currentUserId != null && currentUserId == adUserId;
  }

  Future<bool> createNewAd(String name, String image, String imName,
      String path, String type, int targetViews, int category,String keywords) async
  {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    try {
      final imageFile = XFile(image);
      final bytes = await imageFile.readAsBytes();
      
      final response = await repo.createAdWithBytes(
        session, id, name, bytes, imName, path, type, targetViews, category, keywords
      );

      emit(DoneOperational());

      return response == "Success";
    } catch (e) {
      print("Error creating ad: $e");
      emit(DoneOperational());
      return false;
    }
  }

  Future<bool> editAd(String ad, String name, String? image, String imName,
      String path, String type, int targetViews, int category,String keywords)
  async {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.editAd(session, id, ad, name, type, targetViews, image, imName, path
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

      print("Response : $response");

      emit(DoneOperational());

      return response == "Success";
  }
}
