import 'package:app/src/data/localization/AppLocalization.dart';
import 'package:app/src/data/repository/ApiRepository.dart';
import 'package:app/src/data/repository/SharedPreferences.dart';
import 'package:app/src/data/utils/CheckOrientation.dart';
import 'package:app/src/resources/Styles.dart';
import 'package:app/src/ui/AuthPage/AuthBloc.dart';
import 'package:app/src/ui/BasePage/BaseRxState.dart';
import 'package:app/src/ui/Widgets/Custom/CustomTextFormField.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:platform_info/platform_info.dart';
import 'package:toast/toast.dart';

import '../../../main.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends BaseRxState<SignUpPage, AuthBloc> {

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  var _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String dropDownValue = AppLocalizations.localizedStrings['legal_entity_choose'];
  bool isInvalid = false;
  GlobalKey<FormState> keyToResize = GlobalKey<FormState>();
  String passwordConfirmation;

  final String phoneForm = '+375(__)___-__-__';

  var border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(3.0),
    borderSide: BorderSide(color: Colors.grey),
  );

  var borderFocused = OutlineInputBorder(
    borderRadius: BorderRadius.circular(3.0),
    borderSide: BorderSide(color: Colors.black),
  );

  @override
  Widget build(BuildContext context) {
    bloc.signInEventStream.listen((data) {
      Navigator.pop(context);
    },
        onError: (error) {
          bloc.showMessage(error);
        });
    return Scaffold(
      body: SingleChildScrollView(
        child: _buildLoginForm(),
      ),
    );
  }

  Container _buildLoginForm() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal:
          Platform.I.isAndroid || Platform.I.isIOS || isPortrait(context) ?
          15 : MediaQuery.of(context).size.width / 100 * 30
      ),
      padding: EdgeInsets.only(top: 70),
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.localizedStrings['registration'],
            style: TextStyle(fontSize: 28),
          ),
          buildForm(),
          SizedBox(height: 35),
          Container(
            height: 50,
            width: double.maxFinite,
            child: MaterialButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                if (formKey.currentState.validate())
                  signUp();
              },
              color: AppStyle.appBarColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)
              ),
              child: Text(
                AppLocalizations.localizedStrings['register'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppStyle.appBarTextColor
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildBottomWidgetList(),
          ),
          SizedBox(height: 70),
        ],
      ),
    );
  }

  List<Widget> buildBottomWidgetList() =>
      [
        Text(
          "${AppLocalizations
              .localizedStrings["already_have_account"]} ",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black
          ),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.pushNamed(context, Burshtat.loginRoute);
          },
          padding: EdgeInsets.only(right: 50),
          child: Text(
            AppLocalizations.localizedStrings['login'],
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppStyle.appBarColor,
                decoration: TextDecoration.underline
            ),
          ),
        )
      ];

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            counter: false,
            label: AppLocalizations.localizedStrings['name'],
            maxLength: 20,
            controller: _usernameController,
            validator: (value) {
              if (value.isEmpty)
                return AppLocalizations.localizedStrings['field_is_required'];
            },
          ),

          CustomTextFormField(
            counter: false,
            label: AppLocalizations.localizedStrings['email_address'],
            controller: _emailController,
            validator: (value) {
              if (value == '')
                return AppLocalizations
                    .localizedStrings['field_is_required'];
              if (!EmailValidator.validate(value)) {
                return AppLocalizations
                    .localizedStrings['invalid_email'];
              }
            },
          ),

          Container(
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppLocalizations
                      .localizedStrings['phone_number']}: ',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  decoration: InputDecoration(
                    hintText: '+375(',
                    counter: SizedBox.shrink(),
                    border: border,
                    focusedBorder: borderFocused,
                    errorBorder: border,
                    focusedErrorBorder: borderFocused,
                  ),
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction,
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16.0),
                  onTap: () {
                    if (_phoneNumberController.text.length <= 5) {
                      _phoneNumberController.text = '+375(';
                      _phoneNumberController.selection =
                          TextSelection.fromPosition(
                              TextPosition(offset: 5));
                    }
                    if (_phoneNumberController.selection
                        .extentOffset !=
                        _phoneNumberController.text.length)
                      _phoneNumberController.selection =
                          TextSelection.fromPosition(
                              TextPosition(
                                  offset: _phoneNumberController
                                      .text.length
                              )
                          );
                  },
                  // ignore: missing_return
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations
                          .localizedStrings['field_is_required'];
                    }
                    if (value.length < phoneForm.length) {
                      return AppLocalizations
                          .localizedStrings['phone_number_error'];
                    }
                  },
                  onChanged: (val) => checkPhoneFormat(val),
                  cursorColor: AppStyle.secondaryColor,
                ),
              ],
            ),
          ),

          CustomTextFormField(
            counter: false,
            label: AppLocalizations.localizedStrings['password'],
            maxLength: 20,
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value.isEmpty)
                return AppLocalizations.localizedStrings['field_is_required'];
              if (value.length < 8) {
                return AppLocalizations.localizedStrings['password_short'];
              }
            },
          ),

          CustomTextFormField(
            counter: false,
            label: AppLocalizations.localizedStrings['password_confirm'],
            maxLength: 20,
            obscureText: true,
            controller: _confirmPasswordController,
            validator: (value) {
              if (value != _passwordController.text)
                return AppLocalizations
                    .localizedStrings['password_confirm_error'];
            },
          ),

          CustomDropdownField(
            label: AppLocalizations.localizedStrings['organization_type'],
            value: dropDownValue,
            padding: EdgeInsets.zero,
            onChanged: (String newValue) =>
                setState(() => dropDownValue = newValue),
            items: <String>[
              AppLocalizations.localizedStrings['legal_entity_choose'],
              AppLocalizations.localizedStrings['individual_entrepreneur']
            ]
                .map<DropdownMenuItem<String>>((String value) =>
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> signUp() async {
    String jurStatus;
    if (dropDownValue == AppLocalizations.localizedStrings["legal_entity_choose"])
      jurStatus = "J";
    else
      jurStatus = "I";

    if (await bloc.signUp(_usernameController.text, _phoneNumberController.text,
        _emailController.text, _passwordController.text, jurStatus) == "") {
      Navigator.pop(context);
      showRegistrationMessage(context);
    } else
      Toast.show(await bloc.signUp(
          _usernameController.text, _phoneNumberController.text,
          _emailController.text, _passwordController.text, jurStatus), context);
  }

  void checkPhoneFormat(String value) {
    int newOffset = _phoneNumberController.selection.extentOffset;

    if (value.length > phoneForm.length)
      if (value.length - 1 == phoneForm.length) {
        value = value.substring(0, newOffset - 1) + value.substring(newOffset);
        newOffset--;
      } else
        value = value.substring(0, phoneForm.length);

    for (int i = 0; i < value.length; i++)
      if (i < phoneForm.length && value[i] != phoneForm[i])
        if (phoneForm[i] == '_' && !isNumeric(value[i])) {
          value = value.substring(0, i) + value.substring(i + 1);
          newOffset--;
          i--;
        } else if (phoneForm[i] != '_') {
          value = value.substring(0, i) + phoneForm[i] + value.substring(i);
          newOffset++;
        }

    if (value.length <= 5) {
      value = '+375(';
      newOffset = 5;
    }

    setState(() {
      _phoneNumberController = TextEditingController(text: value);
      _phoneNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneNumberController.text.length));
    });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  void showRegistrationMessage(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              AppLocalizations.localizedStrings['registration_message'],
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontWeight: FontWeight.normal
              ),
            ),
            children: <Widget>[
              Center(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)
                  ),
                  child: Text(
                      AppLocalizations.localizedStrings['ok'],
                      style: TextStyle(color: Colors.white, fontSize: 13)
                  ),
                  color: AppStyle.appBarColor,
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget buildStateContent() {

    bloc.signInEventStream.listen((data) {
      Navigator.pop(context);
    },
        onError: (error) {
          bloc.showMessage(error);
        });

    return Container();
  }

  @override
  Drawer buildDrawer() {
    return null;
  }

  @override
  FloatingActionButton floatingActionButton() {
    return null;
  }

  @override
  Widget bottomBarWidget() {
    // TODO: implement bottomBarWidget
    return null;
  }

  @override
  PreferredSizeWidget buildTopToolbarTitleWidget() {
    return null;
  }

  @override
  void disposeExtra() {
    // TODO: implement disposeExtra
  }

  @override
  AuthBloc initBloC() {
    return AuthBloc(ApiRepository(), SharedPrefRepository());
  }

  @override
  void preInitState() {
    // TODO: implement preInitState
  }

}

