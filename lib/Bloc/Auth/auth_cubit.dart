import 'package:ads_app/Models/auth_models.dart';
import 'package:ads_app/Repos/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState>{

  final AuthRepo repo;
  final SharedPreferences prefs;
  
  UserProfile? _cachedProfile;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  AuthCubit(super.initialState, this.prefs, this.repo);

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
        prefs.remove("guest");  // إزالة وضع الزائر عند تسجيل الدخول ✅
        clearProfileCache();  // مسح الـ cache القديم
        emit(AuthDone());
        res = true;
      }
    else if (x.status == "Unverified")
      {
        prefs.setString("id", x.id ?? "");
        prefs.setString("session", x.session ?? "");
        prefs.remove("guest");  // إزالة وضع الزائر ✅
        clearProfileCache();
        emit(AuthError("Unverified"));
        res = false;
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
    print("🔍 AuthCubit.getProfile: Starting...");
    final id = prefs.getString("id");
    final session = prefs.getString("session");
    print("   ID: ${id != null ? 'exists' : 'null'}");
    print("   Session: ${session != null ? 'exists' : 'null'}");

    // Fix: إذا كان المستخدم عنده ID و Session، امسح الـ guest flag
    if (id != null && session != null && prefs.getBool("guest") == true) {
      print("⚠️ AuthCubit: Fixing guest mode flag for logged-in user");
      prefs.remove("guest");
    }

    if (isGuestMode())
    {
      print("⚠️ AuthCubit: User is in Guest Mode");
      emit(AuthDone());
      return UserProfile.guest();
    }
    
    if (!forceRefresh && 
        _cachedProfile != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      print("✅ AuthCubit: Returning cached profile (age: ${DateTime.now().difference(_lastFetchTime!).inSeconds}s)");
      emit(AuthDone());
      return _cachedProfile!;
    }

    if (id != null && session != null)
    {
      try {
        print("📡 AuthCubit: Fetching profile from backend...");
        final response = await repo.profile(id, session);
        
        _cachedProfile = response;
        _lastFetchTime = DateTime.now();
        
        print("✅ AuthCubit: Profile fetched successfully: ${response.name}");
        emit(AuthDone());
        return response;
      }
      on Exception catch (e) {
        print("❌ AuthCubit: Exception while fetching profile: $e");
        if (_cachedProfile != null) {
          print("   Returning old cached profile");
          emit(AuthDone());
          return _cachedProfile!;
        }
        
        emit(AuthError("لم نستطع استحضار الملف الشخصي"));
        return UserProfile();
      }
    }
    print("❌ AuthCubit: Invalid session");
    emit(AuthError("جلسة غير صحيحة"));
    return UserProfile();
  }
  
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
      try {
        // Get raw response to access isAdmin field directly
        final rawResponse = await repo.isAdminRaw(id, session);
        
        // Backend returns: {status: 'Valid'/'Invalid', isAdmin: true/false}
        // Check the isAdmin field directly - this is the source of truth
        if (rawResponse.containsKey("isAdmin")) {
          final isAdminValue = rawResponse["isAdmin"];
          // Handle both boolean and int (0/1) from backend
          if (isAdminValue is bool) {
            res = isAdminValue;
          } else if (isAdminValue is int) {
            res = isAdminValue == 1;
          } else if (isAdminValue is String) {
            res = isAdminValue.toLowerCase() == "true" || isAdminValue == "1";
          } else {
            // Fallback: check status
            res = rawResponse["status"] == "Valid";
          }
        } else {
          // Fallback: if no isAdmin field, check status
          res = rawResponse["status"] == "Valid";
        }
        
        // Save admin status to SharedPreferences for quick access
        prefs.setBool("isAdmin", res);
      } catch (e) {
        // On error, assume not admin
        prefs.setBool("isAdmin", false);
        res = false;
      }
    } else {
      // No session, definitely not admin
      prefs.setBool("isAdmin", false);
      res = false;
    }

    return res;
  }

  Future<bool> logout () async
  {
    if (isGuestMode())
      {
        exitGuestMode();
        clearProfileCache();
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
        clearProfileCache();
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
      // حفظ الـ session و id في SharedPreferences ✅
      if (x.id != null && x.session != null) {
        prefs.setString("id", x.id!);
        prefs.setString("session", x.session!);
        prefs.remove("guest");  // إزالة وضع الزائر
        clearProfileCache();
      }
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