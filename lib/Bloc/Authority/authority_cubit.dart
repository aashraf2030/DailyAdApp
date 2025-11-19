import 'dart:io';

import 'package:ads_app/Models/authority_models.dart';
import 'package:ads_app/Models/user_models.dart';
import 'package:ads_app/Repos/authority_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'authority_state.dart';

class AuthorityCubit extends Cubit<AuthorityState> {
  final SharedPreferences prefs;
  final AuthorityRepo repo;

  AuthorityCubit(super.initialState, this.prefs, this.repo);

  Future<List<UserRequest>> getUserRequests(String? tier) async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      List<UserRequest> res = [];
      
      // Get Create requests (default_req)
      final res1 = await repo.getDefaultReq(session, id, tier);
      
      // Get Renew requests (renew_req) - now filtered by backend
      final res2 = await repo.getRenewReq(session, id, tier);

      // Combine and remove duplicates based on reqid
      final Map<String, UserRequest> uniqueRequests = {};
      
      for (var req in res1) {
        if (req is DefaultRequest) {
          uniqueRequests[req.id] = req;
        }
      }
      
      for (var req in res2) {
        if (req is RenewRequest) {
          uniqueRequests[req.id] = req;
        }
      }
      
      res = uniqueRequests.values.toList();
      res.shuffle();

      emit(AuthorityRequestDone(res));
      return res;
    } on Exception{
      emit(AuthorityError());
      return [];
    }
  }

  Future<List<UserRequest>> getDefault(String? tier) async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.getDefaultReq(session, id, tier);

      emit(AuthorityRequestDone(res));
      return res;
    } on Exception{
      emit(AuthorityError());
      return [];
    }
  }

  Future<List<UserRequest>> getRenewRequest(String? tier) async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.getRenewReq(session, id, tier);

      emit(AuthorityRequestDone(res));
      return res;
    } on Exception{
      emit(AuthorityError());
      return [];
    }
  }

  Future<List<UserRequest>> getMoneyRequest() async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.getMoneyReq(session, id);

      print(res);

      emit(AuthorityRequestDone(res));
      return res;
    } on Exception{
      emit(AuthorityError());
      return [];
    }
  }

  Future<List<UserRequest>> getMyRequest() async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.getMyReq(session, id);

      emit(AuthorityRequestDone(res));
      return res;
    } on Exception{
      emit(AuthorityError());
      return [];
    }
  }

  Future<bool> handleRequest(String req, bool state) async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.handleRequest(session, id, req, state);

      if (res == "Success") {
        if (!isClosed) {
          emit(AuthoritySuccess());
        }
        return true;
      } else {
        emit(AuthorityError());
        return false;
      }
    } on Exception{
      emit(AuthorityError());
      return false;
    }
  }

  Future<bool> deleteRequest(String req) async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.deleteRequest(session, id, req);

      if (res == "Success") {
        if (!isClosed) {
          emit(AuthoritySuccess());
        }
        return true;
      } else {
        emit(AuthorityError());
        return false;
      }
    } on Exception{
      emit(AuthorityError());
      return false;
    }
  }

  Future<bool> exchangePoints() async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.exchangeRequest(session, id);

      if (res == "Success") {
        if (!isClosed) {
          emit(AuthoritySuccess());
        }
        return true;
      } else {
        emit(AuthorityError());
        return false;
      }
    } on Exception{
      emit(AuthorityError());
      return false;
    }
  }

  Future<List<LeaderboardUser>> getLeaderboard() async {
    emit(AuthorityLoading());

    final session = prefs.getString("session") ?? "";
    final id = prefs.getString("id") ?? "";

    try {
      final res = await repo.getLeaderboard(session, id);

      emit(LeaderboardState(res));
      return res;
    } on StdinException{
      emit(AuthorityError());
      return [];
    }
  }
}
