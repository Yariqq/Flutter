import 'dart:ui';
import 'package:admin_client/resources/Styles.dart';
import 'package:admin_client/ui/AuthPage/LoginPage.dart';
import 'package:admin_client/ui/MainPage/MainPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:after_init/after_init.dart';
import 'data/localization/AppLocalization.dart';
import 'data/repository/ApiRepository.dart';
import 'data/repository/SharedPrefRepository.dart';

void main() => runApp(AdminClient());

class AdminClient extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final shortcuts = WidgetsApp.defaultShortcuts;
    shortcuts[LogicalKeySet(LogicalKeyboardKey.space)] = ActivateIntent();
    return MaterialApp(

      shortcuts: shortcuts,
      debugShowCheckedModeBanner: false,

      supportedLocales: [
        Locale("en", "US"),
        Locale("ru", "RU"),
      ],

      localizationsDelegates: [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
      ],

      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales)
          if (supportedLocale.languageCode == locale.languageCode)
            return supportedLocale;
        return supportedLocales.first;
      },

      theme: ThemeData(
        accentColor: AppStyle.primaryColor,
        primarySwatch: Colors.blue,
        fontFamily: "Montserrat",
        pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
            }),
      ),
      routes: <String, WidgetBuilder>{
        homeRoute: (BuildContext context) => new MainPage(),
        loginRoute: (BuildContext context) => new LoginPage(),
      },
      home: StartPage(),
    );
  }

  static const String homeRoute = '/Home';
  static const String loginRoute = '/Login';
}

class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with AfterInitMixin<StartPage> {

  @override
  void didInitState() async {
    WidgetsFlutterBinding.ensureInitialized();
    bool alreadyLogin = false;

    String token = await SharedPrefRepository().getUserToken();

    if (token != null) {
      // AppDrawerController.isAuth = true;
      alreadyLogin = true;
      ApiRepository.setToken = token;
    }

    while (window.locale == null) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    final locale = window.locale;
    Intl.systemLocale = locale.toString();

    alreadyLogin
        ? Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainPage()))
        : Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.primaryColor,
      child: Center(
        child: Text(
          'LOADING...',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
              fontFamily: 'AvenirNextCyr'
          ),)
        // Image(
        //     image: AssetImage('assets/app_icon.png'),height: 120, width: 120
        // ),
      ),
    );
  }

}
