import 'package:flutter/material.dart';

class CustomTextInputWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String? hint;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final String? initValue;
  final bool showPrefixIcon;
  final TextStyle? hintStyle;
  final Function(String value)? onChange;
  const CustomTextInputWidget({
    super.key,
    this.width,
    this.height,
    this.hint,
    this.color,
    this.onChange,
    this.borderRadius,
    this.initValue,
    this.showPrefixIcon = true,
    this.hintStyle,
    this.textColor,
  });

  @override
  State<CustomTextInputWidget> createState() => CustomTextInputWidgetState();
}

class CustomTextInputWidgetState extends State<CustomTextInputWidget> {
  final textInputCtrl = TextEditingController();
  @override
  void initState() {
    if (widget.initValue != null) {
      textInputCtrl.text = widget.initValue!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.transparent),
        borderRadius: widget.borderRadius != null ? BorderRadius.circular(widget.borderRadius!) : null,
      ),
      width: widget.width ?? 150,
      height: widget.height ?? 32,
      child: TextFormField(
        onChanged: (value) {
          widget.onChange?.call(value);
        },
        style: TextStyle(color: widget.textColor ?? Colors.black),
        controller: textInputCtrl,
        decoration: InputDecoration(
          hintStyle: widget.hintStyle,
          filled: widget.color != null,
          fillColor: widget.color,
          prefixIconConstraints: BoxConstraints(
            maxWidth: widget.height ?? 32,
            minWidth: widget.height ?? 32,
            maxHeight: widget.height ?? 32,
            minHeight: widget.height ?? 32,
          ),
          prefixIcon: widget.showPrefixIcon
              ? Icon(
                  Icons.search,
                  size: 16,
                  color: Colors.black38,
                )
              : null,
          hintText: widget.hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5.0),
          border: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(width: 1, color: Colors.black45),
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(width: 1, color: Colors.black45),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(width: 1, color: Colors.black45),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(width: 1, color: Colors.black45),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(width: 1, color: Colors.red),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
