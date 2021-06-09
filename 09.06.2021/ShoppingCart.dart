import 'package:app/src/data/controllers/AppAuthController.dart';
import 'package:app/src/data/controllers/AppPaddingController.dart';
import 'package:app/src/data/controllers/AppVersionController.dart';
import 'package:app/src/data/controllers/PriceRuleController.dart';
import 'package:app/src/data/localization/AppLocalization.dart';
import 'package:app/src/data/model/CartModel.dart';
import 'package:app/src/data/model/CatalogModel.dart';
import 'package:app/src/data/repository/ApiRepository.dart';
import 'package:app/src/data/repository/SharedPreferences.dart';
import 'package:app/src/data/repository/Url.dart';
import 'package:app/src/data/utils/CheckOrientation.dart';
import 'package:app/src/data/utils/Logout.dart';
import 'package:app/src/resources/Styles.dart';
import 'package:app/src/ui/AuthPage/AuthPhonePage.dart';
import 'package:app/src/ui/BasePage/BaseRxState.dart';
import 'package:app/src/ui/MainPage/ShoppingCart/ShoppingCartBloc.dart';
import 'package:app/src/ui/ProfilePage/EmailPage.dart';
import 'package:app/src/ui/Widgets/AppDrawer.dart';
import 'package:app/src/ui/Widgets/Dialogs.dart';
import 'package:app/src/ui/Widgets/LoadingWidget.dart';
import 'package:app/src/ui/Widgets/ProductView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uic/widgets.dart';
import '../../../data/controllers/AppPaddingController.dart';
import '../MainPage.dart';
import '../OrderPages/OrderView.dart';
import 'ShoppingCartBloc.dart';

class ShoppingCart extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ShoppingCartState();
  }
}

class ShoppingCartState extends BaseRxState<ShoppingCart, ShoppingCartBloc> {
  CartError error;
  bool adding = false, firstVar, changed = false;
  double total = 0.0, totalValue = 0.0;

  @override
  Widget bottomBarWidget() {
    return null;
  }

  @override
  Widget buildStateContent() {
    return StreamBuilder(
        stream: bloc.cartStream,
        builder: (context, snapshot) {
          if (error != null && error != CartError.Awaiting) {
            return buildErrorContent(error);
          } else {
            return buildCart(snapshot.data);
          }
        }
    );
  }

  // ignore: missing_return
  Widget buildCart(CartModel cart) {
    if (cart == null || cart.isLoading == true) {
      return loading;
    } else {
      if (cart.products.isEmpty && cart.isLoading == false) {
        return buildErrorContent(CartError.EmptyCartError);
      }
      if (cart.products.isNotEmpty && cart.isLoading == false) {
        total = 0.0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (changed) {
            changed = false;
            setState(() {});
          }
        });
        return Scaffold(
          persistentFooterButtons: [
            Container(
              padding: AppPaddingController().padding(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: kIsWeb ?
                      MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            AppLocalizations.localizedStrings['total_amount'] +
                                ' ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16
                            )
                        ),
                        Text(
                            '${totalValue.toStringAsFixed(2)} BYN',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16
                            )
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    //margin: AppPaddingController().padding(context),
                    //alignment: Alignment.bottomCenter,
                    // width: MediaQuery
                    //     .of(context)
                    //     .size
                    //     .width,
                    height: 50,
                    child: ActionButton(
                      buttonType: ActionButtonType.elevated,
                      style: ElevatedButton.styleFrom(
                        primary: AppStyle.appBarColor,
                      ),
                      action: () async {
                        var profile = await bloc.getProfile();
                        if (profile != null) {
                          if (profile.phone == '' &&
                              AppVersionController.version ==
                                  AppVersion.MoiShop) {
                            firstVar = true;
                            // ignore: await_only_futures
                            await showPhoneEmailDialog(context);
                            if (adding) {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AuthPhonePage(true)));
                              adding = false;
                              if (result != null && result.length == 13) {
                                profileAppDrawer.phone = result;
                              } else
                                // ignore: await_only_futures
                                await showNotification(context);
                            } else
                              // ignore: await_only_futures
                              await showNotification(context);
                          }

                          var block =
                          await SharedPrefRepository()
                              .getBlockRequestAddEmail();
                          if (profile.email == '' &&
                              AppVersionController.version ==
                                  AppVersion.MoiShop &&
                              !block) {
                            firstVar = false;
                            // ignore: await_only_futures
                            await showPhoneEmailDialog(context);
                            if (adding) {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EmailPage('', true)));
                              adding = false;
                              if (result != null && result is String) {
                                profileAppDrawer.email = result;
                              } else
                                // ignore: await_only_futures
                                await showNotification(context);
                            } else
                              // ignore: await_only_futures
                              await showNotification(context);
                          }

                          var val = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OrderView(
                                          cart,
                                          profile,
                                          ApiRepository(),
                                              () async {
                                            await bloc.clean();
                                            bloc.isCartEditedBeforeCatalog =
                                            true;
                                            bloc.isCartEditedBeforeCatalog =
                                            true;
                                            bloc.isCartEditedBeforePromotions =
                                            true;
                                            mainPageStateObj
                                                .updateProductList();
                                          })));
                          if (val is int) {
                            mainPageStateObj.updateProductList();
                            if (val == 1)
                              mainPageStateObj.navigateToCatalog();
                            else if (val == 2)
                              mainPageStateObj.navigateToOrdersHistory();
                            else if (val == 3)
                              mainPageStateObj.navigateToReviews();
                            else if (val == 4) {
                              currentComponentIndex = 0;
                              Navigator.pushReplacementNamed(context, '/Home');
                            }
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: kIsWeb ? MainAxisSize.min : MainAxisSize
                            .max,
                        mainAxisAlignment: kIsWeb ?
                        MainAxisAlignment.end : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: (
                                '${AppLocalizations
                                    .localizedStrings['total_amount']}: '
                                    '${totalValue.toStringAsFixed(2)} BYN'
                            ).length.toDouble() * 1.7
                            ),
                            child: Text(
                                AppLocalizations.localizedStrings['checkout'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                )
                            ),
                          )
                        ],
                      ),
                      //color: AppStyle.appBarColor,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
          body: Stack(
            fit: StackFit.expand,
            children: [
              ListView.separated(
                  padding: AppPaddingController().padding(context),
                  separatorBuilder: (_, __) => Divider(),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) =>
                      buildProductTile(
                          cart.products[index], index, cart.products.length)
              ),
            ],
          ),
        );
      }
    }
  }

  Widget buildProductTile(ProductModel product, int index, int length) {
    total += (product.promotion ?
    getProductPrice(product.prices) : product.priceVat) * product.quantityInCart;
    if (index == length - 1 && totalValue != total) {
      totalValue = total;
      changed = true;
    }
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ProductView(
                      product,
                      mainPageStateObj.goPreviousCartComponent,
                          (product) {},
                      mainPageStateObj.goToCart
                  )
              )
          );
        },
        child: Container(
          height: (double.maxFinite ~/ (double.maxFinite / 150)) * 1.3,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(top: 10, right: 10),
                  color: AppStyle.catalogListImageBackColor,
                  child: CachedNetworkImage(
                    fit: BoxFit.fitHeight,
                    imageUrl: imageSource + product.image,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppStyle.appBarColor)),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.not_interested),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: isPortrait(context) ?
                  CrossAxisAlignment.start : CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isPortrait(context))
                      Expanded(
                        flex: 10,
                        child: Text(
                          product.name, maxLines: 3,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    if (!isPortrait(context))
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        constraints: BoxConstraints(
                          maxHeight: 80,
                          maxWidth: 200,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.minOrder == 1 ? '' :
                              '${AppLocalizations
                                  .localizedStrings['multiplicity']}: '
                                  + product.minOrder.toString(),
                              style: TextStyle(fontSize: 16,
                                  color: Colors.black26),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${AppLocalizations
                                        .localizedStrings['quantity']}: '
                                        + product.quantityInCart.toString()
                                        + ' ' + AppLocalizations
                                        .localizedStrings['pcs'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  color: Colors.black,
                                  icon: Icon(
                                      const IconData(
                                          0xe900,
                                          fontFamily: 'EditIcon'),
                                      size: 18
                                  ),
                                  onPressed: () async {
                                    var val = await showAddProductToCartDialog(
                                        context, product, false);
                                    if (val != 0)
                                      await newQuantityInCart(
                                          product, val);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (!isPortrait(context))
                      Expanded(
                        flex: 6,
                        child: UnconstrainedBox(
                          child: product.promotion ?
                          Column(
                            mainAxisAlignment: isPortrait(context) ?
                            MainAxisAlignment.start : MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.only(
                                        right: 8.0),
                                    child: Text(
                                      product.priceVat.toString() + ' BYN',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                          decoration: TextDecoration
                                              .lineThrough),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius
                                            .circular(30),
                                        color: Colors.red
                                    ),
                                    child: Text(
                                        " -${product.discount
                                            .toString()}% ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                              Text(
                                "${getProductPrice(product.prices)
                                    .toString()} BYN",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppStyle
                                        .withDiscountColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                              : Container(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              "${getProductPrice(
                                  product.prices)} BYN",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isPortrait(context))
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: buildCardData(product, index),
                        ),
                      ),
                    Container(
                      //alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                            const IconData(0xe900, fontFamily: 'delete'),
                            size: 18
                        ),
                        onPressed: () =>
                            showDeleteConfirmDialog(context, product),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  List<Widget> buildCardData(ProductModel product, int index) =>
      [
        Text(
          product.name, maxLines: 3,
          overflow: TextOverflow.visible,
          style: TextStyle(fontSize: 16),
        ),
        Text(
          product.minOrder == 1 ? "" :
          '${AppLocalizations
              .localizedStrings['multiplicity']}: '
              + product.minOrder.toString(),
          style: TextStyle(fontSize: 16,
              color: Colors.black26),
        ),

        Row(
          children: [
            Flexible(
              child: Text(
                '${AppLocalizations
                    .localizedStrings['quantity']}: '
                    + product.quantityInCart.toString()
                    + ' ' + AppLocalizations
                    .localizedStrings['pcs'],
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              color: Colors.black,
              icon: Icon(
                  const IconData(
                      0xe900,
                      fontFamily: 'EditIcon'),
                  size: 18
              ),
              onPressed: () async {
                var val = await showAddProductToCartDialog(
                    context, product, false);
                if (val != 0)
                  await newQuantityInCart(
                      product, val);
                setState(() {});
              },
            ),
          ],
        ),

        Container(
          child: product.promotion ?
          Column(
            mainAxisAlignment: MainAxisAlignment
                .start,
            crossAxisAlignment: CrossAxisAlignment
                .start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        right: 8.0),
                    child: Text(
                      product.priceVat.toString() +
                          ' BYN',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          decoration: TextDecoration
                              .lineThrough),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius
                            .circular(
                            30),
                        color: Colors.red
                    ),
                    child: Text(
                        " -${product.discount
                            .toString()}% ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12)),
                  ),
                ],
              ),
              Text(
                "${getProductPrice(product.prices)
                    .toString()} BYN",
                style: TextStyle(
                    fontSize: 14,
                    color: AppStyle
                        .withDiscountColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
              : Container(
            padding: EdgeInsets.only(right: 15),
            child: Text(
              "${getProductPrice(
                  product.prices)} BYN",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),
      ];

  void showPhoneEmailDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              AppLocalizations.localizedStrings[
              firstVar ? 'link_phone' : 'link_email'
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.normal
              ),
            ),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      adding = true;
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Text(
                        AppLocalizations.localizedStrings[
                        firstVar ? 'enter_phone_number' : 'add_email'
                        ],
                        style: TextStyle(color: Colors.white)
                    ),
                    color: AppStyle.appBarColor,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      adding = false;
                      SharedPrefRepository().setBlockRequestAddEmail();
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Text(
                        AppLocalizations.localizedStrings['later'],
                        style: TextStyle(color: Colors.white)
                    ),
                    color: Colors.grey,
                  )
                ],
              )
            ],
          );
        }
    );
  }

  void showNotification(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.localizedStrings[
                firstVar ? 'phone_notification' : 'email_notification'
                ],
                  // style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: 18
                  //     ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.localizedStrings['close'],
                // style: TextStyle(
                //     fontWeight: FontWeight.normal,
                //     fontSize: 18
                // ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmDialog(BuildContext context, ProductModel product) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              AppLocalizations.localizedStrings['delete_dialog'],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.normal
              ),
            ),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Text(
                        AppLocalizations.localizedStrings['cancel'],
                        style: TextStyle(color: Colors.white, fontSize: 13)
                    ),
                    color: AppStyle.appBarColor,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      bloc.changeProduct(product, 0);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Text(
                        AppLocalizations.localizedStrings['delete'],
                        style: TextStyle(color: Colors.white, fontSize: 13)
                    ),
                    color: Colors.grey,
                  )
                ],
              )
            ],
          );
        }
    );
  }

  Future<bool> newQuantityInCart(ProductModel product, int val) async {
    if (await bloc.editQuantity(product, val)) {
      bloc.isCartEditedBeforeCatalog =
      true;
      bloc.isCartEditedBeforeSearch =
      true; //?
      bloc.isCartEditedBeforePromotions =
      true; //?

      return true;
    }
    return false;
  }

  // ignore: missing_return
  Widget buildErrorContent(CartError e) {
    // error = null;
    switch (e) {
      case CartError.EmptyTokenError:
        if(AppAuthController.isAuth){
          logout();
          Navigator.pushReplacementNamed(context, '/Login');
        }
        return Center(
            child: Container(
                color: AppStyle.primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: Text(
                        AppLocalizations
                            .localizedStrings['cart_need_login_warning'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black, fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/Login');
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Container(
                          height: 42,
                          width: 68,
                          child: Center(
                            child: Text(AppLocalizations.localizedStrings['login'],
                                style: TextStyle(color: Colors.white)),
                          )
                      ),
                      color: AppStyle.appBarColor,
                    )
                  ],
                )
            )
        );
      case CartError.EmptyCartError:
        return Container(
            color: AppStyle.primaryColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(
                        "assets/shopping_cart.png"),
                    height: 84.0,
                    width: 84.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      AppLocalizations.localizedStrings['empty_cart'],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
        );
      case CartError.LoadingError:
      case CartError.InternetConnectionError:
        if (ApiRepository().token != null)
          return Container(
              color: AppStyle.primaryColor,
              child: Center(
                child: Text(
                  AppLocalizations.localizedStrings['load_error'],
                  style: TextStyle(color: Colors.black),
                ),
              )
          );
    }
  }

  double getTotalPrice(CartModel cart) {
    double price = 0;
    // for (var product in cart.products) {
    //   price += product.quantityInCart * getProductPrice(product.prices);
    // }
    return price;
  }

  double getProductPrice(List<PricesModel> prices) {
    if (prices.length == 1) {
      return prices.first.priceVat.toDouble();
    }
    return prices
        .singleWhere((element) =>
    element.ruleId == PriceRuleController.currentPriceRule)
        .priceVat.toDouble();
  }

  // String getProductPriceVat(List<PricesModel> prices) {
  //   if (prices.length == 1) {
  //     return "${prices.first.priceVat} BYN";
  //   }
  //   return "${prices
  //       .singleWhere((element) =>
  //   element.ruleId == PriceRuleController.currentPriceRule)
  //       .priceVat
  //       .toString()} BYN";
  // }

  @override
  // ignore: missing_return
  PreferredSizeWidget buildTopToolbarTitleWidget() {}

  @override
  void disposeExtra() {}

  @override
  void preInitState() {
    bloc.errorStream.listen((e) {
      error = e;
    });
    bloc.addCartToSink();
  }

  @override
  ShoppingCartBloc initBloC() {
    return mainPageStateObj.cartBloc;
  }

  @override
  Drawer buildDrawer() {
    return null;
  }

  @override
  FloatingActionButton floatingActionButton() {
    return null;
  }
}
