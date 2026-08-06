import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/routes/app_route_names.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../vm/create_map_page_vm.dart';
import '../widgets/create_map_page_button_widgets.dart';
import '../widgets/center_ruler_widget.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/theme/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/theme/radius.dart';
import 'package:agro_employee_public/design_system/theme/spacing.dart';
import 'package:agro_employee_public/design_system/theme/typography.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final mapPageVM = ChangeNotifierProvider.autoDispose<CreateMapPageVm>((ref) {
  return CreateMapPageVm();
});

class CreateMapPage extends ConsumerStatefulWidget {
  final int farmerId;
  const CreateMapPage({super.key, required this.farmerId});

  @override
  ConsumerState<CreateMapPage> createState() => _CreateMapPageState();
}

class _CreateMapPageState extends ConsumerState<CreateMapPage> {
  @override
  void initState() {
    super.initState();
    log("${widget.farmerId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(mapPageVM);
      vm.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mapPageVM);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBarWidget(
        title: "Xarita",
        canPop: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () async {
                if (vm.polylineCoordinates.length < 3) {
                  Utils.fireTopSnackBar("Madyon to'gri kiritilmadi",
                      design_colors.AppColors.error, context);
                } else {
                  // Валидация координат с учетом limit_km (включает проверку currentLocation)
                  final validationError = vm.validateCoordinatesWithLimit(
                      vm.polylineCoordinates, vm.currentLocation);
                  if (validationError != null) {
                    Utils.fireTopSnackBar(validationError,
                        design_colors.AppColors.error, context);
                  } else if (vm.checkPolygonOverlap()) {
                    Utils.fireTopSnackBar(
                        "Plantatsiya boshqa plantatsiyalar ustiga chizilgan. Iltimos, boshqa joy tanlang",
                        design_colors.AppColors.error,
                        context);
                  } else {
                    final value = vm.cordinatesConverter();

                    // GPS-точка юзера. null если геолокация недоступна —
                    // фейковый центр Узбекистана в историю точек не шлём.
                    final currentLocation = vm.currentLocation;
                    final userLocationMap = currentLocation == null
                        ? null
                        : {
                            "latitude": currentLocation.latitude,
                            "longitude": currentLocation.longitude,
                          };
                    log("📤 Passing userLocation: $userLocationMap");

                    final model = {
                      "farmerId": widget.farmerId,
                      "coordinates": value,
                      "latLon": vm.polylineCoordinates,
                      "polygonArea": vm.polygonAreaHectares,
                      // Передаем текущее местоположение пользователя для user_location
                      "userLocation": userLocationMap,
                      // Момент реальной GPS-фиксации/antifraud-проверки —
                      // не момент финального сабмита формы (тот может
                      // случиться намного позже, особенно офлайн).
                      "collectedAt": DateTime.now().toIso8601String(),
                    };
                    log("📦 Model to pass: userLocation = ${model['userLocation']}");
                    context.push(
                      "/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}/${AppRouteNames.detailPage}",
                      extra: model,
                    );
                  }
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text("Keyingi"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                backgroundColor: design_colors.AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Responsive.shouldShowSidebar(context)
          ? Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: vm.currentLocation ?? vm.uzbLatLng,
                          zoom: 10,
                        ),
                        onMapCreated: vm.onMapCreated,
                        mapType: MapType.satellite,
                        zoomControlsEnabled: false,
                        polylines: vm.polylines,
                        polygons: {
                          ...vm.regionBoundaries,
                          if (vm.arePolygonsVisible) ...vm.nearbyPolygons,
                          ...vm.polygons,
                        },
                        markers: vm.markers,
                        onCameraMove: vm.onClusterCameraMove,
                        onTap: vm.onTap,
                      ),
                      CenterRulerWidget(isDrawingMode: vm.isDrawingMode),
                      if (vm.showPlantationDialog &&
                          vm.selectedPlantation != null)
                        _buildPlantationDialog(context, vm),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                _buildSidePanel(context, vm),
              ],
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.currentLocation ?? vm.uzbLatLng,
                    zoom: 10,
                  ),
                  onMapCreated: vm.onMapCreated,
                  mapType: MapType.satellite,
                  zoomControlsEnabled: false,
                  polylines: vm.polylines,
                  polygons: {
                    ...vm.regionBoundaries,
                    if (vm.arePolygonsVisible) ...vm.nearbyPolygons,
                    ...vm.polygons,
                  },
                  markers: vm.markers,
                  onCameraMove: vm.onClusterCameraMove,
                  onTap: vm.onTap,
                ),

                // Legend for plantation statuses - moved to bottom left
                Positioned(
                  bottom: 100,
                  left: 16,
                  child: _buildLegendCard(context),
                ),

                // Простое отображение площади в левом верхнем углу
                if (vm.drawingPoints.isNotEmpty && vm.drawingPoints.length >= 3)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildAreaCard(context, vm),
                  ),

                // Индикатор загрузки плантаций
                if (vm.isLoadingNearby)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Plantatsiyalar yuklanmoqda...',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Белая круглая линейка в центре экрана (всегда видна)
                CenterRulerWidget(isDrawingMode: vm.isDrawingMode),

                // Диалог с информацией о плантации
                if (vm.showPlantationDialog && vm.selectedPlantation != null)
                  _buildPlantationDialog(context, vm),
              ],
            ),
      floatingActionButton: Responsive.shouldShowSidebar(context)
          ? null
          : CreateMapPageButtonWidgets(vm: vm),
    );
  }

  Widget _buildLegendCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantatsiyalar holati:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('Tekshirilgan', design_colors.AppColors.success),
          _buildLegendItem('Tekshirilmagan', design_colors.AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context, CreateMapPageVm vm) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${vm.getPolygonArea().toStringAsFixed(2)} га',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, CreateMapPageVm vm) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      color: context.colors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Boshqaruv',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildLegendCard(context),
            if (vm.drawingPoints.isNotEmpty &&
                vm.drawingPoints.length >= 3) ...[
              const SizedBox(height: 16),
              _buildAreaCard(context, vm),
            ],
            if (vm.isLoadingNearby) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Plantatsiyalar yuklanmoqda...',
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textPrimary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Divider(color: context.colors.divider),
            const SizedBox(height: 16),
            // Кнопки — набор круглых FloatingActionButton, спроектированных
            // для позиционирования поверх карты (floatingActionButton
            // слот). Внутри плоской панели без выравнивания они прижимались
            // к левому краю растянутой колонки — оборачиваем в Center,
            // чтобы сохранить их собственное центрирование по горизонтали
            // независимо от того, что панель crossAxisAlignment.stretch.
            Center(child: CreateMapPageButtonWidgets(vm: vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantationDialog(BuildContext context, CreateMapPageVm vm) {
    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              design_colors.AppColors.primary,
                              design_colors.AppColors.primaryDark,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          vm.selectedPlantation!
                                  .getDisplayFarmerName()
                                  .trim()
                                  .isNotEmpty
                              ? vm.selectedPlantation!.getDisplayFarmerName()
                              : 'Plantatsiya #${vm.selectedPlantation!.id}',
                          style: AppTypography.headlineMedium(context)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: vm.closePlantationDialog,
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildChip(
                        context,
                        label: 'ID',
                        value: '${vm.selectedPlantation!.id}',
                        icon: Icons.numbers,
                      ),
                      _buildChip(
                        context,
                        label: 'Maydon',
                        value: vm.selectedPlantation!.getDisplayArea(),
                        icon: Icons.landscape_outlined,
                      ),
                      _buildChip(
                        context,
                        label: 'Status',
                        value: vm.selectedPlantation!.isChecked
                            ? 'Tekshirilgan'
                            : 'Tekshirilmagan',
                        icon: vm.selectedPlantation!.isChecked
                            ? Icons.verified_outlined
                            : Icons.hourglass_bottom_outlined,
                        color: vm.selectedPlantation!.isChecked
                            ? design_colors.AppColors.success
                            : design_colors.AppColors.warning,
                      ),
                      if (vm.selectedPlantation!
                          .getDisplayKonturNumbers()
                          .trim()
                          .isNotEmpty)
                        _buildChip(
                          context,
                          label: 'Kontur',
                          value:
                              vm.selectedPlantation!.getDisplayKonturNumbers(),
                          icon: Icons.schema_outlined,
                        ),
                      _buildChip(
                        context,
                        label: 'Nuqtalar',
                        value:
                            '${vm.selectedPlantation!.coordinates.length} ta',
                        icon: Icons.straighten_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label: ',
            style: AppTypography.bodySmall(context).copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall(context).copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
