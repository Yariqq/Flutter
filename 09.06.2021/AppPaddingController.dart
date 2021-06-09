import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppPaddingController{
  static double get horizontal => 15.0;
  static double get vertical => 0.0;

  EdgeInsets padding(BuildContext context){
    var width = MediaQuery.of(context).size.width;

    return
      kIsWeb ?
    EdgeInsets.symmetric(
        horizontal: width * horizontal / 100,
        vertical: vertical
    ) :
    EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  double horizontalSide(BuildContext context){
    var width = MediaQuery.of(context).size.width;
    return kIsWeb ? width * horizontal / 100 : horizontal;
  }
}