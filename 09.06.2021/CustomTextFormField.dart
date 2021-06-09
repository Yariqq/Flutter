

import 'package:admin_client/resources/Styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatefulWidget {

  final bool counter;
  final double height;
  final double width;
  final String label;
  final EdgeInsets padding;

  final int maxLength;
  final int maxLines;
  final int minLines;
  final double borderRadius;
  bool required;
  final bool switchingLabel;
  final Color errorColor;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType textInputType;
  final bool obscureText;
  final AutovalidateMode autoValidateMode;
  final Widget suffixIcon;
  final Function(String) validator;
  final Function() onTap;
  Function(String) onFieldSubmitted;
  final Function(dynamic) onChanged;
  final Function(bool) onFocusChange;
  final bool enableSpace;
  final String hintText;

  CustomTextFormField({
    this.counter = true, this.width, this.height, this.label, this.padding,

    this.maxLength, this.maxLines, this.borderRadius, this.required = false,
    this.switchingLabel = false, this.errorColor, this.controller,
    this.focusNode, this.textInputType, this.obscureText, this.autoValidateMode,
    this.suffixIcon, this.validator, this.onFieldSubmitted, this.onTap,
    this.onChanged, this.onFocusChange, this.enableSpace = true, this.minLines,
    this.hintText
  });

  @override
  State<StatefulWidget> createState() {
    return CustomTextFormFieldState();
  }
}

class CustomTextFormFieldState extends State<CustomTextFormField> {

  @override
  void initState() {
    widget.onFieldSubmitted = widget.onFieldSubmitted ?? (_){ };
    super.initState();
  }

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
                inputFormatters:
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

  Widget buildFieldCounter(int length, int max, bool required) {
    Color color = Colors.grey;
    if (length == 0 && required)
      color = Colors.red;
    else if (length > 0)
      color = Colors.grey;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$length/$max', style: TextStyle(color: color, fontSize: 16))
      ],
    );
  }
}