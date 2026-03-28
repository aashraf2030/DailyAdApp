import 'package:ads_app/Models/auth_models.dart';
import '../../core/utils/error_mapper.dart';
import 'package:ads_app/Models/saved_account_model.dart';
import 'package:ads_app/Repos/auth_repo.dart';
import 'package:ads_app/Services/account_manager_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState>{

  final AuthRepo repo;
  final SharedPreferences prefs;
  final AccountManagerService? accountManager;
  
  UserProfile? _cachedProfile;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  AuthCubit(super.initialState, this.prefs, this.repo, [this.accountManager]);

  void enterGuestMode()
  {
    prefs.setBool("guest", true);
    prefs.remove("id");
    prefs.remove("session");
  }

  void exitGuestMode()
  {
    
    prefs.remove("guest");
    prefs.remove("id");
    prefs.remove("session");
    prefs.remove("isAdmin");
  }

  Future<Map<String, dynamic>> login(String user, String pass, {bool rememberMe = false}) async
  {
    Map<String, dynamic> result = {
      'success': false,
      'welcome_bonus': false,
      'bonus_points': 0,
    };

    final x = await repo.login(user, pass);
    if (x.status == "Success")
      {
        emit(AuthDone());
        result['success'] = true;
      }
    else if (x.status == "Valid")
      {
        prefs.setString("id", x.id ?? "");
        prefs.setString("session", x.session ?? "");
        prefs.remove("guest");  
        clearProfileCache();  
        
        
        await isAdmin(forceRefresh: true);
        
        
        result['welcome_bonus'] = x.welcomeBonus ?? false;
        result['bonus_points'] = x.bonusPoints ?? 0;
        
        
        if (rememberMe && accountManager != null && x.id != null) {
          
          
          Future.microtask(() async {
            try {
              String userName = user;
              try {
                
                await Future.delayed(Duration(milliseconds: 100));
                final profile = await getProfile(forceRefresh: true);
                if (profile.name.isNotEmpty && profile.name != "Invalid") {
                  userName = profile.name;
                }
              } catch (e) {
                
                print('Could not fetch profile for account name, using username: $e');
              }
              
              await accountManager!.saveAccount(
                username: user,
                password: pass,
                name: userName,
                userId: x.id!,
              );
            } catch (e) {
              print('Error saving account: $e');
            }
          });
        }
        
        emit(AuthDone());
        result['success'] = true;
      }
    else if (x.status == "Unverified")
      {
        prefs.setString("id", x.id ?? "");
        prefs.setString("session", x.session ?? "");
        prefs.remove("guest");  
        clearProfileCache();
        emit(AuthError("Unverified"));
        result['success'] = false;
      }
    else if (x.status == "Invalid Auth")
      {
        emit(AuthInvalid());
        result['success'] = false;
      }
    else{
      String msg = x.status;
      if (msg == "Error" || msg.toLowerCase().contains("exception")) {
         msg = "حدث خطأ أثناء تسجيل الدخول";
      } else if (msg == "Unverified") {
         msg = "الحساب غير مفعل";
      }
      emit(AuthError(msg));
      result['success'] = false;
    }
    return result;
  }

  Future<UserProfile> getProfile({bool forceRefresh = false}) async{
    print("🔍 AuthCubit.getProfile: Starting...");
    final id = prefs.getString("id");
    final session = prefs.getString("session");
    print("   ID: ${id != null ? 'exists' : 'null'}");
    print("   Session: ${session != null ? 'exists' : 'null'}");

    
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
        
        
        if (response.name.isEmpty || response.name == "Invalid") {
          throw Exception("Invalid profile response");
        }
        
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
        
        final failure = ErrorMapper.map(e);
        emit(AuthError(failure.message));
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
    print("🟡 [AUTH] isLoggedIn called");
    if (prefs.getBool("guest")?? false)
      {
        print("🟡 [AUTH] User is in guest mode - returning true");
        return true;
      }

    try {
      final id = prefs.getString("id");
      final session = prefs.getString("session");
      print("🟡 [AUTH] Session check - id: ${id != null ? 'exists' : 'null'}, session: ${session != null ? 'exists' : 'null'}");

      bool res = false;

      if (id != null && session != null)
        {

          print("🟡 [AUTH] Calling repo.isLoggedIn...");
          final response = await repo.isLoggedIn(id, session);
          print("🟡 [AUTH] repo.isLoggedIn response: ${response.status}");

          if (response.status == "Valid")
          {
            print("🟡 [AUTH] Session valid - emitting AuthDone");
            emit(AuthDone());
            res = true;
          } else {
            print("🟡 [AUTH] Session not valid: ${response.status}");
          }

        } else {
        print("🟡 [AUTH] No id/session - returning false");
      }

      print("🟡 [AUTH] isLoggedIn returning: $res");
      return res;
    } catch (e, stackTrace) {
      print("🔴 [AUTH] isLoggedIn Error: $e");
      print("🔴 [AUTH] Stack trace: $stackTrace");
      return false;
    }
  }

  bool isGuestMode()
  {
    return prefs.getBool("guest")?? false;
  }

  Future<bool> isAdmin({bool forceRefresh = false}) async {
    print("🟣 [AUTH] isAdmin called (forceRefresh: $forceRefresh)");
    
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    
    if (id == null || session == null) {
      print("🟣 [AUTH] No session - not admin");
      prefs.setBool("isAdmin", false);
      return false;
    }

    
    if (!forceRefresh) {
      final cachedIsAdmin = prefs.getBool("isAdmin");
      if (cachedIsAdmin != null) {
        print("🟣 [AUTH] Using cached isAdmin value: $cachedIsAdmin");
        return cachedIsAdmin;
      }
      print("🟣 [AUTH] No cached value, fetching from backend...");
    } else {
      print("🟣 [AUTH] Force refresh requested, fetching from backend...");
    }

    
    bool res = false;
    try {
      
      final rawResponse = await repo.isAdminRaw(id, session);
      
      
      
      if (rawResponse.containsKey("isAdmin")) {
        final isAdminValue = rawResponse["isAdmin"];
        
        if (isAdminValue is bool) {
          res = isAdminValue;
        } else if (isAdminValue is int) {
          res = isAdminValue == 1;
        } else if (isAdminValue is String) {
          res = isAdminValue.toLowerCase() == "true" || isAdminValue == "1";
        } else {
          
          res = rawResponse["status"] == "Valid";
        }
      } else {
        
        res = rawResponse["status"] == "Valid";
      }
      
      
      prefs.setBool("isAdmin", res);
      print("🟣 [AUTH] Fetched and cached isAdmin: $res");
    } catch (e) {
      print("🔴 [AUTH] isAdmin Error: $e");
      
      final cachedIsAdmin = prefs.getBool("isAdmin") ?? false;
      prefs.setBool("isAdmin", cachedIsAdmin);
      res = cachedIsAdmin;
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
        
        prefs.remove("id");
        prefs.remove("session");
        prefs.remove("isAdmin");
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
        
        prefs.remove("id");
        prefs.remove("session");
        prefs.remove("isAdmin");
        clearProfileCache();
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
      
      if (x.id != null && x.session != null) {
        prefs.setString("id", x.id!);
        prefs.setString("session", x.session!);
        prefs.remove("guest");  
        clearProfileCache();
      }
      emit(AuthDone());
      return true;
    }
    else if (x.status == "User Exists")
      {
        emit(AuthError("هذا المستخدم مسجل بالفعل"));
        return false;
      }
    else
      {
        String msg = x.status;
        if (msg == "Error" || msg.toLowerCase().contains("exception")) {
           msg = "حدث خطأ أثناء إنشاء الحساب";
        }
        emit(AuthError(msg));
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
        String msg = x.status;
        if (msg == "Error" || msg.toLowerCase().contains("exception")) {
           msg = "فشل التحقق من الكود";
        }
        emit(AuthError(msg));
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
        String msg = x.status;
        if (msg == "Error" || msg.toLowerCase().contains("exception")) {
           msg = "فشل إرسال الكود";
        }
        emit(AuthError(msg));
        return false;
      }
  }

  Future<bool> verifyCheck() async {
    try {
      if (isGuestMode()) {
        return true;
      }

      final id = prefs.getString("id");
      final session = prefs.getString("session");

      final x = await repo.verifyCheck(id ?? "", session ?? "");

      if (x.status == "Success") {
        emit(AuthDone());
        return true;
      } else if (x.status == "Invalid Request") {
        emit(AuthInvalid());
        return false;
      } else {
        String msg = x.status;
        if (msg == "Error" || msg.toLowerCase().contains("exception")) {
          msg = "فشل التحقق من الحساب";
        }
        emit(AuthError(msg));
        return false;
      }
    } catch (e) {
      print("🔴 [AUTH] verifyCheck Error: $e");
      return false;
    }
  }

  Future<bool> changePass(String pass) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.changePass(session?? "", pass);

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
      String msg = x.status;
      if (msg == "Error" || msg.toLowerCase().contains("exception")) {
         msg = "فشل تغيير كلمة المرور";
      }
      emit(AuthError(msg));
      return false;
    }
  }

  Future<bool> resetPass(String email) async {

    final x = await repo.resetPass(email);

    if (x.status == "Valid")
    {
      prefs.setString("id", x.id?? "");
      prefs.setString("session", x.session?? "");
      prefs.remove("guest");  
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
      String msg = x.status;
       if (msg == "Invalid Email") {
         msg = "البريد الإلكتروني غير مسجل";
       } else if (msg == "Error" || msg.toLowerCase().contains("exception")) {
         msg = "حدث خطأ أثناء إعادة تعيين كلمة المرور";
       }
      emit(AuthError(msg));
      return false;
    }
  }

  Future<bool> validateResetPass(String code) async {
    final id = prefs.getString("id");
    final session = prefs.getString("session");

    final x = await repo.validateResetPass(session?? "", code);

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
      String msg = x.status;
      if (msg == "Error" || msg.toLowerCase().contains("exception")) {
         msg = "فشل التحقق من الكود";
      }
      emit(AuthError(msg));
      return false;
    }
  }

  
  
  

  
  Future<List<SavedAccount>> getSavedAccounts() async {
    if (accountManager == null) return [];
    return await accountManager!.getSavedAccounts();
  }

  
  Future<SavedAccount?> getCurrentAccount() async {
    final id = prefs.getString("id");
    if (id == null) return null;
    
    final accounts = await getSavedAccounts();
    try {
      return accounts.firstWhere((acc) => acc.userId == id);
    } catch (e) {
      return null;
    }
  }

  
  Future<bool> switchAccount(SavedAccount account) async {
    if (accountManager == null) return false;
    
    try {
      
      final password = await accountManager!.getPassword(account.userId);
      if (password == null) {
        emit(AuthError("كلمة المرور غير موجودة"));
        return false;
      }

      
      final loginResult = await login(account.username, password, rememberMe: false);
      
      if (loginResult['success'] == true) {
        clearProfileCache();
        emit(AuthDone());
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error switching account: $e');
      emit(AuthError("فشل التبديل إلى الحساب"));
      return false;
    }
  }

  
  Future<bool> removeSavedAccount(SavedAccount account) async {
    if (accountManager == null) return false;
    
    try {
      final success = await accountManager!.removeAccount(account.userId);
      if (success) {
        emit(AuthDone());
      }
      return success;
    } catch (e) {
      print('Error removing account: $e');
      return false;
    }
  }

  
  Future<bool> saveAccountForRememberMe(String username, String password) async {
    if (accountManager == null) return false;
    
    final id = prefs.getString("id");
    if (id == null) return false;
    
    try {
      final profile = await getProfile(forceRefresh: true);
      return await accountManager!.saveAccount(
        username: username,
        password: password,
        name: profile.name.isNotEmpty ? profile.name : username,
        userId: id,
      );
    } catch (e) {
      print('Error saving account: $e');
      return false;
    }
  }
}