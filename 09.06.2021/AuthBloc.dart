import 'dart:convert';
import 'dart:io';

import 'package:app/src/data/controllers/PriceRuleController.dart';
import 'package:app/src/data/model/PriceRuleModel.dart';
import 'package:app/src/data/repository/ApiRepository.dart';
import 'package:app/src/data/repository/IApiRepository.dart';
import 'package:app/src/data/repository/ISharedPrefRepository.dart';
import 'package:app/src/data/repository/SharedPreferences.dart';
import 'package:app/src/ui/BasePage/BaseRxBloC.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthBloc extends BaseRxBloC {

  AuthBloc(this._apiRepository, this._sharedPrefRepository) {
    initEvent();
  }

  final ISharedPrefRepository _sharedPrefRepository;
  final IApiRepository _apiRepository;

  // ignore: close_sinks
  BehaviorSubject<String> _loginEventSubject;
  Stream<String> get loginEventStream => _loginEventSubject.stream;

  // ignore: close_sinks
  BehaviorSubject<String> _signUpEventSubject;
  Stream<String> get signInEventStream => _signUpEventSubject.stream;

  void loginEvent({String message}) {
    _loginEventSubject.sink.add(message);
  }

  void loginErrorEvent(String message) {

    _loginEventSubject.sink.addError(message);
  }

  void signUpEvent({String message}) {
    _signUpEventSubject.sink.add(message);
  }

  void signUpErrorEvent(String message) {
    _signUpEventSubject.sink.addError(message);
  }


  void initEvent() {

  }

  void setDefaultPriceRule() {
    PriceRuleController.currentPriceRule = PriceRuleController.ruleBase;
    _sharedPrefRepository.setPriceRule(PriceRuleController.ruleBase);
  }

  @override
  void initSubjects(List<Subject> subjects) {
    _loginEventSubject = BehaviorSubject();
    _signUpEventSubject = BehaviorSubject();
    subjects.add(_loginEventSubject);
  }

  void login(String username, String password) async{
    if(passwordValidator(password)) {
      Response loginResponse = await _apiRepository.login(username, password);
      if(loginResponse.statusCode == HttpStatus.ok) {
        _sharedPrefRepository.setUserToken(json.decode(loginResponse.body)['token']);
        ApiRepository.setToken = json.decode(loginResponse.body)['token'];
        Response pricingRulesResponse = await _apiRepository.getPricingRules();
        var decodedResponse = json.decode(pricingRulesResponse.body);
        List<PriceRuleModel> rules = List();
        if(decodedResponse["pricing_rules"] != null){
          decodedResponse["pricing_rules"].forEach((element) {
            rules.add(PriceRuleModel.fromJson(element));
          });
        }
        PriceRuleController.priceRules = rules;
        _sharedPrefRepository.setPriceRuleList(rules);
        if (!kReleaseMode)
        FirebaseAnalytics().logEvent(
            name: 'user_login',
            parameters: {'user_login' : username}
        );
        loginEvent();
      } else {
        String errorMessage = json.decode(loginResponse.body)['msg'];
        loginErrorEvent(errorMessage);
      }
    } else {

    }
  }

  Future<String> signUp(String username, String phoneNumber,
      String email, String password, String jurStatus) async {
      Response signUpResponse = await _apiRepository.signUp(username, phoneNumber, email, password, jurStatus);
      if(signUpResponse.statusCode == HttpStatus.ok) {
        if (!kReleaseMode)
        FirebaseAnalytics().logEvent(
            name: 'sign_up',
            parameters: {'local_sign_up_date' : DateTime.now().toString()}
        );
        //signUpEvent();
        return json.decode(signUpResponse.body)['msg'];
      } else {
        String errorMessage = json.decode(signUpResponse.body)['msg'];
        if (!kReleaseMode)
        FirebaseAnalytics().logEvent(
            name: 'sign_up_error',
            parameters: {'sign_up_error_msg' : errorMessage}
        );
        //signUpErrorEvent(errorMessage);
        return json.decode(signUpResponse.body)['msg'];
      }
  }

  bool passwordValidator(String password) {
    return password.length > 0 ? true : false;
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();


  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      if (await _apiRepository.getToken(googleSignInAuthentication.accessToken)
          .then((response) async {
        if (response.statusCode == HttpStatus.ok) {
          await _sharedPrefRepository
              .setGoogleToken(googleSignInAuthentication.accessToken);
          await _sharedPrefRepository.setGooglePhotoUrl(
              googleSignInAccount.photoUrl);
          SharedPrefRepository().photoUrl = googleSignInAccount.photoUrl;
          String token = await json.decode(response.body)['token'];
          await _sharedPrefRepository.setUserToken(token);
          ApiRepository.setToken = token;
          return true;
        }
        return false;
      }))
        return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
  }


  Future<bool> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        accessToken: appleIdCredential.authorizationCode,
        idToken: appleIdCredential.identityToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (await _apiRepository.getAppleToken(appleIdCredential.identityToken)
          .then((response) {
        if (response.statusCode == HttpStatus.ok) {
          _sharedPrefRepository.setAppleToken(
              appleIdCredential.identityToken);
          String token = json.decode(response.body)['token'];
          _sharedPrefRepository.setUserToken(token);
          ApiRepository.setToken = token;
          return true;
        }
        return false;
      }))
        return true;
      return false;
    }
    catch (e) {
      return false;
    }
  }
}
