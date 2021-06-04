
import 'dart:convert';
import 'dart:io';
import 'package:admin_client/data/repository/ApiRepository.dart';
import 'package:admin_client/data/repository/SharedPrefRepository.dart';
import 'package:admin_client/ui/BasePage/BaseRxBloC.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart';

class LoginBloC extends BaseRxBloC {

  // ignore: close_sinks
  BehaviorSubject<String> _loginEventSubject;
  Stream<String> get loginEventStream => _loginEventSubject.stream;

  void loginEvent({String message}) {
    _loginEventSubject.sink.add(message);
  }

  void loginErrorEvent(String message) {
    _loginEventSubject.sink.addError(message);
  }

  @override
  void initSubjects(List<Subject> subjects) {
    _loginEventSubject = BehaviorSubject();
    subjects.add(_loginEventSubject);
  }

  void login(String username, String password) async {
    Response loginResponse = await ApiRepository().login(username, password);
    if(loginResponse.statusCode == HttpStatus.ok) {
      SharedPrefRepository().setUserToken(json.decode(loginResponse.body)['token']);
      ApiRepository.setToken = json.decode(loginResponse.body)['token'];
      loginEvent();
    } else {
      String errorMessage = json.decode(loginResponse.body)['msg'];
      loginErrorEvent(errorMessage);
    }
  }

}