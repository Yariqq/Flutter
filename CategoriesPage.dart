import 'dart:math';
import 'package:admin_client/data/controllers/AppPaddingController.dart';
import 'package:admin_client/data/localization/AppLocalization.dart';
import 'package:admin_client/data/models/CategoryModel.dart';
import 'package:admin_client/data/repository/ApiRepository.dart';
import 'package:admin_client/resources/Styles.dart';
import 'package:admin_client/ui/Categories/CategoriesBloC.dart';
import 'package:admin_client/ui/Widgets/CustomDialog.dart';
import 'package:admin_client/ui/Widgets/LoadingWidget.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'CurrentCategoryPage.dart';

class CategoriesPage extends StatefulWidget {

  final CategoriesBloC bloC;

  CategoriesPage(this.bloC);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();

}

class _CategoriesPageState extends State<CategoriesPage> {

  @override
  void initState() {
    widget.bloC.getAllCategories();
    super.initState();
  }

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
                  setState(() => widget.bloC.getAllCategories());
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
                setState(() => widget.bloC.getAllCategories());
                if (flag) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          AppLocalization
                              .localizedStrings["category_delete_message"],
                          AppLocalization.localizedStrings["ok"],
                          null,
                          const IconData(0xe900, fontFamily: 'UserDeleted'),
                          false,
                              () => Navigator.pop(context),
                              () => null,
                        );
                      }
                  );
                }
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
}
