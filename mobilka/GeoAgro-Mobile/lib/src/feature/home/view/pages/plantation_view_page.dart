import 'dart:convert';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../data/model/plantation/edit_plantation.dart';
import '../../../../data/model/plantation/comment_model.dart';
import '../../../../data/repository/app_repository_impl.dart';
import 'package:agro_employee_public/src/feature/google_map/vm/plantation_map_view_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../pages/home_page.dart';
import '../../../../core/services/biometric_service.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final plantationViewVM = ChangeNotifierProvider.autoDispose
    .family<_PlantationViewVm, int>((ref, id) {
  return _PlantationViewVm(id);
});

final plantationMapMiniVM = ChangeNotifierProvider.autoDispose
    .family<PlantationMapViewVm, int>((ref, id) {
  final vm = PlantationMapViewVm(id);
  ref.onDispose(vm.dispose);
  return vm;
});

/// Локальный класс секции (замена DetailSection из screen_shells)
class _DetailSection {
  final String title;
  final IconData? icon;
  final Widget content;

  _DetailSection({
    required this.title,
    this.icon,
    required this.content,
  });
}

class _PlantationViewVm extends ChangeNotifier {
  final AppRepositoryImpl _repo = AppRepositoryImpl();
  final int plantationId;

  bool isLoading = true;
  String? errorMessage;
  EditPlantationModel? plantation;

  /// Имена пользователей: создатель и модератор
  String? createdByName;
  String? moderatedByName;

  _PlantationViewVm(this.plantationId) {
    _loadPlantation();
  }

  Future<void> _loadPlantation() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _repo.getPlantationDetail(id: plantationId);
      if (data == null) {
        errorMessage = "Ma'lumotlar topilmadi";
      } else {
        plantation = editPlantationModelFromJson(data);
        // Загружаем имена пользователей асинхронно
        _loadUserNames();
      }
    } catch (e) {
      errorMessage = "Xatolik yuz berdi: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Асинхронно загружает имена пользователей (создатель и модератор)
  Future<void> _loadUserNames() async {
    final createdById = plantation?.createdBy;
    final moderatedById = plantation?.moderatedBy;

    // Загружаем параллельно
    final futures = <Future>[];

    if (createdById != null) {
      futures.add(_fetchUserName(createdById).then((name) {
        createdByName = name;
      }));
    }

    if (moderatedById != null) {
      futures.add(_fetchUserName(moderatedById).then((name) {
        moderatedByName = name;
      }));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
      notifyListeners();
    }
  }

  /// Получает имя пользователя по ID через API
  Future<String?> _fetchUserName(int userId) async {
    try {
      final data = await _repo.getUserById(id: userId);
      if (data != null) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        // Пробуем разные возможные поля для имени
        final fullName =
            json['full_name'] ?? json['display_name'] ?? json['name'];
        final firstName = json['first_name']?.toString() ?? '';
        final lastName = json['last_name']?.toString() ?? '';

        if (fullName != null && fullName.toString().trim().isNotEmpty) {
          return fullName.toString();
        }
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          return '$firstName $lastName'.trim();
        }
        // Если имени нет, пробуем username
        final username = json['username'];
        if (username != null) return username.toString();
      }
    } catch (e) {
      debugPrint('Failed to fetch user name for id=$userId: $e');
    }
    return null;
  }

  void retry() => _loadPlantation();
}

class PlantationViewPage extends ConsumerStatefulWidget {
  final int id;
  const PlantationViewPage({super.key, required this.id});

  @override
  ConsumerState<PlantationViewPage> createState() => _PlantationViewPageState();
}

class _PlantationViewPageState extends ConsumerState<PlantationViewPage> {
  bool _hasTriedToLoadMapCoordinates = false;
  bool _hasTriedToInitializeFromDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Перезагружаем данные плантации при открытии страницы
      ref.read(plantationViewVM(widget.id)).retry();
      // Перезагружаем координаты для карты только один раз
      if (!_hasTriedToLoadMapCoordinates) {
        _hasTriedToLoadMapCoordinates = true;
        ref.read(plantationMapMiniVM(widget.id)).loadRelatedPlantations();
      }
    });
  }

  /// Пытается инициализировать карту с координатами из детальной информации
  Future<void> _tryInitializeMapFromDetail(int? plantationId) async {
    if (plantationId == null) {
      debugPrint("[PlantationViewPage] Plantation ID is null");
      return;
    }

    try {
      debugPrint(
          "[PlantationViewPage] Trying to initialize map from detail for ID: $plantationId");
      final repo = AppRepositoryImpl();
      final data = await repo.getPlantationDetail(id: plantationId);
      if (data != null) {
        debugPrint(
            "[PlantationViewPage] Got detail data, length: ${data.length}");
        final jsonData = jsonDecode(data);
        debugPrint("[PlantationViewPage] Parsed JSON, keys: ${jsonData.keys}");

        if (jsonData['coordinates'] != null) {
          debugPrint("[PlantationViewPage] Coordinates found in response");
          final mapVm = ref.read(plantationMapMiniVM(widget.id));
          mapVm.initializeFromDetailData(jsonData);
        } else {
          debugPrint("[PlantationViewPage] No coordinates in detail response");
        }
      } else {
        debugPrint("[PlantationViewPage] Detail data is null");
      }
    } catch (e, stackTrace) {
      debugPrint("[PlantationViewPage] Error initializing map from detail: $e");
      debugPrint("[PlantationViewPage] Stack trace: $stackTrace");
    }
  }

  Widget _buildSummaryHighlights(
    BuildContext context,
    List<_InfoEntry> entries,
  ) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i == entries.length - 1 ? 0 : AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entries[i].icon != null) ...[
                    Icon(
                      entries[i].icon,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    entries[i].label,
                    style: AppTypography.caption(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entries[i].value,
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return "0";

    String intPart;
    String decPart = '';

    if (value is double) {
      if (value == value.toInt().toDouble()) {
        intPart = value.toInt().toString();
      } else {
        final parts = value.toStringAsFixed(2).split('.');
        intPart = parts[0];
        decPart = '.${parts[1]}';
      }
    } else if (value is int) {
      intPart = value.toString();
    } else {
      return value.toString();
    }

    // Добавляем разделитель тысяч (пробел)
    final isNegative = intPart.startsWith('-');
    if (isNegative) intPart = intPart.substring(1);

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(intPart[i]);
    }

    return '${isNegative ? '-' : ''}$buffer$decPart';
  }

  /// Форматирует ISO 8601 дату в читаемый формат: "dd.MM.yyyy HH:mm"
  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "Noma'lum";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildCommentsList(
      BuildContext context, List<Comment> comments, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...comments
            .map((comment) => _buildCommentCard(context, comment, isDark)),
      ],
    );
  }

  Widget _buildModerationCommentsList(BuildContext context,
      List<_ModerationCommentDisplay> comments, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...comments.map(
            (comment) => _buildModerationCommentCard(context, comment, isDark)),
      ],
    );
  }

  Widget _buildModerationCommentCard(
      BuildContext context, _ModerationCommentDisplay comment, bool isDark) {
    String formattedDate = '';
    if (comment.timestamp != null) {
      try {
        final date = DateTime.parse(comment.timestamp!);
        formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
      } catch (e) {
        formattedDate = comment.timestamp!;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: design_colors.AppColors.warning.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: design_colors.AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "Moderatsiya",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: design_colors.AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 12.sp,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (comment.author != null && comment.author!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              comment.author!,
              style: AppTypography.caption(context).copyWith(
                fontSize: 12.sp,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            comment.text,
            style: AppTypography.bodySmall(context).copyWith(
              fontSize: 14.sp,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, Comment comment, bool isDark) {
    String formattedDate = '';
    try {
      final date = DateTime.parse(comment.createdAt);
      formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      formattedDate = comment.createdAt;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (comment.isModeration)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "Moderatsiya",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (comment.isModeration) SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  formattedDate,
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 12.sp,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (comment.createdBy != null) ...[
            SizedBox(height: 4.h),
            Text(
              comment.createdBy!.fullName,
              style: AppTypography.caption(context).copyWith(
                fontSize: 12.sp,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            comment.body,
            style: AppTypography.bodySmall(context).copyWith(
              fontSize: 14.sp,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailVm = ref.watch(plantationViewVM(widget.id));
    final mapVm = ref.watch(plantationMapMiniVM(widget.id));

    final isLoading = detailVm.isLoading;
    final hasError = detailVm.errorMessage != null;
    final plantation = detailVm.plantation;
    // Используем статус из currentPlantation, если доступен, иначе из plantation
    final statusData = _resolveStatus(
      mapVm.currentPlantation,
      plantation,
      Theme.of(context).colorScheme,
    );

    Widget? summaryCard;
    List<_InfoEntry> baseEntries = const [];
    List<_DetailSection> sections = const [];

    if (!isLoading && !hasError && plantation != null) {
      // Пытаемся использовать координаты из детальной информации для немедленного отображения
      // Только если еще не пытались инициализировать и карта не загружена
      if (!_hasTriedToInitializeFromDetail &&
          mapVm.currentPlantation == null &&
          !mapVm.isLoading) {
        _hasTriedToInitializeFromDetail = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Пытаемся получить координаты из ответа API детальной информации
          _tryInitializeMapFromDetail(plantation.id);

          // Также загружаем координаты через стандартный endpoint, если инициализация не удалась
          Future.delayed(AppMotion.slow, () {
            if (mapVm.currentPlantation == null &&
                !mapVm.isLoading &&
                !_hasTriedToLoadMapCoordinates) {
              _hasTriedToLoadMapCoordinates = true;
              mapVm.loadRelatedPlantations();
            }
          });
        });
      }

      baseEntries = _buildBaseEntries(context, plantation, mapVm);
      summaryCard = _buildSummaryCard(
        context: context,
        plantation: plantation,
        mapVm: mapVm,
        statusData: statusData,
      );
      sections = _buildDetailSections(
        context: context,
        plantation: plantation,
        mapVm: mapVm,
        baseEntries: baseEntries,
        statusData: statusData,
        detailVm: detailVm,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text("Plantatsiya ma'lumotlari"),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
      ),
      body: hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: design_colors.AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      detailVm.errorMessage ?? "Xatolik yuz berdi",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: detailVm.retry,
                      child: const Text("Qayta urinish"),
                    ),
                  ],
                ),
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    // Шире общего Responsive.getMaxContentWidth: эта
                    // страница — сплошные короткие label+value плитки
                    // (_buildInfoGrid), которые с обычным лимитом
                    // оставляли пустое поле по бокам на планшете вместо
                    // того, чтобы разложить больше плиток в строку.
                    constraints: BoxConstraints(
                      maxWidth: Responsive.isCompact(context)
                          ? Responsive.getMaxContentWidth(context)
                          : 1400,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.isCompact(context) ? 16 : 8,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (summaryCard != null) ...[
                            summaryCard,
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (sections.isNotEmpty)
                            ...sections.map((section) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.lg,
                                  ),
                                  child: _buildSectionWidget(context, section),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionWidget(BuildContext context, _DetailSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (section.icon != null) ...[
              Icon(
                section.icon,
                size: 20,
                color: design_colors.AppColors.accentGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              section.title,
              style: AppTypography.title(context).copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        section.content,
      ],
    );
  }

  List<_InfoEntry> _buildBaseEntries(
    BuildContext context,
    EditPlantationModel plantation,
    PlantationMapViewVm mapVm,
  ) {
    final entries = <_InfoEntry>[
      if (plantation.id != null)
        _InfoEntry(
          "Plantatsiya ID",
          plantation.id.toString(),
          Icons.badge_outlined,
        ),
      if (plantation.gardenEstablishedYear != null)
        _InfoEntry(
          "Bog' tashkil topgan yil",
          plantation.gardenEstablishedYear.toString(),
          Icons.calendar_month_outlined,
        ),
      if (plantation.plantationType != null)
        _InfoEntry(
          "Plantatsiya turi",
          AppLocalizedMaps.plantationTypes[plantation.plantationType] ??
              "Noma'lum",
          Icons.category_outlined,
        ),
      if (_resolveTypeChoiceLabel(plantation) != null)
        _InfoEntry(
          "Yo'nalish",
          _resolveTypeChoiceLabel(plantation)!,
          Icons.style_outlined,
        ),
      if (_resolveSubtypeLabel(plantation) != null)
        _InfoEntry(
          "Subtype",
          _resolveSubtypeLabel(plantation)!,
          Icons.bubble_chart_outlined,
        ),
      _InfoEntry(
        "Umumiy maydon",
        "${_formatNumber(plantation.totalArea)} GA",
        Icons.square_foot_outlined,
      ),
      _InfoEntry(
        "Sug'oriladigan maydon",
        "${_formatNumber(plantation.irrigationArea)} GA",
        Icons.water_drop_outlined,
      ),
      _InfoEntry(
        "Bo'sh maydon",
        "${_formatNumber(plantation.emptyArea)} GA",
        Icons.crop_square_outlined,
      ),
      _InfoEntry(
        "Yaroqsiz maydon",
        "${_formatNumber(plantation.notUsableArea)} GA",
        Icons.block_outlined,
      ),
      if (plantation.landType != null)
        _InfoEntry(
          "Yer turi",
          AppLocalizedMaps.yerTuri[plantation.landType] ?? "Noma'lum",
          Icons.terrain_outlined,
        ),
      if (plantation.fertilityScore != null)
        _InfoEntry(
          "Banitet bali",
          plantation.fertilityScore!.toStringAsFixed(1),
          Icons.leaderboard_outlined,
        ),
      _InfoEntry(
        "Unumdormi",
        plantation.isFertile == true ? "Ha" : "Yo'q",
        plantation.isFertile == true
            ? Icons.check_circle
            : Icons.cancel_outlined,
      ),
      if (plantation.irrigationSystemsCount != null)
        _InfoEntry(
          "Sug'orish tizimlari",
          plantation.irrigationSystemsCount.toString(),
          Icons.precision_manufacturing_outlined,
        ),
      if (plantation.konturNumber != null &&
          plantation.konturNumber!.isNotEmpty)
        _InfoEntry(
          "Kontur raqamlari",
          plantation.konturNumber!.join(", "),
          Icons.numbers_outlined,
        ),
    ];

    return entries;
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required EditPlantationModel plantation,
    required PlantationMapViewVm mapVm,
    required MapEntry<String, Color> statusData,
  }) {
    final name = mapVm.currentPlantation?.name?.trim();
    final title = (name != null && name.isNotEmpty)
        ? name
        : "Plantatsiya #${plantation.id ?? widget.id}";

    final descriptionParts = <String>[];
    final typeLabel =
        AppLocalizedMaps.plantationTypes[plantation.plantationType];
    if (typeLabel != null) descriptionParts.add(typeLabel);
    final direction = _resolveTypeChoiceLabel(plantation);
    if (direction != null) descriptionParts.add(direction);
    if (plantation.gardenEstablishedYear != null) {
      descriptionParts.add("${plantation.gardenEstablishedYear} yil");
    }

    final highlightEntries = <_InfoEntry>[
      _InfoEntry(
        "Umumiy maydon",
        "${_formatNumber(plantation.totalArea)} GA",
        Icons.square_foot_outlined,
      ),
      _InfoEntry(
        "Sug'oriladigan maydon",
        "${_formatNumber(plantation.irrigationArea)} GA",
        Icons.water_drop_outlined,
      ),
      if (mapVm.currentPlantation?.coordinates.isNotEmpty ?? false)
        _InfoEntry(
          "Koordinatalar",
          mapVm.currentPlantation!.coordinates.length.toString(),
          Icons.straighten_outlined,
        ),
    ];

    final gradientColors = [
      design_colors.AppColors.accentGreenDark.withValues(alpha: 0.9),
      design_colors.AppColors.accentGreen.withValues(alpha: 0.75),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
                      title,
                      style: AppTypography.headline3(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (descriptionParts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        descriptionParts.join(" • "),
                        style: AppTypography.bodySmall(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 18, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      statusData.key,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSummaryHighlights(context, highlightEntries),
        ],
      ),
    );
  }

  List<_DetailSection> _buildDetailSections({
    required BuildContext context,
    required EditPlantationModel plantation,
    required PlantationMapViewVm mapVm,
    required List<_InfoEntry> baseEntries,
    required MapEntry<String, Color> statusData,
    required _PlantationViewVm detailVm,
  }) {
    final isDark = context.colors.isDark;
    final sections = <_DetailSection>[];

    // Секция с информацией о подтверждении/модерации — первой
    if (plantation.moderatedAt != null ||
        plantation.moderatedBy != null ||
        plantation.createdAt != null ||
        plantation.createdBy != null) {
      final createdByDisplay = detailVm.createdByName ??
          (plantation.createdBy != null ? 'ID: ${plantation.createdBy}' : null);
      final moderatedByDisplay = detailVm.moderatedByName ??
          (plantation.moderatedBy != null
              ? 'ID: ${plantation.moderatedBy}'
              : null);

      final moderationEntries = <_InfoEntry>[
        if (createdByDisplay != null)
          _InfoEntry(
            "Yaratgan",
            createdByDisplay,
            Icons.person_add_outlined,
          ),
        if (plantation.createdAt != null)
          _InfoEntry(
            "Yaratilgan vaqt",
            _formatDateTime(plantation.createdAt),
            Icons.access_time_outlined,
          ),
        if (moderatedByDisplay != null)
          _InfoEntry(
            "Tasdiqlagan",
            moderatedByDisplay,
            Icons.verified_user_outlined,
            design_colors.AppColors.success,
          ),
        if (plantation.moderatedAt != null)
          _InfoEntry(
            "Tasdiqlangan vaqt",
            _formatDateTime(plantation.moderatedAt),
            Icons.schedule_outlined,
            design_colors.AppColors.success,
          ),
      ];

      if (moderationEntries.isNotEmpty) {
        sections.add(
          _DetailSection(
            title: "Tasdiqlash ma'lumotlari",
            icon: Icons.verified_outlined,
            content: _buildMetricsCard(context, moderationEntries),
          ),
        );
      }
    }

    // Карта и статус
    sections.add(
      _DetailSection(
        title: "Xarita va holat",
        icon: Icons.map_outlined,
        content: _buildMapCard(
          context: context,
          plantation: plantation,
          mapVm: mapVm,
          statusData: statusData,
        ),
      ),
    );

    // Основная информация
    sections.add(
      _DetailSection(
        title: "Asosiy ma'lumotlar",
        icon: Icons.info_outline,
        content: _buildMetricsCard(context, baseEntries),
      ),
    );

    if (plantation.trellises?.isNotEmpty == true) {
      sections.add(
        _DetailSection(
          title: "Shpaller",
          icon: Icons.account_tree_outlined,
          content: _buildGroupedCard(
            context,
            plantation.trellises!
                .map((trellis) => [
                      _InfoEntry(
                        "Shpaller turi",
                        _resolveTrellisType(trellis.trellisType),
                        Icons.account_tree_outlined,
                      ),
                      _InfoEntry(
                        "Maydon",
                        "${_formatNumber(trellis.trellisInstalledArea)} GA",
                        Icons.square_foot_outlined,
                      ),
                      if (trellis.trellisCount != null)
                        _InfoEntry(
                          "Soni",
                          trellis.trellisCount.toString(),
                          Icons.countertops_outlined,
                        ),
                    ])
                .toList(),
          ),
        ),
      );
    }

    if (plantation.reservoirs?.isNotEmpty == true) {
      sections.add(
        _DetailSection(
          title: "Suv havzalari",
          icon: Icons.water_outlined,
          content: _buildGroupedCard(
            context,
            plantation.reservoirs!
                .map((reservoir) => [
                      _InfoEntry(
                        "Hovuz turi",
                        _resolveReservoirType(reservoir.reservoirType),
                        Icons.pool_outlined,
                      ),
                      _InfoEntry(
                        "Hajm",
                        "${reservoir.reservoirVolume ?? 0} m³",
                        Icons.opacity_outlined,
                      ),
                    ])
                .toList(),
          ),
        ),
      );
    }

    if (plantation.investments?.isNotEmpty == true) {
      sections.add(
        _DetailSection(
          title: "Investitsiyalar",
          icon: Icons.account_balance_wallet_outlined,
          content: _buildGroupedCard(
            context,
            plantation.investments!
                .map((investment) => [
                      _InfoEntry(
                        "Turi",
                        investment.investType == 1 ? "Mahalliy" : "Xorijiy",
                        Icons.flag_outlined,
                      ),
                      _InfoEntry(
                        "Miqdor",
                        "${_formatNumber(investment.investmentAmount)} ${investment.investType == 1 ? 'UZS' : 'USD'}",
                        Icons.attach_money_outlined,
                      ),
                    ])
                .toList(),
          ),
        ),
      );
    }

    if (plantation.subsidies?.isNotEmpty == true) {
      sections.add(
        _DetailSection(
          title: "Subsidiyalar",
          icon: Icons.card_giftcard_outlined,
          content: _buildGroupedCard(
            context,
            plantation.subsidies!
                .map((subsidy) => [
                      if (subsidy.direction != null)
                        _InfoEntry(
                          "Yo'nalish",
                          AppLocalizedMaps.subsidyTypes[subsidy.direction] ??
                              "Noma'lum",
                          Icons.category_outlined,
                        ),
                      if (subsidy.year != null)
                        _InfoEntry(
                          "Yil",
                          subsidy.year.toString(),
                          Icons.event_outlined,
                        ),
                      if (subsidy.contractNumber != null &&
                          subsidy.contractNumber!.isNotEmpty)
                        _InfoEntry(
                          "Shartnoma raqami",
                          subsidy.contractNumber!,
                          Icons.description_outlined,
                        ),
                      if (subsidy.amount != null)
                        _InfoEntry(
                          "Miqdor",
                          "${_formatNumber(subsidy.amount)} UZS",
                          Icons.payments_outlined,
                        ),
                      _InfoEntry(
                        "Samaradorlik",
                        subsidy.efficiency == true ? "Ha" : "Yo'q",
                        subsidy.efficiency == true
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                      ),
                    ])
                .toList(),
          ),
        ),
      );
    }

    // Добавляем секцию с комментариями при создании (не модерация)
    final regularComments = plantation.comments
        ?.where((comment) => comment.isModeration == false)
        .toList();
    if (regularComments != null && regularComments.isNotEmpty) {
      sections.add(
        _DetailSection(
          title: "Izohlar (yaratilganda)",
          icon: Icons.comment_outlined,
          content: _buildCommentsList(context, regularComments, isDark),
        ),
      );
    }

    // Добавляем секцию с комментариями модерации
    final moderationCommentsFromComments = plantation.comments
        ?.where((comment) => comment.isModeration == true)
        .toList();
    final moderationCommentsFromField = plantation.moderationComments;

    // Объединяем комментарии модерации из обоих источников
    final allModerationComments = <_ModerationCommentDisplay>[];

    // Добавляем из comments где is_moderation: true
    if (moderationCommentsFromComments != null) {
      for (var comment in moderationCommentsFromComments) {
        allModerationComments.add(_ModerationCommentDisplay(
          id: comment.id,
          text: comment.body,
          timestamp: comment.createdAt,
          author: comment.createdBy?.fullName,
        ));
      }
    }

    // Добавляем из moderation_comment
    if (moderationCommentsFromField != null) {
      for (var comment in moderationCommentsFromField) {
        if (comment.text != null && comment.text!.isNotEmpty) {
          allModerationComments.add(_ModerationCommentDisplay(
            id: comment.id,
            text: comment.text!,
            timestamp: null,
            author: "Moderator",
          ));
        }
      }
    }

    if (allModerationComments.isNotEmpty) {
      sections.add(
        _DetailSection(
          title: "Moderatsiya izohlari",
          icon: Icons.gavel_outlined,
          content: _buildModerationCommentsList(
              context, allModerationComments, isDark),
        ),
      );
    }

    if (plantation.fruitAreas?.isNotEmpty == true) {
      // Проверяем, есть ли экономически неэффективные зоны
      final inefficientFruits = plantation.fruitAreas!
          .where((fruit) => fruit.iqtisodiysamarasiz == true)
          .toList();
      final hasInefficientAreas = inefficientFruits.isNotEmpty;
      final totalInefficientArea = inefficientFruits.fold<double>(
        0.0,
        (sum, fruit) => sum + (fruit.economicInefficientArea ?? 0.0),
      );

      sections.add(
        _DetailSection(
          title: "Mevali hududlar",
          icon: Icons.eco_outlined,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupedCard(
                context,
                plantation.fruitAreas!
                    .map((fruit) => [
                          _InfoEntry(
                            "Meva",
                            fruit.fruitName ?? "Noma'lum",
                            Icons.eco_outlined,
                          ),
                          if (fruit.varietyName != null)
                            _InfoEntry(
                              "Nav",
                              fruit.varietyName!,
                              Icons.local_florist_outlined,
                            ),
                          if (fruit.rootstockName != null)
                            _InfoEntry(
                              "Podvoy",
                              fruit.rootstockName!,
                              Icons.grass_outlined,
                            ),
                          _InfoEntry(
                            "Maydon",
                            "${_formatNumber(fruit.area)} GA",
                            Icons.square_foot_outlined,
                          ),
                          if (fruit.plantedYear != null)
                            _InfoEntry(
                              "Ekilgan yil",
                              fruit.plantedYear.toString(),
                              Icons.date_range_outlined,
                            ),
                          if (fruit.schema != null && fruit.schema!.isNotEmpty)
                            _InfoEntry(
                              "Ekilish sxemasi",
                              fruit.schema!,
                              Icons.grid_view_outlined,
                            ),
                          if (fruit.kochatSoni != null)
                            _InfoEntry(
                              "Ko'chat soni",
                              fruit.kochatSoni.toString(),
                              Icons.spa_outlined,
                            ),
                        ])
                    .toList(),
              ),
              if (hasInefficientAreas) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildInefficientAreaCard(context, totalInefficientArea),
              ],
            ],
          ),
        ),
      );
    }

    if (plantation.images?.isNotEmpty == true) {
      sections.add(
        _DetailSection(
          title: "Fotogalereya",
          icon: Icons.photo_library_outlined,
          content: _buildImagesCard(context, plantation.images!),
        ),
      );
    }

    if (sections.isEmpty) {
      sections.add(
        _DetailSection(
          title: "Ma'lumotlar",
          icon: Icons.info_outline,
          content: _buildMetricsCard(context, baseEntries),
        ),
      );
    }

    // Add action buttons section
    sections.add(
      _DetailSection(
        title: "Harakatlar",
        icon: Icons.settings_outlined,
        content: _buildActionButtons(context, plantation, mapVm),
      ),
    );

    return sections;
  }

  MapEntry<String, Color> _resolveStatus(
    RelatedPlantation? relatedPlantation,
    EditPlantationModel? editPlantation,
    ColorScheme scheme,
  ) {
    if (editPlantation == null && relatedPlantation == null) {
      return MapEntry("Ma'lumot yo'q", scheme.onSurfaceVariant);
    }

    // Объединяем данные из обоих источников через ||:
    // если ХОТЯ БЫ ОДИН источник подтверждает статус, используем его.
    // Это решает проблему, когда detail API возвращает is_checked: false,
    // а list/map API корректно возвращает is_checked: true.
    final bool isDeleting = editPlantation?.isDeleting == true;
    final bool isRejected = (editPlantation?.isRejected == true) ||
        (relatedPlantation?.isRejected == true);
    final bool isChecked = (editPlantation?.isChecked == true) ||
        (relatedPlantation?.isChecked == true);

    debugPrint('_resolveStatus: isChecked=$isChecked, isRejected=$isRejected, '
        'isDeleting=$isDeleting');

    if (isDeleting) {
      return MapEntry(
          "O'chirish so'rovi yuborilgan", design_colors.AppColors.error);
    }
    if (isRejected) {
      return MapEntry("Rad etilgan", design_colors.AppColors.error);
    }
    if (isChecked) {
      return MapEntry("Tasdiqlangan", design_colors.AppColors.success);
    }
    return MapEntry("Ko'rib chiqilmoqda", design_colors.AppColors.warning);
  }

  Widget _buildMapCard({
    required BuildContext context,
    required EditPlantationModel plantation,
    required PlantationMapViewVm mapVm,
    required MapEntry<String, Color> statusData,
  }) {
    final perimeter = mapVm.currentPlantation == null
        ? null
        : mapVm.calculatePerimeter(mapVm.currentPlantation!.coordinates);

    // Используем chegaraArea из API, если доступно, иначе totalArea
    final chegaraAreaValue = plantation.chegaraArea ?? plantation.totalArea;

    final metrics = <_InfoEntry>[
      _InfoEntry(
        "Holat",
        statusData.key,
        Icons.verified_outlined,
        statusData.value,
      ),
      _InfoEntry(
        "Chegara maydon",
        chegaraAreaValue != null && chegaraAreaValue > 0
            ? "${_formatNumber(chegaraAreaValue)} GA"
            : "${_formatNumber(plantation.totalArea)} GA",
        Icons.landscape_outlined,
      ),
      if (perimeter != null && perimeter > 0)
        _InfoEntry(
          "Perimetr",
          "${perimeter.toStringAsFixed(2)} m",
          Icons.timeline_outlined,
        ),
      if (mapVm.currentPlantation?.coordinates.isNotEmpty ?? false)
        _InfoEntry(
          "Nuqtalar",
          mapVm.currentPlantation!.coordinates.length.toString(),
          Icons.straighten_outlined,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniMap(context, mapVm, statusData),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoGrid(context, metrics),
          // Блок координат убран по запросу пользователя
        ],
      ),
    );
  }

  Widget _buildMiniMap(
    BuildContext context,
    PlantationMapViewVm mapVm,
    MapEntry<String, Color> statusData,
  ) {
    final borderRadius = BorderRadius.circular(AppRadii.card);
    final colorScheme = Theme.of(context).colorScheme;

    if (mapVm.isLoading) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 220,
          color: colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    if (mapVm.errorMessage != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 220,
          color: colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined,
                  size: 36, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: AppSpacing.sm),
              Text(
                mapVm.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: mapVm.loadRelatedPlantations,
                child: const Text("Qayta urinish"),
              ),
            ],
          ),
        ),
      );
    }

    final hasGeometry = mapVm.polygons.isNotEmpty ||
        mapVm.polylines.isNotEmpty ||
        mapVm.markers.isNotEmpty ||
        mapVm.circles.isNotEmpty;

    if (!hasGeometry) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 220,
          color: colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Text(
            "Koordinatalar topilmadi",
            style: AppTypography.bodySmall(context),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: 220,
        child: _MapGestureHandler(
          child: GoogleMap(
            onMapCreated: mapVm.onMapCreated,
            initialCameraPosition: CameraPosition(
              target: mapVm.initialPosition,
              zoom: 15,
            ),
            mapType: MapType.satellite,
            polygons: mapVm.polygons,
            polylines: mapVm.polylines,
            markers: mapVm.markers,
            circles: mapVm.circles,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            liteModeEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
          ),
        ),
      ),
    );
  }

  // Метод _buildCoordinateSection удален по запросу пользователя

  Widget _buildActionButtons(
    BuildContext context,
    EditPlantationModel plantation,
    PlantationMapViewVm mapVm,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // TODO: Disabled — allow editing/deleting even for confirmed plantations
    // final isChecked = plantation.isChecked ?? mapVm.currentPlantation?.isChecked ?? false;
    // if (isChecked) {
    //   return const SizedBox.shrink();
    // }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              if (plantation.id != null) {
                context.go(
                  "${AppRouteNames.home}${AppRouteNames.editPage}",
                  extra: plantation.id,
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text("Tahrirlash"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _handleDelete(context, plantation, mapVm),
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text("O'chirish"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
              ),
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
          ),
        ),
      ],
    );
  }

  void _handleDelete(
    BuildContext context,
    EditPlantationModel plantation,
    PlantationMapViewVm mapVm,
  ) {
    final isChecked =
        plantation.isChecked ?? mapVm.currentPlantation?.isChecked ?? false;

    if (isChecked) {
      // Подтверждённую плантацию удалить нельзя — показываем модальное окно
      _showCannotDeleteDialog(context);
      return;
    }

    // Не подтверждённая — показываем диалог с комментарием
    _showDeleteWithReasonDialog(context, plantation);
  }

  /// Модальное окно: удалить нельзя (is_checked == true)
  void _showCannotDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.block, size: 48),
        iconColor: Theme.of(context).colorScheme.error,
        title: const Text("O'chirib bo'lmaydi"),
        content: const Text(
          "Tasdiqlangan plantatsiyani o'chirib bo'lmaydi. "
          "Iltimos, administrator bilan bog'laning.",
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tushunarli"),
          ),
        ],
      ),
    );
  }

  /// Диалог удаления с комментарием (is_checked == false)
  void _showDeleteWithReasonDialog(
    BuildContext context,
    EditPlantationModel plantation,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DeleteConfirmationDialog(
          onConfirm: (reason) async {
            Navigator.of(dialogContext).pop();
            if (!context.mounted) return;
            // Подтверждение через блокировку устройства
            final confirmed =
                await BiometricService.instance.confirmCriticalAction(
              context: context,
              reason: "Plantatsiyani o'chirish uchun tasdiqlang",
            );
            if (!confirmed) return;
            if (!context.mounted) return;
            _deletePlantationWithReason(context, plantation.id, reason);
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  Future<void> _deletePlantationWithReason(
    BuildContext context,
    int? plantationId,
    String reason,
  ) async {
    if (plantationId == null) return;

    try {
      final vm = ref.read(homePageVM.notifier);

      final result = await vm.deletePlantationPermanently(
        id: plantationId,
        reason: reason,
      );

      if (context.mounted) {
        debugPrint("Delete: Result: $result, deletMessage: ${vm.deletMessage}");
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.deletMessage ??
                  "O'chirish so'rovi moderatsiyaga yuborildi"),
              backgroundColor: design_colors.AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          if (context.mounted) {
            context.pop();
          }
        } else {
          final errorMessage =
              vm.deletMessage ?? "O'chirishda xatolik yuz berdi";
          debugPrint("Delete: Showing error message: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: design_colors.AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xatolik: $e"),
            backgroundColor: design_colors.AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Метод _buildCoordinateChip удален по запросу пользователя

  /// Хелпер для создания карточки с тёмным стилем (замена AppCardFilled)
  Widget _buildFilledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: context.colors.cardBorder,
        boxShadow: context.colors.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildMetricsCard(
    BuildContext context,
    List<_InfoEntry> entries,
  ) {
    if (entries.isEmpty) {
      return _buildFilledCard(
        child: Text(
          "Ma'lumot yo'q",
          style: AppTypography.bodySmall(context).copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    return _buildFilledCard(
      child: _buildInfoGrid(context, entries),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context,
    List<List<_InfoEntry>> groups,
  ) {
    if (groups.isEmpty) {
      return _buildFilledCard(
        child: Text(
          "Ma'lumot yo'q",
          style: AppTypography.bodySmall(context).copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    return _buildFilledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groups.asMap().entries.map((entry) {
            final index = entry.key;
            final items = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  Divider(height: 32, color: context.colors.border),
                _buildInfoGrid(context, items),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImagesCard(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return _buildFilledCard(
        child: Text(
          "Rasmlar mavjud emas",
          style: AppTypography.bodySmall(context).copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    return _buildFilledCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          return Semantics(
            button: true,
            label: "Rasmni ochish",
            child: GestureDetector(
              onTap: () => _showImageDialog(context, imageUrl),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: context.colors.isDark
                      ? Border.all(color: context.colors.border, width: 1)
                      : null,
                  boxShadow:
                      context.colors.isDark ? null : context.colors.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm - 1),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return Container(
                        color: context.colors.surface,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            design_colors.AppColors.accentGreen,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: context.colors.surface,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: context.colors.textSecondary,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInefficientAreaCard(
    BuildContext context,
    double totalInefficientArea,
  ) {
    return _buildFilledCard(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: design_colors.AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: design_colors.AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: design_colors.AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Iqtisodiy samarasiz maydon",
                    style: AppTypography.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: design_colors.AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "${_formatNumber(totalInefficientArea)} GA",
                    style: AppTypography.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: design_colors.AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, List<_InfoEntry> entries) {
    final effectiveEntries =
        entries.where((entry) => entry.value.trim().isNotEmpty).toList();

    if (effectiveEntries.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSpacing.md;
        final availableWidth = constraints.maxWidth;

        // Минимальная ширина плитки — дальше считаем, сколько таких
        // плиток реально влезает в строку (а не только "1 или 2"), чтобы
        // на широких экранах строка не оставалась пустой на 2/3 ширины.
        const minTileWidth = 140.0;
        final maxColumns = effectiveEntries.length.clamp(1, 4);
        var columns = ((availableWidth + spacing) / (minTileWidth + spacing))
            .floor()
            .clamp(1, maxColumns);

        final tileWidth = (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: effectiveEntries.map((entry) {
            return SizedBox(
              width: tileWidth,
              child: _InfoTile(entry: entry),
            );
          }).toList(),
        );
      },
    );
  }

  String? _resolveTypeChoiceLabel(EditPlantationModel plantation) {
    final typeChoice = plantation.types?.typeChoice;
    if (typeChoice == null) return null;

    switch (plantation.plantationType ?? plantation.types?.plantationType) {
      case 1:
        return AppLocalizedMaps.bogTypes[typeChoice];
      case 2:
        return AppLocalizedMaps.uzumTypes[typeChoice];
      case 3:
        return AppLocalizedMaps.issiqxonaTypes[typeChoice];
      default:
        return null;
    }
  }

  String? _resolveSubtypeLabel(EditPlantationModel plantation) {
    final subtype = plantation.types?.subtype;
    if (subtype == null) return null;
    if ((plantation.plantationType ?? plantation.types?.plantationType) == 1) {
      return AppLocalizedMaps.bogSubtypes[subtype];
    }
    return null;
  }

  String _resolveTrellisType(int? trellisType) {
    switch (trellisType) {
      case 1:
        return "Temir shpaller";
      case 2:
        return "Beton shpaller";
      default:
        return "Noma'lum";
    }
  }

  String _resolveReservoirType(int? type) {
    switch (type) {
      case 1:
        return "Beton suv havzasi";
      case 2:
        return "Qoplamali suv havzasi";
      default:
        return "Noma'lum";
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) {
                  return Container(
                    width: 240,
                    height: 240,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppRadii.modal),
                    ),
                    child: const CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppRadii.modal),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image,
                            size: 48, color: Colors.white),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Rasm yuklanmadi",
                          style: AppTypography.bodySmall(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoEntry {
  final String label;
  final String value;
  final IconData? icon;
  final Color? statusColor;

  const _InfoEntry(
    this.label,
    this.value, [
    this.icon,
    this.statusColor,
  ]);
}

class _InfoTile extends StatelessWidget {
  final _InfoEntry entry;

  const _InfoTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final accentColor =
        entry.statusColor ?? design_colors.AppColors.accentGreen;
    final backgroundColor = context.colors.surfaceElevated;
    final labelStyle = AppTypography.caption(context).copyWith(
      fontWeight: FontWeight.w500,
      color: context.colors.textSecondary,
    );
    final valueStyle = AppTypography.bodyLarge(context).copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: entry.statusColor ?? context.colors.textPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:
            context.colors.isDark ? backgroundColor : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: context.colors.isDark
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(entry.icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  entry.label,
                  style: labelStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            entry.value,
            style: valueStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MapGestureHandler extends StatefulWidget {
  final Widget child;

  const _MapGestureHandler({required this.child});

  @override
  State<_MapGestureHandler> createState() => _MapGestureHandlerState();
}

class _MapGestureHandlerState extends State<_MapGestureHandler> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        // Блокируем вертикальные жесты, чтобы они не передавались родительскому ScrollView
      },
      onVerticalDragUpdate: (_) {
        // Блокируем вертикальные жесты
      },
      onVerticalDragEnd: (_) {
        // Блокируем вертикальные жесты
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

// Вспомогательный класс для отображения комментариев модерации
class _ModerationCommentDisplay {
  final int? id;
  final String text;
  final String? timestamp;
  final String? author;

  _ModerationCommentDisplay({
    this.id,
    required this.text,
    this.timestamp,
    this.author,
  });
}
