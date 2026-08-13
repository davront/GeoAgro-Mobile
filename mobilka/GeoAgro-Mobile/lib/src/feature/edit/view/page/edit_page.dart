import 'package:agro_employee_public/src/core/widgets/custom_app_bar_widget.dart';
import 'package:agro_employee_public/src/core/widgets/main_button.dart';
import 'package:agro_employee_public/src/core/widgets/mian_text.dart';
import 'package:agro_employee_public/src/feature/detail_page/view/widgets/detail_dropdown_widget.dart';
import 'package:agro_employee_public/src/feature/edit/view/widgets/images_upload_widget.dart';
import 'package:agro_employee_public/src/feature/edit/view/widget/edit_subsidy_bottom_shit.dart';
import 'package:agro_employee_public/src/feature/edit/view/widget/edit_subsidy_list.dart';
import 'package:agro_employee_public/src/feature/edit/view/widget/updeta_create_time.dart';
import 'package:agro_employee_public/src/feature/edit/vm/edit_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../../localization/app_strings.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/utils/utils.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/radii.dart';
import '../../../../../design_system/tokens/typography.dart';
import '../../../detail_page/view/widgets/border_widget.dart';
import '../../../detail_page/view/widgets/detail_text_fild_widget.dart';
import '../../../detail_page/view/widgets/productivity_indicator_widget.dart';
import '../../../detail_page/view/widgets/subsidiya_button.dart';
import '../../../detail_page/view/widgets/switch_card_widget.dart';
import '../widget/edit_fruit_area.dart';
import '../widget/edit_fruit_button.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

class EditPage extends ConsumerStatefulWidget {
  final int id;
  const EditPage({super.key, required this.id});

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage>
    with WidgetsBindingObserver {
  bool _hasLoadedData = false;

  // Тот же паттерн, что и в DetailPage: маппинг field_name (реально
  // подтверждённые бэком через пробные запросы) → GlobalKey для
  // автоскролла+подсветки конкретного инпута.
  final GlobalKey _plantationTypeKey = GlobalKey();
  final GlobalKey _landTypeKey = GlobalKey();

  void _scrollToErroredField(String? fieldName) {
    final key = switch (fieldName) {
      'plantation_type' => _plantationTypeKey,
      'land_type' => _landTypeKey,
      _ => null,
    };
    if (key?.currentContext == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key!.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final id = widget.id;
      ref.read(editVm).saveDraftSnapshot(ref, id);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Загружаем данные только один раз при первой инициализации
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = ref.read(editVm);
        vm.getPlantationDetail(ref, widget.id);
        // Загружаем информацию о пользователе (isSpecialUser)
        vm.loadUserInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = ref.watch(editVm);
    final isTomchi = ref.watch(switchTomchi);
    final isFertile = ref.watch(switchIsFertile);
    final isTrellis = ref.watch(switchTrellis);
    final isTrellisTemit = ref.watch(switchTrellisTemir);
    final isTrellisBeton = ref.watch(switchTrellisBeton);
    final isReservoirs = ref.watch(switchReservoirs);
    final isInvestmentXorijiy = ref.watch(switchInvestmentXorjiy);
    final isInvestmentMahhalliy = ref.watch(switchInvestmentMahhalliy);

    // Всегда тёмная тема

    if (edit.isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomAppBarWidget(
            title: "Malumotlar yuklanmoqda...", canPop: true),
        body: Center(
          child: Lottie.asset(
            'assets/lotties/search.json',
            width: 300.w,
            height: 300.h,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    if (edit.errorMessage != null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomAppBarWidget(title: "Xatolik !!!", canPop: true),
        body: ErrorStateWidget(
          errorMessage: edit.errorMessage ?? "Kutilmagan Javob qaytdi",
          onTap: () => edit.getPlantationDetail(ref, widget.id),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // Восстанавливаем оригинальный список изображений при выходе
          edit.restoreOriginalImages();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBarWidget(title: "Tahrirlash", canPop: true),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.getMaxContentWidth(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 18.w,
                right: 18.w,
                top: 10.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
              ),
              child: Padding(
                padding: REdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MainText(text: "Bog`ning barpo etilgan vaqti"),
                    UpdetaCreateTime(
                      serverDate: edit.plantationModel.gardenEstablishedYear !=
                              null
                          ? DateTime(edit.plantationModel.gardenEstablishedYear!
                              .toInt())
                          : null,
                      setSelectedDate: (date) {
                        ref.read(editVm).setSelectedDate(date);
                      },
                    ),
                    DropdownWithLabel(
                        key: _plantationTypeKey,
                        label: "Plantatsiya turi",
                        items: AppLocalizedMaps.plantationTypes,
                        hint: "plantatsiya turi",
                        selectedValue: edit.selectedPlantationType,
                        hasError: edit.erroredField == 'plantation_type',
                        onChanged: (value) {
                          edit.setPlantationType(value);
                        }),
                    if (edit.selectedPlantationType == 1)
                      DropdownWithLabel(
                        items: AppLocalizedMaps.bogTypes,
                        hint: "bog' turi tanlanmagan",
                        selectedValue: edit.selectedBogType,
                        onChanged: (value) {
                          edit.setBogType(value);
                        },
                      ),
                    if (edit.selectedPlantationType == 1 &&
                        edit.selectedBogType == 1)
                      DropdownWithLabel(
                        items: AppLocalizedMaps.bogSubtypes,
                        hint: "intensiv bog` turi tanlanmagan",
                        selectedValue: edit.selectedBogSubtype,
                        onChanged: (value) {
                          edit.setBogSubtype(value);
                        },
                      ),
                    // 2 = Uzumzor, 3 = Issiqxona (per setup.dart)
                    if (edit.selectedPlantationType == 3)
                      DropdownWithLabel(
                        hint: "issiqxona turi tanlanmagan",
                        items: AppLocalizedMaps.issiqxonaTypes,
                        selectedValue: edit.selectedIssiqxonaType,
                        onChanged: (value) {
                          edit.setIssiqxonaType(value);
                        },
                      ),
                    if (edit.selectedPlantationType == 2)
                      DropdownWithLabel(
                        hint: "uzumzor turi tanlanmagan",
                        items: AppLocalizedMaps.uzumTypes,
                        selectedValue: edit.selectedUzumType,
                        onChanged: (value) {
                          edit.setUzumType(value);
                        },
                      ),
                    DropdownWithLabel(
                      key: _landTypeKey,
                      label: "Yer turi",
                      hint: "yer turi tanlanmagan",
                      items: AppLocalizedMaps.yerTuri,
                      selectedValue: edit.selectedYerTuri,
                      hasError: edit.erroredField == 'land_type',
                      onChanged: edit.setYerTuri,
                    ),
                    SizedBox(height: 10.h),
                    ProductivityIndicator(
                      value: edit.unumdorlikValue,
                      onChanged: (newValue) {
                        edit.setUnumdorlikValue(newValue);
                      },
                    ),
                    CustomTextFieldWithLabel(
                      controller: edit.notUsableArea,
                      onTextChanged: (v) =>
                          edit.setNotUsableArea(v.replaceAll('-', '')),
                      hintText: "yaroqsiz maydon kiritilmagan",
                      label: "Foydalanishga yaroqsiz maydon",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                      maxLength: 10,
                    ),
                    CustomTextFieldWithLabel(
                      controller: edit.emptyArea,
                      onTextChanged: (v) =>
                          edit.setEmptyArea(v.replaceAll('-', '')),
                      hintText: "ochiq maydon kiritilmagan",
                      label: "Ochiq maydon",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                      maxLength: 10,
                    ),
                    SizedBox(height: 16.h),
                    MainText(text: "Kontur raqamlari"),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: edit.konturInputController,
                            style: AppTypography.input(context).copyWith(
                              fontSize: 14.sp,
                              color: context.colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "kontur raqamini kiriting",
                              filled: true,
                              fillColor: context.colors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.inputPaddingHorizontal,
                                vertical: AppSpacing.inputPaddingVertical,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.input),
                                borderSide: BorderSide(
                                  color: context.colors.isDark
                                      ? context.colors.border
                                      : context.colors.border
                                          .withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.input),
                                borderSide: BorderSide(
                                  color: design_colors.AppColors.accentGreen,
                                  width: 1.6,
                                ),
                              ),
                              hintStyle:
                                  AppTypography.bodySmall(context).copyWith(
                                fontSize: 14.sp,
                                color: context.colors.textSecondary,
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) => edit.addKonturNumber(),
                            onTap: () {
                              // Предотвращаем перезагрузку при фокусе на поле
                              // Просто фокусируемся на поле без дополнительных действий
                            },
                            enableInteractiveSelection: true,
                            readOnly: false,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: edit.addKonturNumber,
                            child: const Text("Qo'shish"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < edit.konturNumbers.length; i++)
                          Chip(
                            label: Text(edit.konturNumbers[i]),
                            onDeleted: () => edit.removeKonturAt(i),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Xorijiy invitsitsiya",
                      switchValue: isInvestmentXorijiy,
                      onChanged: (value) {
                        ref.read(switchInvestmentXorjiy.notifier).state = value;
                        if (!value) {
                          edit.investmentXorijiyAmount.clear();
                          edit.setInvestmentXorijiyAmount("");
                        }
                      },
                      childWidgets: [
                        SizedBox(height: 10.h),
                        CustomTextFieldWithLabel(
                          controller: edit.investmentXorijiyAmount,
                          onTextChanged: edit.setInvestmentXorijiyAmount,
                          hintText: "Xorijiy invitsitsiya miqdori",
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    CustomSwitchCard(
                      label: "Mahalliy invitsitsiya",
                      switchValue: isInvestmentMahhalliy,
                      onChanged: (value) {
                        ref.read(switchInvestmentMahhalliy.notifier).state =
                            value;
                        if (!value) {
                          edit.investmentMahhalliyAmount.clear();
                          edit.setInvestmentMahhalliyAmount("");
                        }
                      },
                      childWidgets: [
                        SizedBox(height: 10.h),
                        CustomTextFieldWithLabel(
                          controller: edit.investmentMahhalliyAmount,
                          onTextChanged: edit.setInvestmentMahhalliyAmount,
                          hintText: "Mahalliy invitsitsiya miqdori",
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Tomchilab sug`oriladimi ?",
                      switchValue: isTomchi,
                      onChanged: (value) {
                        ref.read(switchTomchi.notifier).state = value;
                        if (!value) {
                          edit.irrigationAreaController.clear();
                          edit.setIrrigationArea("");
                          edit.irrigationSystemsCount.clear();
                          edit.setIrrigationSystemsCount("");
                        }
                      },
                      childWidgets: [
                        BorderWidget(
                          children: [
                            Padding(
                              padding: REdgeInsets.only(top: 10),
                              child: CustomTextFieldWithLabel(
                                controller: edit.irrigationAreaController,
                                onTextChanged: edit.setIrrigationArea,
                                hintText:
                                    "Tomchilab sug‘oruladigan yer maydoni",
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'))
                                ],
                                maxLength: 10,
                              ),
                            ),
                            Padding(
                              padding: REdgeInsets.only(top: 10),
                              child: CustomTextFieldWithLabel(
                                controller: edit.irrigationSystemsCount,
                                onTextChanged: edit.setIrrigationSystemsCount,
                                hintText: "Tomchilab sug‘orish tizimlari soni",
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLength: 6,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Subsidiya ajratilganmi ?",
                      switchValue: ref.watch(switchSubsidiya),
                      onChanged: (value) {
                        ref.read(switchSubsidiya.notifier).state = value;
                      },
                      childWidgets: [
                        SubsidiyaButton(
                            viewModel: editVm,
                            widget: EditSubsidyBottomShit(viewModel: edit)),
                        SizedBox(height: 10.h),
                        EditSubsidyList(
                          selectedList: edit.selectedEditSubsidy,
                          removeAt: (index) => edit.removeSubsidy(index),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Shpaller o`rnatilganmi ?",
                      switchValue: isTrellis,
                      onChanged: (value) {
                        ref.read(switchTrellis.notifier).state = value;
                        if (!value) {
                          ref.read(switchTrellisTemir.notifier).state = false;
                          ref.read(switchTrellisBeton.notifier).state = false;
                          edit.trellisTemirInstalledArea.clear();
                          edit.setTrellisTemirInstalledArea("");
                          edit.trellisTemirCount.clear();
                          edit.setTrellisTemirCount("");
                          edit.trellisBetonInstalledArea.clear();
                          edit.setTrellisBetonInstalledArea("");
                          edit.trellisBetonCount.clear();
                          edit.setTrellisBetonCount("");
                        }
                      },
                      childWidgets: [
                        BorderWidget(
                          children: [
                            CustomSwitchCard(
                              label: "Temir shpaller",
                              switchValue: isTrellisTemit,
                              onChanged: (value) {
                                ref.read(switchTrellisTemir.notifier).state =
                                    value;
                              },
                              childWidgets: [
                                Padding(
                                  padding: REdgeInsets.only(top: 10),
                                  child: CustomTextFieldWithLabel(
                                    controller: edit.trellisTemirInstalledArea,
                                    onTextChanged:
                                        edit.setTrellisTemirInstalledArea,
                                    hintText:
                                        "temir shpaller o'rnatilgan maydon",
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.,]'))
                                    ],
                                    maxLength: 10,
                                  ),
                                ),
                                Padding(
                                  padding: REdgeInsets.only(top: 10),
                                  child: CustomTextFieldWithLabel(
                                    controller: edit.trellisTemirCount,
                                    onTextChanged: edit.setTrellisTemirCount,
                                    hintText: "o'rnatilgan temir shpaller soni",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLength: 6,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            CustomSwitchCard(
                              label: "Beton shpaller",
                              switchValue: isTrellisBeton,
                              onChanged: (value) {
                                ref.read(switchTrellisBeton.notifier).state =
                                    value;
                              },
                              childWidgets: [
                                Padding(
                                  padding: REdgeInsets.only(top: 10),
                                  child: CustomTextFieldWithLabel(
                                    controller: edit.trellisBetonInstalledArea,
                                    onTextChanged:
                                        edit.setTrellisBetonInstalledArea,
                                    hintText:
                                        "beton shpaller o'rnatilgan maydon",
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.,]'))
                                    ],
                                    maxLength: 10,
                                  ),
                                ),
                                Padding(
                                  padding: REdgeInsets.only(top: 10),
                                  child: CustomTextFieldWithLabel(
                                    controller: edit.trellisBetonCount,
                                    onTextChanged: edit.setTrellisBetonCount,
                                    hintText: "o'rnatilgan beton shpaller soni",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLength: 6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Unumdormi ?",
                      switchValue: isFertile,
                      onChanged: (value) {
                        ref.read(switchIsFertile.notifier).state = value;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomSwitchCard(
                      label: "Suv xavzasi turi ?",
                      switchValue: isReservoirs,
                      onChanged: (value) {
                        ref.read(switchReservoirs.notifier).state = value;
                        if (!value) {
                          ref.read(switchReservoirsBeton.notifier).state =
                              false;
                          ref.read(switchReservoirsQoplamali.notifier).state =
                              false;
                          // Очищаем все контроллеры резервуаров
                          for (final controller
                              in edit.reservoirsBetonliVolumes) {
                            controller.clear();
                          }
                          for (final controller
                              in edit.reservoirsQoplamaliVolumes) {
                            controller.clear();
                          }
                          // Оставляем только основные контроллеры
                          edit.reservoirsBetonliVolumes.clear();
                          edit.reservoirsQoplamaliVolumes.clear();
                          edit.initializeReservoirs();
                        }
                      },
                      childWidgets: [
                        BorderWidget(children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final edit = ref.watch(editVm);
                              final isReservoirsBeton =
                                  ref.watch(switchReservoirsBeton);
                              return CustomSwitchCard(
                                label: "Betonli suv xavzasi",
                                switchValue: isReservoirsBeton,
                                onChanged: (value) {
                                  ref
                                      .read(switchReservoirsBeton.notifier)
                                      .state = value;
                                  if (value &&
                                      edit.reservoirsBetonliVolumes.isEmpty) {
                                    edit.initializeReservoirs();
                                  }
                                },
                                childWidgets: [
                                  if (isReservoirsBeton) ...[
                                    ...List.generate(
                                        edit.reservoirsBetonliVolumes.length,
                                        (index) {
                                      return Padding(
                                        padding: REdgeInsets.only(
                                            top: index == 0 ? 10 : 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFieldWithLabel(
                                                controller:
                                                    edit.reservoirsBetonliVolumes[
                                                        index],
                                                onTextChanged: (_) {},
                                                hintText:
                                                    "suv havzasi hajmi m³",
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.,]'))
                                                ],
                                                maxLength: 10,
                                              ),
                                            ),
                                            if (edit.reservoirsBetonliVolumes
                                                    .length >
                                                1)
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    edit.removeBetonReservoir(
                                                        index),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                    Padding(
                                      padding: REdgeInsets.only(top: 10),
                                      child: TextButton.icon(
                                        onPressed: edit.addBetonReservoir,
                                        icon: const Icon(Icons.add),
                                        label: const Text("Yana qo'shish"),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 10.h),
                          Consumer(
                            builder: (context, ref, child) {
                              final edit = ref.watch(editVm);
                              final isReservoirsQoplamali =
                                  ref.watch(switchReservoirsQoplamali);
                              return CustomSwitchCard(
                                label: "Qoplamali suv xavzasi",
                                switchValue: isReservoirsQoplamali,
                                onChanged: (value) {
                                  ref
                                      .read(switchReservoirsQoplamali.notifier)
                                      .state = value;
                                  if (value &&
                                      edit.reservoirsQoplamaliVolumes.isEmpty) {
                                    edit.initializeReservoirs();
                                  }
                                },
                                childWidgets: [
                                  if (isReservoirsQoplamali) ...[
                                    ...List.generate(
                                        edit.reservoirsQoplamaliVolumes.length,
                                        (index) {
                                      return Padding(
                                        padding: REdgeInsets.only(
                                            top: index == 0 ? 10 : 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFieldWithLabel(
                                                controller:
                                                    edit.reservoirsQoplamaliVolumes[
                                                        index],
                                                onTextChanged: (_) {},
                                                hintText:
                                                    "suv havzasi hajmi m³",
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.,]'))
                                                ],
                                                maxLength: 10,
                                              ),
                                            ),
                                            if (edit.reservoirsQoplamaliVolumes
                                                    .length >
                                                1)
                                              Padding(
                                                padding:
                                                    REdgeInsets.only(left: 8),
                                                child: IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red),
                                                  onPressed: () => edit
                                                      .removeQoplamaliReservoir(
                                                          index),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                    Padding(
                                      padding: REdgeInsets.only(top: 10),
                                      child: TextButton.icon(
                                        onPressed: edit.addQoplamaliReservoir,
                                        icon: const Icon(Icons.add),
                                        label: const Text("Yana qo'shish"),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ])
                      ],
                    ),
                    SizedBox(height: 16.h),
                    EditFruitButton(),
                    EditFruitArea(
                      selectedDetails: edit.selectedDetails,
                      removeDetailAt: (index) => edit.removeDetailAt(index),
                      editDetailAt: (index, ref, context) =>
                          edit.editDetailAt(index, ref, context),
                    ),
                    MainText(text: "Bog`ning rasmlarini qayta yuklang"),
                    SizedBox(height: 8.h),
                    // TODO: Photo requirements indicator disabled for edit page
                    // Photo count validation is only required on create page
                    SizedBox(height: 12.h),
                    Consumer(
                      builder: (context, ref, child) {
                        final existingCount = edit.existingImages.length;
                        final required =
                            edit.calculateMinimumPhotosRequired(ref);
                        final base = required > 4 ? required : 4;
                        // Count how many slots [0..upper) actually hold a photo
                        // (existing or freshly uploaded). Always render one
                        // extra empty slot beyond the last filled one so the
                        // user can always add more — no hard cap at 4.
                        int filled = 0;
                        final upper =
                            existingCount > base ? existingCount : base;
                        for (int i = 0; i < upper; i++) {
                          final hasExisting = i < existingCount;
                          final hasUploaded = edit.getImageFile(i) != null;
                          if (hasExisting || hasUploaded) filled++;
                        }
                        final itemCount = [
                          base,
                          existingCount,
                          filled + 1,
                        ].reduce((a, b) => a > b ? a : b);
                        return EditImageUploadListWidget(
                          existingImages: edit.existingImages,
                          showImagePicker: edit.showImagePicker,
                          getImageFile: edit.getImageFile,
                          removeExistingImage: edit.removeExistingImage,
                          isUploadingAt: edit.isUploadingAt,
                          itemCount: itemCount,
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Отображение общей площади после загрузки изображений
                    Consumer(
                      builder: (context, ref, child) {
                        return Container(
                          padding: EdgeInsets.all(12.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Umumiy maydon:",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                "${edit.getTotalArea(ref).toStringAsFixed(1)} GA",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    MainText(text: "Izohlar (ixtiyoriy)"),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: edit.commentsController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      inputFormatters: [
                        // Разрешаем буквы (латиница, кириллица, узбекские символы), цифры, пробелы и основные знаки препинания
                        // Запрещаем специальные символы: < > { } [ ] | \ / & % $ # @ * ^ ~ ` и другие
                        FilteringTextInputFormatter.allow(RegExp(
                            r"[a-zA-Zа-яА-ЯёЁўЎқҚғҒҳҲ0-9\s.,!?:;\-''" "()]")),
                      ],
                      style: AppTypography.input(context).copyWith(
                        fontSize: 14.sp,
                        color: context.colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Izoh kiriting (qo'shiladi yangilangandan keyin)",
                        filled: true,
                        fillColor: context.colors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.inputPaddingHorizontal,
                          vertical: AppSpacing.inputPaddingVertical,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: BorderSide(
                            color: context.colors.isDark
                                ? context.colors.border
                                : context.colors.border.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: BorderSide(
                            color: design_colors.AppColors.accentGreen,
                            width: 1.6,
                          ),
                        ),
                        hintStyle: AppTypography.bodySmall(context).copyWith(
                          fontSize: 14.sp,
                          color: context.colors.textSecondary,
                        ),
                        isDense: true,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    MainButton(
                      text: "Yangilanishni yuklash",
                      isLoading: edit.isSaving,
                      onTap: () async {
                        // Защита от множественных нажатий
                        if (edit.isSaving) {
                          return;
                        }

                        final validation = edit.validateFields(ref);
                        if (validation != null) {
                          if (context.mounted) {
                            Utils.fireTopSnackBar(validation,
                                design_colors.AppColors.error, context);
                          }
                          return;
                        }

                        if (!context.mounted) return;

                        var allTrue = await edit.saveAllChanges(ref, widget.id);
                        if (allTrue && context.mounted) {
                          final wasQueued = edit.errorMessage != null;
                          Utils.fireTopSnackBar(
                              edit.errorMessage ??
                                  "Ma'lumotlar muvaffaqiyatli yangilandi",
                              design_colors.AppColors.accentGreen,
                              context,
                              duration: wasQueued
                                  ? const Duration(seconds: 5)
                                  : const Duration(seconds: 2));
                          context.go("/");
                        } else {
                          if (context.mounted && edit.errorMessage != null) {
                            Utils.fireTopSnackBar(edit.errorMessage!,
                                design_colors.AppColors.error, context);
                            _scrollToErroredField(edit.erroredField);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
