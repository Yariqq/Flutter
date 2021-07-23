
/////////////////////////////////////////////////////////////////////////////
//////////////////////LOGIN COMPONENT/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      backgroundColor: AppStyle.primaryColor,
      body: Padding(
        padding: AppPaddingController().padding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalization.localizedStrings["entrance"],
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            CustomTextFormField(
              padding: EdgeInsets.only(top: 46),
              counter: false,
              label: AppLocalization.localizedStrings["email_or_phone"],
              maxLength: 70,
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
            CustomTextFormField(
              counter: false,
              label: AppLocalization.localizedStrings["password"],
              maxLength: 70,
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
                  onPressed: () =>
                      setState(() => visiblePassword = !visiblePassword)
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
            SizedBox(height: 30),
            CustomButton(
              padding: AppPaddingController().padding(context),
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
                  login();
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}


/////////////////////////////////////////////////////////////////////////////
//////////////////////CATALOG COMPONENT/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
@override
Widget build(BuildContext context) =>
    StreamBuilder(
      stream: widget.bloC.categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return entryItem(
                  snapshot.data[index], 16, false, snapshot.data);
            },
          );
        }
        return loading;
      },
    );

Widget entryItem(dynamic element, double fontSize,
    bool lastDivider, List<CategoryModel> allCategories, {dynamic id, int index}){
  if (element.idCategory == id && index != null)
    element = element.children[index];


  if (element is CategoryModel)
    return Column(
      children: [
        element.children != null ?
        ExpansionTileCard(
          shadowColor: Colors.transparent,
          baseColor: AppStyle.primaryColor,
          expandedColor: AppStyle.primaryColor,
          trailing: Transform.rotate(
            angle: pi / 2,
            child: Icon(
              Icons.arrow_forward_ios_sharp,
              color: Colors.black,
              size: 22,
            ),
          ),
          animateTrailing: true,
          colorCurve: Curves.bounceInOut,
          title: MaterialButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CurrentCategoryPage(widget.bloC,
                          element.idCategory, allCategories))).then((
                  value) {
                setState(() {
                  widget.bloC.getAllCategories();
                });
              });
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.centerLeft,
              child: HtmlWidget(element.categoryName),

            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingController.horizontal
              ),
              // padding: device.mobilePadding(context, 0),
              decoration: BoxDecoration(color: AppStyle.primaryColor),
              child: Column(
                children: List.generate(
                    element.children.length, (index) {
                  return entryItem(
                      element.children[index], 14,
                      element.children.length == index + 1, allCategories,
                      id: element.idCategory, index: index);
                }),
              ),
            ),
          ],
        ) :
        ListTile(
          tileColor: AppStyle.primaryColor,
          title: HtmlWidget(element.categoryName),

          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) =>
                    CurrentCategoryPage(widget.bloC,
                        element.idCategory, allCategories))).then((flag) {
              setState(() {
                widget.bloC.getAllCategories();
              });
            });
          },
        ),
        !lastDivider ? Divider(
          indent: 16,
          endIndent: 16,
          thickness: 1,
        ) : Container(),
      ],
    );
  else
    return Container();
}


/////////////////////////////////////////////////////////////////////////////
//////////////////////MAIN PAGE COMPONENT/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
@override
Widget buildStateContent() {
  Widget page;
  switch (currentIndex) {
    case categoriesIndex:
      bloc.setAppBarTitle = AppLocalization.localizedStrings['categories'];
      page = CategoriesPage(categoriesBloC);
      break;

    case usersIndex:
      bloc.setAppBarTitle = AppLocalization.localizedStrings['users'];
      // page = AllUsersPage();
      page = CustomCardListPage(
        usersBloC.usersStream, usersBloC.percentStream,
            (model) => Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            UserPage(usersBloC, model))).then((_) => setState(() {
          usersBloC.getAllUsers();
        })),
        statusRow: (model) =>
            StatusRow(model, turnOn: (model) async =>
            await screenLock(context, () async =>
            await usersBloC.updateUser(model))),
        onDelete: (id) =>
            usersBloC.deleteButtonFunc(context, id, () => setState(() {
              usersBloC.getAllUsers();
            })),
      );
      break;

    case rolesIndex:
      bloc.setAppBarTitle =
      AppLocalization.localizedStrings['roles_and_permissions'];
      page = RolesAndPermPage(rolesAndPermBloC);
      break;

    case pickupIndex:
      bloc.setAppBarTitle =
      AppLocalization.localizedStrings['pickup_points'];
      page = CustomCardListPage(
        pickupBloC.pickupStream,  pickupBloC.percentStream,
            (model) => Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            PickupPointPage(pickupBloC, model))).then((_) =>
            setState(() {})),

        onDelete: (id) =>
            pickupBloC.deleteButtonFunc(context, id, () => setState(() {
              pickupBloC.getAllPickupPoints();
            })),
      );
      break;

    case redirectsIndex:
      bloc.setAppBarTitle = AppLocalization.localizedStrings['redirects'];
      page = CustomCardListPage(
          redirectsBloC.redirectsStream, redirectsBloC.percentStream,
              (model) => Navigator.push(
              context, MaterialPageRoute(builder: (context) =>
              RedirectPage(redirectsBloC, model)))
              .then((_) => setState(() {})),

          statusRow: (model) => StatusRow(model, turnOn: (model) async =>
          await screenLock(context, () async =>
          await redirectsBloC.updateRedirect(model))),
          onDelete: (id) => redirectsBloC
              .deleteButtonFunc(context, id, () => setState(() {
            redirectsBloC.getAllRedirects();
          }))
      );
      break;

    case attributesIndex:
      bloc.setAppBarTitle =
      AppLocalization.localizedStrings['attributes'];
      page = CustomCardListPage(
          attributesBloC.attributesStream, attributesBloC.percentStream,
              (model) async => await showDialog(context: context,
              builder: (BuildContext context) =>
                  AttributeComponent(attributesBloC, model))
              .then((_) => setState(() {})),

          onSwitched: (model) async => await screenLock(context, () async =>
          await attributesBloC.updateAttribute(
              AttributeModel.clone(model)..isHidden = !model.isHidden))
              .then((_) => setState(() {})),
          onDelete: (id) => attributesBloC
              .deleteButtonFunc(context, id, () => setState(() {
            attributesBloC.getAllAttributes();
          }))
      );
      break;

    case feedsIndex:
      bloc.setAppBarTitle =
      AppLocalization.localizedStrings['feeds'];
      page = CustomCardListPage(
          feedsBloC.feedsStream, feedsBloC.percentStream,
              (model) async => await showDialog(context: context,
              builder: (BuildContext context) =>
                  FeedComponent(feedsBloC, model))
              .then((_) => setState(() {})),

          onDelete: (id) => feedsBloC
              .deleteButtonFunc(context, id, () => setState(() {
            feedsBloC.getAllFeeds();
          }))
      );
      break;

    case clientsIndex:
      bloc.setAppBarTitle = AppLocalization.localizedStrings['clients'];
      // page = AllUsersPage();
      page = CustomCardListPage(
        clientBloC.clientsStream, clientBloC.percentStream,
            (model) => Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            ClientPage(clientBloC, model))).then((_) => setState(() {})),

        statusRow: (model) => StatusRow(model, flag: !model.banned,
            turnOn: (flag) async => await screenLock(context, () async =>
            await clientBloC.updateStatus(model..banned = !flag))
                .then((obj) => setState(() => model = obj ?? model))),
        onDelete: (id) =>
            clientBloC.deleteButtonFunc(context, id, () => setState(() {})),
      );
      break;

    case groupsIndex:
      bloc.setAppBarTitle = AppLocalization.localizedStrings['groups'];
      page = CustomCardListPage(
        groupsBloC.groupsStream, groupsBloC.percentStream,
            (model) => setState(() {
          selectedGroups.clear();
          model.selected = !model.selected;
        }),
        cardRightIcon: Icon(
          const IconData(0xe900, fontFamily: 'Groups'),
          size: 16, color: Colors.black,
        ),
        onDelete: (id) => Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            GroupUsersPage(groupsBloC, id))).then((_) => setState(() {
          groupsBloC.clearGroupUsersStream();
          groupsBloC.getAllGroups();
        })),
      );
      break;

    default:
      bloc.setAppBarTitle = 'In development';
      page = PricesPage();
      break;
  }
  return Padding(
    padding: AppPaddingController().padding(context),
    child: page,
  );
}


/////////////////////////////////////////////////////////////////////////////
//////////////////////CUSTOM TEXTFORMFIELD COMPONENT/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
@override
Widget build(BuildContext context) {
  if (widget.switchingLabel) {
    setState(() => widget.required = widget.controller.text.length == 0);
  }
  return Container(
    height: widget.height,
    width: widget.width,
    padding: widget.padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label + (widget.required ? '*' : '') ?? '',
          style: TextStyle(color: widget.required ?
          Colors.red : AppStyle.textFieldLabelColor, fontSize: 14),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          child: Focus(
            child: TextFormField(
              onChanged: (v) {
                if (widget.switchingLabel)
                  setState(() =>
                  widget.required = v.length == 0 ? true : false);
                setState(() {
                  if (widget.onChanged != null)
                    widget.onChanged(v);
                });
              },
              maxLength: widget.maxLength,
              maxLines: widget.maxLines ?? 1,
              minLines: widget.minLines ?? 1,
              keyboardType: widget.textInputType ??
                  TextInputType.visiblePassword,
              obscureText: widget.obscureText ?? false,
              inputFormatters: widget.inputFormatters ??
                  [
                    if (!widget.enableSpace)
                      FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
                  ],
              decoration: InputDecoration(
                  hintText: widget.hintText ?? '',
                  suffixIcon: widget.counter ?
                  buildFieldCounter(widget.controller.text.length,
                      widget.maxLength, widget.required) : widget
                      .suffixIcon ?? null,
                  counter: SizedBox.shrink(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 30),
                    borderSide: BorderSide(
                        color: AppStyle.textFieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 30),
                    borderSide: BorderSide(
                        color: AppStyle.focusedTextFieldBorderColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 30),
                    borderSide: BorderSide(
                        color: AppStyle.errorTextFieldBorderColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 30),
                    borderSide: BorderSide(
                        color: AppStyle.errorTextFieldBorderColor),
                  ),
                  errorStyle: TextStyle(
                      color: widget.errorColor ?? Colors.red)
              ),
              autovalidateMode: widget.autoValidateMode ??
                  AutovalidateMode.onUserInteraction,
              controller: widget.controller,
              style: TextStyle(fontSize: 14.0),
              onFieldSubmitted: widget.onFieldSubmitted,
              cursorColor: Colors.black,
              // ignore: missing_return
              validator: widget.validator ?? (widget.required ? (value) {
                if (value.isEmpty)
                  return 'field_is_required';
              } : null),
              onTap: widget.onTap,
            ),
            onFocusChange: widget.onFocusChange,
          ),
        )
      ],
    ),
  );
}