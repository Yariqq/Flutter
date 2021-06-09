import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:toast/toast.dart';

class APIREP {

  static String _token;

  static Map<String, String> _headers;

  String get token => _token;

  static set setToken(String value) {
    _token = value;
    _headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: tokenType + _token
    };
  }

  static void removeToken(){
    _token = null;
    _headers = { };
  }

  Future<Response> login(String username, String password) async {
    print(loginRequestUrl);
    final response = await post(
        Uri.parse(loginRequestUrl),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: "{ \"email\":\"$username\", \"password\":\"$password\"}"
    );
    return response;
  }

  Future<Response> getUsers(BuildContext context) async {
    final response = await get(
        Uri.parse(usersActionsRequestUrl),
        headers: _headers
    );
    return checkResponseStatusCode(response, context);
  }

  Future<Response> getUserById(int userId, BuildContext context) async {
    final response = await get(
        Uri.parse(usersActionsRequestUrl + '/' + userId.toString()),
        headers: _headers
    );
    return checkResponseStatusCode(response, context);
  }

  Future<Response> update(String name, String email, String position,
      bool enabled, bool superAdmin, int userId) async {
    final response = await put(
        Uri.parse(usersActionsRequestUrl + '/' + userId.toString()),
        headers: _headers,
        body: "{\n \"name\":\"$name\","
            "\n \"email\":\"$email\","
            "\n \"position\":\"$position\","
            "\n \"enabled\":$enabled,"
            "\n \"superadmin\":$superAdmin\n}"
    );
    return response;
  }

  Response checkResponseStatusCode(Response response, BuildContext context) {
    if (response.statusCode == HttpStatus.ok)
      return response;
    else {
      String errorMessage = json.decode(response.body)['msg'];
      Toast.show(errorMessage, context, duration: Toast.LENGTH_LONG);
      return null;
    }
  }

  static String get loginRequestUrl => currentUrl + '/api/v2/login';
  static String get usersActionsRequestUrl => currentUrl + '/api/v2/admin/admin-users';
  static String tokenType = 'Bearer ';