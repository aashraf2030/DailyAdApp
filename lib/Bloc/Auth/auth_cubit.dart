import 'package:ads_app/Models/auth_models.dart';
import 'package:ads_app/Repos/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState>{

  late final AuthRepo repo;
  final SharedPreferences prefs;
  
  // Cache للبروفايل
  UserProfile? _cachedProfile;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // مدة الـ cache

  AuthCubit(super.initialState, this.prefs){
    repo = AuthRepo();
  }

  void enterGuestMode()
  {
    prefs.setBool("guest", true);
    prefs.remove("id");
    prefs.remove("session");
  }

  void exitGuestMode()
  {
    prefs.clear();
  }

  Future<bool> login(String user, String pass) async
  {
    bool res = false;

    final x = await repo.login(user, pass);
    if (x.status == "Success")
      {
        emit(AuthDone());
        res = true;
      }
    else if (x.status == "Valid")
      {
        prefs.setString("id", x.id ?? "");
        prefs.setString("session", x.session ?? "");
        emit(AuthDone());
        res = true;
      }
    else if (x.status == "Invalid Auth")
      {
        emit(AuthInvalid());
        res = false;
      }
    else{
      emit(AuthError(x.status));
      res = false;
    }
    return res;
  }

  Future<UserProfile> getProfile({bool forceRefresh = false}) async{
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    if (isGuestMode())
    {
      emit(AuthDone());
      return UserProfile.guest();
    }
    
    // استخدام الـ cache إذا كان موجود وحديث ومش محتاجين refresh
    if (!forceRefresh && 
        _cachedProfile != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      emit(AuthDone());
      return _cachedProfile!;
    }

    if (id != null && session != null)
    {
      try {
        final response = await repo.profile(id, session);
        
        // حفظ في الـ cache
        _cachedProfile = response;
        _lastFetchTime = DateTime.now();
        
        emit(AuthDone());
        return response;
      }
      on Exception{
        // إذا فشل الطلب واحنا عندنا cache قديم، نرجعه
        if (_cachedProfile != null) {
          emit(AuthDone());
          return _cachedProfile!;
        }
        
        emit(AuthError("لم نستطع استحضار الملف الشخصي"));
        return UserProfile();
      }
    }
    emit(AuthError("جلسة غير صحيحة"));
    return UserProfile();
  }
  
  // دالة لمسح الـ cache
  void clearProfileCache() {
    _cachedProfile = null;
    _lastFetchTime = null;
  }

  Future<bool> isLoggedIn () async
  {
    if (prefs.getBool("guest")?? false)
      {
        return true;
      }

    final id = prefs.getString("id");
    final session = prefs.getString("session");

    bool res = false;

    if (id != null && session != null)
      {

        final response = await repo.isLoggedIn(id, session);

        if (response.status == "Valid")
        {
          emit(AuthDone());
          res = true;
        }

      }

    return res;
  }

  bool isGuestMode()
  {
    return prefs.getBool("guest")?? false;
  }

  Future<bool> isAdmin () async
  {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    bool res = false;

    if (id != null && session != null)
    {

      final response = await repo.isAdmin(id, session);

      if (response.status == "Valid")
      {
        res = true;
      }
    }

    return res;
  }

  Future<bool> logout () async
  {
    if (isGuestMode())
      {
        exitGuestMode();
        clearProfileCache(); // مسح الـ cache
        return true;
      }

    final id = prefs.getString("id");
    final session = prefs.getString("session");

    bool res = false;

    if (id != null && session != null)
    {

      final response = await repo.logout(id, session);

      if (response.status == "Valid")
      {
        clearProfileCache(); // مسح الـ cache
        res = true;
      }
    }

    return res;
  }

  Future<bool> delete () async
  {
    if (isGuestMode())
      {
        exitGuestMode();
        return true;
      }

    final id = prefs.getString("id");
    final session = prefs.getString("session");

    bool res = false;

    if (id != null && session != null)
    {

      final response = await repo.delete(id, session);

      if (response.status == "Success")
      {
        res = true;
      }
    }

    return res;
  }

  Future<bool> register (String name, String user,
      String pass, String email, String? phone) async
  {
    final x = await repo.register(name, user, pass, email, phone);

    if (x.status == "Success") {
      emit(AuthDone());
      return true;
    }
    else if (x.status == "User Exists")
      {
        emit(AuthError("Existed User"));
        return false;
      }
    else
      {
        emit(AuthInvalid());
        return false;
      }
  }

  Future<bool> verify(String code) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.verify(id?? "", session?? "", code);

    if (x.status == "Success")
      {
        emit(AuthDone());
        return true;
      }
    else if (x.status == "Invalid Request")
      {
        emit(AuthInvalid());
        return false;
      }
    else
      {
        emit(AuthError(x.status));
        return false;
      }
  }

  Future<bool> sendCode({bool passReset = false}) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.sendCode(id?? "", session?? "", passReset);

    if (x.status == "Success")
      {
        emit(AuthDone());
        return true;
      }
    else if (x.status == "Invalid Request")
      {
        emit(AuthInvalid());
        return false;
      }
    else
      {
        emit(AuthError(x.status));
        return false;
      }
  }

  Future<bool> verifyCheck() async {

    if (isGuestMode()) {
      return true;
    }

    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.verifyCheck(id?? "", session?? "");

    if (x.status == "Success")
    {
      emit(AuthDone());
      return true;
    }
    else if (x.status == "Invalid Request")
    {
      emit(AuthInvalid());
      return false;
    }
    else
    {
      emit(AuthError(x.status));
      return false;
    }
  }

  Future<bool> changePass(String pass) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.changePass(id?? "", session?? "", pass);

    if (x.status == "Success")
    {
      emit(AuthDone());
      return true;
    }
    else if (x.status == "Invalid Request")
    {
      emit(AuthInvalid());
      return false;
    }
    else
    {
      emit(AuthError(x.status));
      return false;
    }
  }

  Future<bool> resetPass(String email) async {

    final x = await repo.resetPass(email);

    if (x.status == "Valid")
    {
      prefs.setString("id", x.id?? "");
      prefs.setString("session", x.session?? "");
      emit(AuthDone());
      return true;
    }
    else if (x.status == "Invalid Request")
    {
      emit(AuthInvalid());
      return false;
    }
    else
    {
      emit(AuthError(x.status));
      return false;
    }
  }

  Future<bool> validateResetPass(String code) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.validateResetPass(id?? "", session?? "", code);

    if (x.status == "Success")
    {
      emit(AuthDone());
      return true;
    }
    else if (x.status == "Invalid Request")
    {
      emit(AuthInvalid());
      return false;
    }
    else
    {
      emit(AuthError(x.status));
      return false;
    }
  }
}