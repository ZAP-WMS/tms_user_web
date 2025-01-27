import 'package:flutter/material.dart';
import 'package:tms_useweb_app/utils/app_dimensions.dart';
import 'package:tms_useweb_app/utils/text_styles.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  List<DropdownMenuItem<String>>? items = [];

  CustomDropdown(
      {Key? key,
      required this.label,
      required this.value,
      required this.onChanged,
      required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.getPadding(context, percentage: 0.005),
      child: SizedBox(
        width: AppDimensions.getWidth(context, percentage: 0.2),
        child: DropdownButtonFormField<String>(
          value: value,
          itemHeight: 48,
          items: items,
          //  provider.workData.map((String option) {
          //   return DropdownMenuItem<String>(
          //     value: option,
          //     child: Text(option),
          //   );
          // }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.boldBlackColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ),
    );
  }
}
