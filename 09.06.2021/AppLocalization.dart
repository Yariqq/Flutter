
import 'dart:convert';
import 'dart:ui';
import 'package:admin_client/data/repository/SharedPrefRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;
  SharedPrefRepository _sharedPrefRepository;
  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  static Map<String, String> localizedStrings;

  static const LocalizationsDelegate<AppLocalization> delegate =
  _AppLocalizationDelegate();

  Future<bool> load() async {

    String jsonString =
    await rootBundle.loadString('lib/data/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    _sharedPrefRepository = SharedPrefRepository();
    _sharedPrefRepository.setLocalizedStrings(localizedStrings);

    return true;
  }

  String translate(String key) {
    return localizedStrings[key];
  }
}

class _AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localizations = new AppLocalization(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;

}