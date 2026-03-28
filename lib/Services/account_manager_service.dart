import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/saved_account_model.dart';

class AccountManagerService {
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;
  
  static const String _savedAccountsKey = 'saved_accounts';
  static const String _passwordPrefix = 'account_password_';

  AccountManagerService(this.prefs, this.secureStorage);

  
  Future<bool> saveAccount({
    required String username,
    required String password,
    required String name,
    required String userId,
  }) async {
    try {
      
      final accounts = await getSavedAccounts();
      
      
      if (accounts.any((acc) => acc.userId == userId)) {
        
        await removeAccount(userId);
      }

      
      final account = SavedAccount(
        username: username,
        name: name,
        userId: userId,
        avatarLetter: SavedAccount.getAvatarLetter(name),
        savedAt: DateTime.now(),
      );

      
      accounts.add(account);

      
      final accountsJson = accounts.map((acc) => acc.toJson()).toList();
      await prefs.setString(_savedAccountsKey, jsonEncode(accountsJson));

      
      await secureStorage.write(
        key: '$_passwordPrefix$userId',
        value: password,
      );

      return true;
    } catch (e) {
      print('Error saving account: $e');
      return false;
    }
  }

  
  Future<List<SavedAccount>> getSavedAccounts() async {
    try {
      final accountsJson = prefs.getString(_savedAccountsKey);
      if (accountsJson == null || accountsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(accountsJson);
      return decoded
          .map((json) => SavedAccount.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting saved accounts: $e');
      return [];
    }
  }

  
  Future<String?> getPassword(String userId) async {
    try {
      return await secureStorage.read(key: '$_passwordPrefix$userId');
    } catch (e) {
      print('Error getting password: $e');
      return null;
    }
  }

  
  Future<bool> removeAccount(String userId) async {
    try {
      
      final accounts = await getSavedAccounts();
      
      
      accounts.removeWhere((acc) => acc.userId == userId);

      
      final accountsJson = accounts.map((acc) => acc.toJson()).toList();
      await prefs.setString(_savedAccountsKey, jsonEncode(accountsJson));

      
      await secureStorage.delete(key: '$_passwordPrefix$userId');

      return true;
    } catch (e) {
      print('Error removing account: $e');
      return false;
    }
  }

  
  Future<bool> isAccountSaved(String userId) async {
    final accounts = await getSavedAccounts();
    return accounts.any((acc) => acc.userId == userId);
  }

  
  Future<bool> clearAllAccounts() async {
    try {
      final accounts = await getSavedAccounts();
      
      
      for (final account in accounts) {
        await secureStorage.delete(key: '$_passwordPrefix${account.userId}');
      }

      
      await prefs.remove(_savedAccountsKey);
      return true;
    } catch (e) {
      print('Error clearing all accounts: $e');
      return false;
    }
  }
}

