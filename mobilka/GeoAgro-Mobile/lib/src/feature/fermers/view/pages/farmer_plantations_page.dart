import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../../design_system/theme/colors.dart' as design_colors;
import '../../../../../design_system/theme/spacing.dart';
import '../../../../../design_system/theme/radius.dart';
import '../../../../../design_system/theme/typography.dart';
import '../widgets/farmer_plantation_card.dart';
import '../../vm/farmer_plantations_vm.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final farmerPlantationsVm =
    ChangeNotifierProvider.autoDispose<FarmerPlantationsVm>((ref) {
  return FarmerPlantationsVm();
});

class FarmerPlantationsPage extends ConsumerStatefulWidget {
  final int farmerId;
  final int farmerInn;
  final String farmerName;

  const FarmerPlantationsPage({
    super.key,
    required this.farmerId,
    required this.farmerInn,
    required this.farmerName,
  });

  @override
  ConsumerState<FarmerPlantationsPage> createState() =>
      _FarmerPlantationsPageState();
}

class _FarmerPlantationsPageState extends ConsumerState<FarmerPlantationsPage> {
  @override
  void initState() {
    super.initState();
    // Load farmer plantations when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(farmerPlantationsVm.notifier).getFarmerPlantations(
            farmerInn: widget.farmerInn,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(farmerPlantationsVm);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBarWidget(
        title: "Fermer plantatsiyalari",
        canPop: true,
      ),
      body: _buildContent(context, ref, vm),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, FarmerPlantationsVm vm) {
    if (vm.isLoading) {
      return Center(
        child: Icon(
          Icons.search,
          size: 120.sp,
          color: design_colors.AppColors.primary,
        ),
      );
    }

    if (vm.errorMessage != null) {
      return ErrorStateWidget(
        errorMessage: vm.errorMessage ?? "Kutilmagan xatolik",
        onTap: () =>
            ref.read(farmerPlantationsVm.notifier).getFarmerPlantations(
                  farmerInn: widget.farmerInn,
                ),
      );
    }

    if (vm.plantations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 120.sp,
              color: design_colors.AppColors.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              "Bu fermerda plantatsiya yo'q",
              style: AppTypography.bodyLarge(context).copyWith(
                color: design_colors.AppColors.darkOnBackground,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Sticky Header with farmer info
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            minHeight: 100,
            maxHeight: 100,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              margin: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: design_colors.AppColors.primaryContainerDark,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: design_colors.AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.farmerName,
                    style: AppTypography.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: design_colors.AppColors.primaryLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    "Jami ${vm.plantations.length} ta plantatsiya",
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: design_colors.AppColors.darkOnSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),

        // Plantations list/grid — одна колонка на compact/portrait
        // (узкий экран, список читабельнее), сетка на expanded+
        // (landscape-планшет — широкий экран, список тянулся во всю
        // ширину без пользы от простора).
        if (Responsive.shouldShowSidebar(context))
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: Responsive.getGridColumns(context),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childCount: vm.plantations.length,
              itemBuilder: (context, index) {
                final plantation = vm.plantations[index];
                return FarmerPlantationCard(
                  plantation: plantation,
                  onTap: () {
                    if (plantation.id > 0) {
                      context.go(
                        "${AppRouteNames.home}${AppRouteNames.plantationView}",
                        extra: plantation.id,
                      );
                    }
                  },
                );
              },
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final plantation = vm.plantations[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: FarmerPlantationCard(
                      plantation: plantation,
                      onTap: () {
                        // Navigate to plantation detail page
                        if (plantation.id > 0) {
                          context.go(
                            "${AppRouteNames.home}${AppRouteNames.plantationView}",
                            extra: plantation.id,
                          );
                        }
                      },
                    ),
                  );
                },
                childCount: vm.plantations.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
