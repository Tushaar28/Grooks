import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FlutterFlowDropDown extends StatefulWidget {
  const FlutterFlowDropDown({
    this.initialOption,
    required this.options,
    required this.onChanged,
    this.icon,
    this.width,
    this.height,
    this.fillColor,
    this.textStyle,
    this.elevation,
    this.borderWidth,
    this.borderRadius,
    this.borderColor,
    this.margin,
    this.hint = '',
    this.hideUnderline = true,
  });

  final String? initialOption;
  final String? hint;
  final List<String> options;
  final Function(String?) onChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final Color? fillColor;
  final TextStyle? textStyle;
  final double? elevation;
  final double? borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final bool? hideUnderline;

  @override
  State<FlutterFlowDropDown> createState() => _FlutterFlowDropDownState();
}

class _FlutterFlowDropDownState extends State<FlutterFlowDropDown> {
  late String dropDownValue;
  List<String> get effectiveOptions =>
      widget.options.isEmpty ? ['[Option]'] : widget.options;

  @override
  void initState() {
    super.initState();
    dropDownValue = widget.initialOption!;
    widget.onChanged(dropDownValue);
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 28),
        border: Border.all(
          color: widget.borderColor!,
          width: widget.borderWidth!,
        ),
        color: widget.fillColor,
      ),
      child: Padding(
        padding: widget.margin!,
        child: DropdownButton<String>(
          hint: AutoSizeText(widget.hint!),
          value:
              effectiveOptions.contains(dropDownValue) ? dropDownValue : null,
          items: effectiveOptions
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: AutoSizeText(
                      e,
                      style: widget.textStyle,
                    ),
                  ))
              .toList(),
          elevation: widget.elevation!.toInt(),
          onChanged: (value) {
            dropDownValue = value!;
            widget.onChanged(value);
          },
          icon: widget.icon,
          isExpanded: true,
          dropdownColor: widget.fillColor,
        ),
      ),
    );
    if (widget.height != null || widget.width != null) {
      return SizedBox(
          width: widget.width, height: widget.height, child: childWidget);
    }
    return childWidget;
  }
}
