import '../../../../data/model/plantation/new_plantation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../localization/app_strings.dart';

class AddSubsidyList extends StatelessWidget {
  final List<Subsidy> selectedList;
  final void Function(int) removeAt;

  const AddSubsidyList({
    super.key,
    required this.selectedList,
    required this.removeAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        selectedList.isEmpty
            ? SizedBox.shrink()
            : SizedBox(
                height: 240.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedList.length,
                  itemBuilder: (context, index) {
                    final detail = selectedList[index];
                    return Stack(
                      children: [
                        SizedBox(
                          width: 270.w,
                          child: Card(
                            child: Padding(
                              padding: REdgeInsets.all(12.0.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 25),
                                  _buildRow("Subsidiya yili:  ", detail.year),
                                  SizedBox(height: 8),
                                  _buildRow("Shartnoma raqami:  ",
                                      detail.contractNumber),
                                  SizedBox(height: 8),
                                  _buildRow("Subsidiya miqdori:  ",
                                      detail.amount.toString()),
                                  SizedBox(height: 8),
                                  _buildRow(
                                      "Subsidiya yonalishi:  ",
                                      AppLocalizedMaps.subsidyTypes[detail.direction ?? 0] ??
                                          'Noma’lum'),
                                  SizedBox(height: 8),
                                  _buildRow(
                                    "Subsidiya samaradorligi:  ",
                                    (detail.efficiency ?? false)
                                        ? "Samarali"
                                        : "Samarasiz",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.red, size: 16.sp),
                            onPressed: () {
                              removeAt(index);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        Expanded(
          child: Text(
            value != null && value.isNotEmpty ? value : 'Noma’lum',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Arial',
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
