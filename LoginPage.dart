import 'package:admin_client/data/controllers/AppPaddingController.dart';
import 'package:admin_client/data/localization/AppLocalization.dart';
import 'package:admin_client/resources/Styles.dart';
import 'package:admin_client/ui/AuthPage/LoginBloC.dart';
import 'package:admin_client/ui/BasePage/BaseRxState.dart';
import 'package:admin_client/ui/Widgets/CustomButton.dart';
import 'package:admin_client/ui/Widgets/CustomTextFormField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends BaseRxState<LoginPage, LoginBloC> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // DeviceSize device = DeviceSize();
  bool visiblePassword = false, enabledButton = false, wrongData = false;

  @override
  Widget buildStateContent() =>
      Center(
        child: Padding(
        padding: AppPaddingController().padding(context),
        // padding: kIsWeb ?
        // device.webPadding(context, 30, 7) :
        // device.mobilePadding(context, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalization.localizedStrings["entrance"],
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 46),
              child: CustomTextFormField(
                counter: false,
                label: AppLocalization.localizedStrings["email_or_phone"],
                maxLength: 30,
                controller: _emailController,
                onChanged: (value) {
                  setState(() => enabledButton =
                      _passwordController.text.trim() != "" && value != "");

                },
                validator: (value) {
                  if (value.isEmpty)
                    return AppLocalization.localizedStrings['field_is_required'];
                },
              ),
            ),
            CustomTextFormField(
              counter: false,
              label: AppLocalization.localizedStrings["password"],
              maxLength: 30,
              obscureText: !visiblePassword,
              controller: _passwordController,
              suffixIcon: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: Icon(
                  !visiblePassword ?
                  const IconData(0xe900, fontFamily: 'Eye') :
                  const IconData(0xe900, fontFamily: 'CrossedEye'),
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() => visiblePassword = !visiblePassword);
                },
              ),
              onChanged: (value) {
                setState(() => enabledButton =
                    _emailController.text.trim() != "" && value != "");
              },
              validator: (value) {
                if (value.isEmpty)
                  return AppLocalization
                      .localizedStrings['field_is_required'];
              },
            ),
            Padding(
              padding: AppPaddingController().padding(context),
              // padding: kIsWeb ?
              // device.webPadding(context, 5, 2) :
              // EdgeInsets.only(top: 50),
              child: CustomButton(
                color: enabledButton
                    ? AppStyle.enabledButtonColor
                    : AppStyle.disabledButtonColor,
                text: AppLocalization.localizedStrings["enter"],
                textColor: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                onPressed: () {
                  if (enabledButton) {
                    FocusScope.of(context).unfocus();
                    _login();
                  }
                },
              ),
            ),
            wrongData ?
            Padding(
              padding: AppPaddingController().padding(context),
              // padding: EdgeInsets.only(top: device.height(context, 13)),
              child: Text(
                AppLocalization.localizedStrings["wrong_data_login"],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: AppStyle.errorTextFieldBorderColor
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
      );

  void _login() =>
    bloc.login(_emailController.text, _passwordController.text);


  @override
  void preInitState() => bloc.loginEventStream.listen(
      (_) => Navigator.pushReplacementNamed(context, '/Home'),
      onError: (_) => setState(() => wrongData = true));

  @override
  LoginBloC initBloC() => LoginBloC();

  @override
  Widget bottomBarWidget() {
    return null;
  }

  @override
  Drawer buildDrawer() {
    return null;
  }

  @override
  PreferredSizeWidget buildTopToolbarTitleWidget(GlobalKey<ScaffoldState> key) {
    return null;
  }

  @override
  void disposeExtra() {}

  @override
  FloatingActionButton floatingActionButton() {
    return null;
  }

}