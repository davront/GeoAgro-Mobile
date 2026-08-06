import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_route_names.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart' hide EmptyStateWidget;
import '../../../../data/model/farmer/district_area_stat_model.dart';
import '../../../../data/model/farmer/farmer_statistics_model.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../data/model/farmer/farmer_list_model.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import '../../../../../design_system/tokens/radii.dart';
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/typography.dart';
import '../../vm/farmers_statistics_vm.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';
import '../../../../../localization/app_strings.dart';

final farmersStatisticsVM =
    ChangeNotifierProvider.autoDispose<FarmersStatisticsVm>((ref) {
  return FarmersStatisticsVm();
});

class FarmersStatisticsPage extends ConsumerStatefulWidget {
  const FarmersStatisticsPage({super.key});

  @override
  ConsumerState<FarmersStatisticsPage> createState() =>
      _FarmersStatisticsPageState();
}

class _FarmersStatisticsPageState extends ConsumerState<FarmersStatisticsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint("📊 FarmersStatisticsPage: initState called");
    // Инициализируем данные только при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("📊 FarmersStatisticsPage: PostFrameCallback executing");
      final vm = ref.read(farmersStatisticsVM);
      debugPrint(
          "📊 FarmersStatisticsPage: statistics=${vm.statistics}, isLoading=${vm.isLoading}");
      if (vm.statistics == null && !vm.isLoading) {
        debugPrint("📊 FarmersStatisticsPage: Calling initialize()");
        vm.initialize();
      } else {
        debugPrint(
            "⚠️ FarmersStatisticsPage: Skipping initialize - statistics exists or is loading");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(farmersStatisticsVM);

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: "Fermerlar kesimida statistika",
        canPop: true,
        onBackPressed: () =>
            context.go('/farmers'), // Переход на страницу фермеров
      ),
      body: Container(
        color: context.colors.background,
        child: RefreshIndicator(
          onRefresh: () => vm.refresh(),
          color: design_colors.AppColors.accentGreen,
          backgroundColor: context.colors.surface,
          child: _BodyContent(vm: vm),
        ),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final FarmersStatisticsVm vm;

  const _BodyContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: const LoadingWidget(),
          ),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: ErrorStateWidget(
              errorMessage: vm.errorMessage!,
              onTap: vm.refresh,
            ),
          ),
        ),
      );
    }

    final statistics = vm.statistics;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SearchSection(),
          SizedBox(height: AppSpacing.lg),
          const _StatisticsFiltersSection(),
          SizedBox(height: AppSpacing.lg),
          if (vm.searchResults != null) ...[
            _SearchResultsList(vm: vm),
          ] else if (statistics == null || statistics.isEmpty) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const EmptyStateWidget(
                subMessage: "Ma'lumotlarni yangilash uchun pastga torting",
              ),
            ),
          ] else ...[
            _OverviewHeader(statistics: statistics),
            if (vm.myDistrictStat != null || vm.isLoadingDistrictStat) ...[
              SizedBox(height: AppSpacing.sectionSpacing),
              _MyDistrictSection(
                stat: vm.myDistrictStat,
                isLoading: vm.isLoadingDistrictStat,
              ),
            ],
            SizedBox(height: AppSpacing.sectionSpacing),
            _SummaryGrid(statistics: statistics),
            SizedBox(height: AppSpacing.sectionSpacing),
            _FarmersList(statistics: statistics),
          ],
        ],
      ),
    );
  }
}

class _SearchSection extends ConsumerWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(farmersStatisticsVM);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: vm.searchInnController,
                  hintText: "INN",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.search,
                  suffixIcon: vm.searchInnController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: context.colors.textSecondary,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            vm.clearSearch();
                          },
                        )
                      : null,
                  onChanged: (value) {
                    ref
                        .read(farmersStatisticsVM.notifier)
                        .onSearchChanged(value);
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: vm.isSearching ? null : vm.searchByInn,
                style: FilledButton.styleFrom(
                  backgroundColor: design_colors.AppColors.accentGreen,
                  foregroundColor: context.colors.textPrimary,
                  padding: EdgeInsets.all(AppSpacing.md),
                  minimumSize: Size(48.w, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: vm.isSearching
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.textPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: 20.sp,
                      ),
              ),
            ],
          ),
          if (vm.searchErrorMessage != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              vm.searchErrorMessage!,
              style: AppTypography.caption(context).copyWith(
                color: design_colors.AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatisticsFiltersSection extends ConsumerWidget {
  const _StatisticsFiltersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(farmersStatisticsVM);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filtrlar",
            style: AppTypography.body(context).copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<PlantationStatus>(
            initialValue: vm.selectedStatus,
            decoration: const InputDecoration(
              labelText: "Holati",
              border: OutlineInputBorder(),
            ),
            items: PlantationStatus.values
                .map(
                  (status) => DropdownMenuItem<PlantationStatus>(
                    value: status,
                    child: Text(status.labelUz),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(farmersStatisticsVM.notifier).setStatus(value);
              }
            },
          ),
          SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int?>(
            initialValue: vm.regionId,
            decoration: const InputDecoration(
              labelText: "Viloyat",
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Barcha viloyatlar"),
              ),
              ...AppLocalizedMaps.regions.entries.map(
                (entry) => DropdownMenuItem<int?>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(farmersStatisticsVM.notifier).setRegion(value);
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final FarmersStatisticsVm vm;

  const _SearchResultsList({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.searchResults == null || vm.searchResults!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: context.colors.cardBorder,
          boxShadow: context.colors.cardShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48.sp,
                color: context.colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                "Fermer topilmadi",
                style: AppTypography.body(context).copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Qidiruv natijalari",
              style: AppTypography.title(context).copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: vm.clearSearch,
              icon: Icon(
                Icons.close,
                size: 18.sp,
                color: context.colors.textSecondary,
              ),
              label: Text(
                "Tozalash",
                style: AppTypography.bodySmall(context).copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.searchResults!.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final farmer = vm.searchResults![index];
            return _SearchResultCard(farmer: farmer);
          },
        ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final FarmerModel farmer;

  const _SearchResultCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Fermer ma'lumotlari",
      child: GestureDetector(
        onTap: () {
          final farmerId = farmer.id ?? 0;
          final farmerInn = farmer.inn ?? farmer.id ?? 0;
          final farmerName = farmer.name ?? 'Fermer';
          final route =
              "/${AppRouteNames.farmers}/${AppRouteNames.farmerPlantations}?id=$farmerId&inn=$farmerInn&name=${Uri.encodeComponent(farmerName)}";
          context.push(route);
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: context.colors.cardBorder,
            boxShadow: context.colors.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.name ?? "Noma'lum fermer",
                            style: AppTypography.title(context).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (farmer.inn != null) ...[
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              "INN: ${farmer.inn}",
                              style: AppTypography.caption(context).copyWith(
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
                if (farmer.phoneNumber != null || farmer.address != null) ...[
                  SizedBox(height: AppSpacing.md),
                  Divider(
                    color: context.colors.divider.withValues(alpha: 0.6),
                    height: 1,
                  ),
                  SizedBox(height: AppSpacing.md),
                  if (farmer.phoneNumber != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16.sp,
                            color: context.colors.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            farmer.phoneNumber!,
                            style: AppTypography.bodySmall(context).copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (farmer.address != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            farmer.address!,
                            style: AppTypography.bodySmall(context).copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (farmer.createdBy != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16.sp,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            "Yaratgan: ${farmer.createdBy!.fullName} (${farmer.createdBy!.username})",
                            style: AppTypography.bodySmall(context).copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// _EmptyState removed

/// Показывает разбивку только по своему району (не по всему региону) —
/// сад/виноградник/площади. `stat == null` значит район ещё не найден в
/// ответе региона (например у юзера district_id вне списка) — секция не
/// рендерится вообще (см. вызывающий код).
class _MyDistrictSection extends StatelessWidget {
  final DistrictAreaStat? stat;
  final bool isLoading;

  const _MyDistrictSection({required this.stat, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: design_colors.AppColors.accentGreen,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                stat?.districtName ?? "Mening tumanim",
                style: AppTypography.title(context).copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (isLoading && stat == null)
            const Center(child: CircularProgressIndicator())
          else if (stat != null)
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _MetricPill(
                  label: "Fermerlar",
                  value: "${stat!.total.farmerCount}",
                  icon: Icons.groups_outlined,
                ),
                _MetricPill(
                  label: "Umumiy maydon",
                  value: "${stat!.total.totalArea.toStringAsFixed(1)} ga",
                  icon: Icons.map_outlined,
                ),
                _MetricPill(
                  label: "Ekilgan",
                  value: "${stat!.total.plantedArea.toStringAsFixed(1)} ga",
                  icon: Icons.grass_outlined,
                ),
                _MetricPill(
                  label: "Bog'lar",
                  value: "${stat!.fruitGarden.farmerCount}",
                  icon: Icons.park_outlined,
                ),
                _MetricPill(
                  label: "Uzumzorlar",
                  value: "${stat!.vineyard.farmerCount}",
                  icon: Icons.landscape_outlined,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  final List<FarmerData> statistics;

  const _OverviewHeader({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final totalFarmers = statistics.length;
    final totalArea = statistics.fold<double>(
      0.0,
      (sum, farmer) => sum + (farmer.totalArea ?? 0),
    );
    final plantedArea = statistics.fold<double>(
      0.0,
      (sum, farmer) => sum + (farmer.plantedArea ?? 0),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.highlight,
            context.colors.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fermerlar kesimida statistika",
            style: AppTypography.headline3(context).copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            "Fermerlar soni: $totalFarmers",
            style: AppTypography.bodySmall(context).copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            "Umumiy maydon: ${totalArea.toStringAsFixed(1)} ga • Ekilgan: ${plantedArea.toStringAsFixed(1)} ga",
            style: AppTypography.bodySmall(context).copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<FarmerData> statistics;

  const _SummaryGrid({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final totalPlantations = statistics.fold<int>(
      0,
      (sum, farmer) => sum + (farmer.totalPlantations ?? 0),
    );
    final approvedPlantations = statistics.fold<int>(
      0,
      (sum, farmer) => sum + (farmer.approvedPlantations ?? 0),
    );
    final rejectedPlantations = statistics.fold<int>(
      0,
      (sum, farmer) => sum + (farmer.rejectedPlantations ?? 0),
    );
    final fruitGardens = statistics.fold<int>(
      0,
      (sum, farmer) => sum + (farmer.fruitGardenCount ?? 0),
    );
    final vineyards = statistics.fold<int>(
      0,
      (sum, farmer) => sum + (farmer.vineyardCount ?? 0),
    );
    final totalArea = statistics.fold<double>(
      0.0,
      (sum, farmer) => sum + (farmer.totalArea ?? 0.0),
    );
    final plantedArea = statistics.fold<double>(
      0.0,
      (sum, farmer) => sum + (farmer.plantedArea ?? 0.0),
    );
    final approvedArea = statistics.fold<double>(
      0.0,
      (sum, farmer) => sum + (farmer.approvedArea ?? 0.0),
    );

    final items = [
      _SummaryItem(
        title: "Jami plantatsiyalar",
        value: "$totalPlantations",
        icon: Icons.eco_outlined,
        accent: design_colors.AppColors.accentGreen,
      ),
      _SummaryItem(
        title: "Tasdiqlangan",
        value: "$approvedPlantations",
        icon: Icons.verified_outlined,
        accent: design_colors.AppColors.chartBlue,
        onTap: () {
          context.push("${AppRouteNames.home}${AppRouteNames.approvedPage}");
        },
      ),
      _SummaryItem(
        title: "Rad etilgan",
        value: "$rejectedPlantations",
        icon: Icons.highlight_off_outlined,
        accent: design_colors.AppColors.chartRed,
        onTap: () {
          context.push("${AppRouteNames.home}${AppRouteNames.recheckPage}");
        },
      ),
      _SummaryItem(
        title: "Mevazorlar",
        value: "$fruitGardens",
        icon: Icons.park_outlined,
        accent: design_colors.AppColors.chartEmerald,
      ),
      _SummaryItem(
        title: "Uzumzorlar",
        value: "$vineyards",
        icon: Icons.landscape_outlined,
        accent: design_colors.AppColors.chartMint,
      ),
      _SummaryItem(
        title: "Umumiy maydon",
        value: "${totalArea.toStringAsFixed(1)} ga",
        icon: Icons.map_outlined,
        accent: design_colors.AppColors.chartPurple,
      ),
      _SummaryItem(
        title: "Ekilgan maydon",
        value: "${plantedArea.toStringAsFixed(1)} ga",
        icon: Icons.grass_outlined,
        accent: design_colors.AppColors.chartTeal,
      ),
      _SummaryItem(
        title: "Tasdiqlangan maydon",
        value: "${approvedArea.toStringAsFixed(1)} ga",
        icon: Icons.check_circle_outline,
        accent: design_colors.AppColors.chartBlue,
      ),
    ];

    // Fixed childAspectRatio grids overflow once real content (longer
    // values/titles) doesn't match the guessed ratio — masonry sizes each
    // cell by its own content instead of a fixed guess.
    final columns = Responsive.getGridColumns(context);
    return MasonryGridView.count(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      itemBuilder: (context, index) => _SummaryCard(item: items[index]),
    );
  }
}

class _SummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.onTap,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.accent,
                    size: 22.sp,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: AppTypography.headline3(context).copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      item.title,
                      style: AppTypography.caption(context).copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmersList extends StatelessWidget {
  final List<FarmerData> statistics;

  const _FarmersList({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fermerlar ro'yxati",
          style: AppTypography.title(context).copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statistics.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) =>
              _FarmerCard(farmer: statistics[index]),
        ),
      ],
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final FarmerData farmer;

  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Fermer statistikasi",
      child: GestureDetector(
        onTap: () {
          final farmerId = farmer.id ?? 0;
          final farmerInn = farmer.inn ?? farmer.id ?? 0;
          final farmerName = farmer.name ?? 'Fermer';
          final route =
              "/${AppRouteNames.farmers}/${AppRouteNames.farmerPlantations}?id=$farmerId&inn=$farmerInn&name=${Uri.encodeComponent(farmerName)}";

          debugPrint(
              'FarmersStatisticsPage: Navigating to farmer plantations: $route');
          debugPrint(
              'FarmersStatisticsPage: farmerId=$farmerId, farmerInn=$farmerInn');
          context.push(route);
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: context.colors.cardBorder,
            boxShadow: context.colors.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.name ?? "Noma'lum fermer",
                            style: AppTypography.title(context).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            farmer.lastAddedPlantations?.isNotEmpty == true
                                ? "Oxirgi qo'shilgan: ${_formatDate(farmer.lastAddedPlantations!)}"
                                : "Yangilangan ma'lumot mavjud emas",
                            style: AppTypography.caption(context).copyWith(
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Divider(
                  color: context.colors.divider.withValues(alpha: 0.6),
                  height: 1,
                ),
                SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = AppSpacing.lg;
                    final availableWidth = constraints.maxWidth;

                    // Минимальная ширина для одного элемента (примерно 140-160px)
                    final minTileWidth = 140.0;

                    // Список всех метрик
                    final metrics = [
                      _MetricPill(
                        label: "Plantatsiyalar",
                        value: "${farmer.totalPlantations ?? 0}",
                        icon: Icons.forest_outlined,
                      ),
                      _MetricPill(
                        label: "Tasdiqlangan",
                        value: "${farmer.approvedPlantations ?? 0}",
                        icon: Icons.check_circle_outlined,
                      ),
                      _MetricPill(
                        label: "Rad etilgan",
                        value: "${farmer.rejectedPlantations ?? 0}",
                        icon: Icons.highlight_off_outlined,
                      ),
                      _MetricPill(
                        label: "Mevazorlar",
                        value: "${farmer.fruitGardenCount ?? 0}",
                        icon: Icons.park_outlined,
                      ),
                      _MetricPill(
                        label: "Uzumzorlar",
                        value: "${farmer.vineyardCount ?? 0}",
                        icon: Icons.landscape_outlined,
                      ),
                      _MetricPill(
                        label: "Umumiy maydon",
                        value:
                            "${(farmer.totalArea ?? 0).toStringAsFixed(1)} ga",
                        icon: Icons.map_outlined,
                      ),
                      _MetricPill(
                        label: "Ekilgan",
                        value:
                            "${(farmer.plantedArea ?? 0).toStringAsFixed(1)} ga",
                        icon: Icons.grass_outlined,
                      ),
                      if ((farmer.approvePercent ?? 0) > 0)
                        _MetricPill(
                          label: "Tasdiqlash %",
                          value:
                              "${(farmer.approvePercent ?? 0).toStringAsFixed(0)}%",
                          icon: Icons.percent_outlined,
                        ),
                    ];

                    // Вычисляем, помещаются ли все элементы в одну строку
                    // Если ширина каждого элемента при размещении в одну строку >= minTileWidth, используем один столбец
                    // Если нет - используем два столбца
                    final singleRowWidth = availableWidth / metrics.length;
                    final useTwoColumns =
                        singleRowWidth < minTileWidth && metrics.length > 1;

                    // Вычисляем ширину элемента
                    final tileWidth = useTwoColumns
                        ? (availableWidth - spacing) / 2
                        : (availableWidth - (spacing * (metrics.length - 1))) /
                            metrics.length;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.start,
                      children: metrics.map((metric) {
                        return SizedBox(
                          width: tileWidth,
                          child: metric,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      // Парсим ISO 8601 формат (например: 2025-10-18T07:24:03.910158Z)
      final date = DateTime.parse(dateString);
      // Форматируем в читаемый формат: dd.MM.yyyy HH:mm
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      // Если не удалось распарсить, возвращаем исходную строку
      return dateString;
    }
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.isDark
            ? context.colors.surfaceElevated
            : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: context.colors.isDark
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: design_colors.AppColors.accentGreen,
          ),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.bodySmall(context).copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTypography.caption(context).copyWith(
                    color: context.colors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
