import 'package:agro_employee_public/src/data/model/plantation/edit_plantation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditFruitArea extends ConsumerWidget {
  final List<FruitArea> selectedDetails;
  final void Function(int) removeDetailAt;
  final void Function(int, WidgetRef, BuildContext) editDetailAt;

  const EditFruitArea({
    super.key,
    required this.selectedDetails,
    required this.removeDetailAt,
    required this.editDetailAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        selectedDetails.isEmpty
            ? SizedBox.shrink()
            : SizedBox(
                height: 330.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedDetails.length,
                  itemBuilder: (context, index) {
                    final detail = selectedDetails[index];
                    return Stack(
                      children: [
                        SizedBox(
                          width: 300.w,
                          child: Card(
                            child: Padding(
                              padding: REdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 25),
                                  _buildRow("Meva turi:", detail.fruitName ?? detail.fruit?.toString() ?? ""),
                                  SizedBox(height: 8),
                                  _buildRow("Meva navi:", detail.varietyName ?? detail.variety?.toString() ?? ""),
                                  if (detail.iqtisodiysamarasiz == true) ...[
                                    SizedBox(height: 8),
                                    _buildRow("Iqtisodiy samarasiz maydon:", 
                                        detail.economicInefficientArea?.toString() ?? "0.0"),
                                  ] else ...[
                                    SizedBox(height: 8),
                                    _buildRow("Payvand turi:", detail.rootstockName ?? detail.rootstock?.toString() ?? ""),
                                    SizedBox(height: 8),
                                    _buildRow("Ekinlagan yil:",
                                        detail.plantedYear.toString()),
                                    SizedBox(height: 8),
                                    _buildRow("Maydon:", detail.area.toString()),
                                    SizedBox(height: 8),
                                    _buildRow("Ko'chat sxemasi:", detail.schema),
                                    SizedBox(height: 8),
                                    _buildRow(
                                        "Meva maydoni ximoya to`siq\nbilan o`ralganmi:",
                                        detail.fenced == true ? 'Ha' : 'Yoq'),
                                    SizedBox(height: 8),
                                    _buildRow(
                                        "Kutilayotgan hosil miqdori: T",
                                        detail.weight == null
                                            ? '—'
                                            : detail.weight.toString()),
                                  ],
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
                              removeDetailAt(index);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        SizedBox(height: 16.h),
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
