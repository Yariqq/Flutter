import 'dart:convert';
import 'package:admin_client/data/repository/ISharedPrefRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefRepository implements ISharedPrefRepository {

  static final SharedPrefRepository _singleton =
  new SharedPrefRepository._internal();

  factory SharedPrefRepository() {
    return _singleton;
  }

  SharedPrefRepository._internal();

  @override
  Future<bool> setUserToken(String userToken) async {
    // AppDrawerController.isAuth = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserToken, userToken);
  }

  @override
  Future<String> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserToken);
  }

  @override
  Future<bool> removeUserToken() async {
    // AppDrawerController.isAuth = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(keyUserToken);
  }

  @override
  Future<bool> setLocalizedStrings(Map<String, String> localizedStrings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String localized = json.encode(localizedStrings);
    return prefs.setString(keyLocalizedStrings, localized);
  }

  @override
  Future<Map<String, dynamic>> getLocalizedStrings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(keyLocalizedStrings));
  }
}

const keyLocalizedStrings = 'KEY_LOCALIZED_STRINGS';
const keyUserToken = 'KEY_USER_TOKEN';