import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/utils/responsive.dart';
import '../../../../data/model/plantation/plantations_list_model.dart';

/// Список плантаций: одна колонка на компактной ширине (телефон),
/// сетка (Responsive.getGridColumns) на medium+ — тот же паттерн, что
/// у HomePage._buildContent, вынесен сюда чтобы approved/pending/
/// recheck-страницы (изначально не входившие в план адаптации под
/// планшет, но страдающие от той же проблемы: список на всю ширину
/// планшета) не дублировали одну и ту же ветвящуюся логику трижды.
class PlantationListOrGridWidget extends StatelessWidget {
  final List<Result> items;
  final ScrollController? controller;
  final bool canLoadNext;
  final bool isFetchingMore;
  final VoidCallback onLoadMore;
  final Widget Function(Result plantation) itemBuilder;

  const PlantationListOrGridWidget({
    super.key,
    required this.items,
    required this.canLoadNext,
    required this.isFetchingMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.controller,
  });

  Widget _buildLoadMoreButton() {
    return Container(
      margin: REdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: isFetchingMore ? null : onLoadMore,
        style: ElevatedButton.styleFrom(
          backgroundColor: design_colors.AppColors.accentGreen,
          foregroundColor: Colors.white,
          padding: REdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isFetchingMore
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  8.horizontalSpace,
                  Text("Yuklanmoqda...", style: TextStyle(fontSize: 16.sp)),
                ],
              )
            : Text("Qolganlarini ko'rish", style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isCompact(context)) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        separatorBuilder: (_, __) => 16.verticalSpace,
        padding: REdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: items.length + (canLoadNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildLoadMoreButton();
          }
          return Padding(
            padding: REdgeInsets.symmetric(horizontal: 4),
            child: itemBuilder(items[index]),
          );
        },
      );
    }

    return SingleChildScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: REdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.getGridColumns(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(items[index]),
          ),
          if (canLoadNext) _buildLoadMoreButton(),
        ],
      ),
    );
  }
}
