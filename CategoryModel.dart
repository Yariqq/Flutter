
import 'package:admin_client/data/utils/ResponseLogger.dart';

class CategoryModel {

  int idCategory;
  String humanReadableId;
  String categoryName;
  List<CategoryModel> children;
  String seoTitle;
  String seoDescription;
  String footerDescription;
  String updatedDate;
  String updatedBy;
  int parentId;
  List<FilterModel> assignedFilters;
  List<FilterModel> unassignedFilters;
  bool isHidden;

  CategoryModel();

  CategoryModel.fromJson(Map<String, dynamic> parsedJson,
      {List<FilterModel> parsedAssignedFilters,
      List<FilterModel> parsedUnassignedFilters}) {

    idCategory = parsedJson["id"];
    humanReadableId = parsedJson["human_readable_id"];
    categoryName = parsedJson["name"];

    if (parsedJson["childs"] != null) {
      children = [];
      for (int i = 0; i < parsedJson["childs"].length; i++) {
        children.add(CategoryModel.fromJson(parsedJson['childs'][i]));
      }
    }

    seoTitle = parsedJson["seo_title"];
    seoDescription = parsedJson["seo_description"];
    footerDescription = parsedJson["footer_description"];

    if (parsedJson["updated"] != null && parsedJson["updated"] != "") {
      var parsedUpdateDate = parsedJson["updated"].toString().split(" ")[0]
          .split(
          "-");
      updatedDate =
      "${parsedUpdateDate[2]}.${parsedUpdateDate[1]}.${parsedUpdateDate[0]}";
    } else {
      updatedDate = parsedJson["updated"];
    }

    if (parsedJson["updated_by"] != null)
      updatedBy = parsedJson["updated_by"].toString();

    parentId = parsedJson["parent_id"];

    if (parsedAssignedFilters != null)
      assignedFilters = parsedAssignedFilters;

    if (parsedUnassignedFilters != null)
      unassignedFilters = parsedUnassignedFilters;

    isHidden = parsedJson["is_hidden"];
  }
}

class FilterModel {

  String _idFilter;
  String _filterName;
  List<String> _values;

  String get idFilter => _idFilter;
  String get filterName => _filterName;
  List<String> get values => _values;

  FilterModel.fromJson(Map<String, dynamic> parsedJson) {
    _idFilter = parsedJson["id"];
    _filterName = parsedJson["name"];

    if(parsedJson["values"] != null)
      _values = parsedJson["values"];
  }
}


class ProductModel {
  String _barcode;
  String _art;
  String _name;
  String _text;
  String _importer;
  String _izgotov;
  String _nominal;
  String _nominalName;
  bool _promotion;
  String _promoStartDate;
  String _promoEndDate;
  int _discount;
  dynamic _basePrice;
  int _vat;
  dynamic priceVat;
  // List<PricesModel> _prices;
  int _packageQuality;
  int _quantity;
  int _quantityInCart;
  String _image;
  String _group;
  String _brand;
  int _minOrder;
  bool _multiply;
  bool _singlePrice;
  bool wish;
  int count;

  String get barcode => _barcode;

  String get art => _art;

  String get name => _name;
      // removeAllHtmlTags(
      //     _name.replaceAll('&nbsp;', ' ').replaceAll('&quot;', ''));

  // String get name => _name;
  String get text => _text;

  String get importer => _importer;

  String get izgotov => _izgotov;

  String get nominal => _nominal;

  String get nominalName => _nominalName;

  bool get promotion => _promotion;

  String get promoStartDate => _promoStartDate;

  String get promoEndDate => _promoEndDate;

  int get discount => _discount;

  dynamic get basePrice => _basePrice;

  int get vat => _vat;

  // dynamic get priceVat => _priceVat;
  // List<PricesModel> get prices => _prices;

  int get packageQuality => _packageQuality;

  int get quantity => _quantity;

  // ignore: unnecessary_getters_setters
  int get quantityInCart => _quantityInCart;

  String get image => _image;

  String get group => _group;

  String get brand => _brand;

  int get minOrder => _minOrder;

  bool get multiply => _multiply;

  bool get singlePrice => _singlePrice;

  // ignore: unnecessary_getters_setters
  set quantityInCart(int quantity) => _quantityInCart = quantity;

  ProductModel.fromJson(Map<String, dynamic> parsedJson)
  {
    _barcode = parsedJson['barcode'];
    _art = parsedJson['art'];
    _name = parsedJson['name'];
    _text = parsedJson['text'];
    _importer = parsedJson['importer'];
    _izgotov = parsedJson['izgotov'];
    _nominal = parsedJson['nominal'];
    _nominalName = parsedJson['nominal_name'];
    _promotion =
    parsedJson['promotion'] != null ? parsedJson['promotion'] : true;
    _promoStartDate = parsedJson['promo_start_date'];
    _promoEndDate = parsedJson['promo_end_date'];
    _discount = parsedJson['discount'];
    _basePrice = parsedJson['base_price'].toDouble();
    _vat = parsedJson['vat'];
    priceVat = parsedJson['price_vat'] != null ?
    parsedJson['price_vat'].toDouble() : (_basePrice * 1.2).toDouble();
    // _prices = List();
    // if (parsedJson['prices'] != null) {
    //   parsedJson['prices'].forEach((data) {
    //     _prices.add(PricesModel.fromJson(data));
    //   });
    // }
    _packageQuality = parsedJson['package_quantity'];
    _quantity = parsedJson['quantity_front'];
    // AppVC.version == AppVersion.Burshtat
    //     ? parsedJson['quantity'] :
    // AppVC.version == AppVersion.MoiShop || AppVC.version == AppVersion.Nails?
    // parsedJson['quantity_front'] : parsedJson['quantity'];
    _quantityInCart = parsedJson['quantity_in_cart'] == null ?
    0 : parsedJson['quantity_in_cart'];
    _image = parsedJson['image'];
    _group = parsedJson['group'];
    _brand = parsedJson['brand'];
    _minOrder = parsedJson['min_order'];
    _multiply = parsedJson['multiple'];
    _singlePrice = parsedJson['single_price'];
    wish = parsedJson['in_wishlist'];
  }
}

