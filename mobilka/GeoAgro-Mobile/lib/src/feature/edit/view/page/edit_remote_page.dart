// Удалённое редактирование плантации — только административные поля,
// без GPS-проверки. См.
// docs/superpowers/specs/2026-08-13-remote-edit-design.md
//
// Не дублирует EditVM — читает/пишет тот же provider, что и EditPage.
// В дереве этого экрана физически нет виджетов для площади/типа
// земли/состава насаждений/фото/tomchi/шпалер/резервуаров — юзер не
// может их изменить отсюда, даже случайно.
import 'package:agro_employee_public/src/core/widgets/custom_app_bar_widget.dart';
import 'package:agro_employee_public/src/core/widgets/main_button.dart';
import 'package:agro_employee_public/src/core/widgets/mian_text.dart';
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
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/doc_file_row.dart';
import '../../../../core/utils/utils.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/radii.dart';
import '../../../../../design_system/tokens/typography.dart';
import '../../../detail_page/view/widgets/created_time_widget.dart';
import '../../../detail_page/view/widgets/detail_text_fild_widget.dart';
import '../../../detail_page/view/widgets/subsidiya_button.dart';
import '../../../detail_page/view/widgets/switch_card_widget.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

class EditRemotePage extends ConsumerStatefulWidget {
  final int id;
  const EditRemotePage({super.key, required this.id});

  @override
  ConsumerState<EditRemotePage> createState() => _EditRemotePageState();
}

class _EditRemotePageState extends ConsumerState<EditRemotePage> {
  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getPlantationDetail перезагружает EditVM детали заново при каждом
    // открытии — если юзер до этого сохранил на joyida-экране того же id,
    // remote-экран не унаследует stale state, а подтянет свежее.
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = ref.read(editVm);
        vm.getPlantationDetail(ref, widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = ref.watch(editVm);
    final isInvestmentXorijiy = ref.watch(switchInvestmentXorjiy);
    final isInvestmentMahhalliy = ref.watch(switchInvestmentMahhalliy);

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

    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBarWidget(title: "Tahrirlash (masofadan)", canPop: true),
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
                  Container(
                    width: double.infinity,
                    padding: REdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color:
                          design_colors.AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(
                          color: design_colors.AppColors.info
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "Bu ekranda faqat ma'muriy ma'lumotlar (subsidiya, "
                      "investitsiya, hujjatlar) tahrirlanadi. Maydon, tur, "
                      "rasmlar — joyida turib tahrirlash orqali o'zgartiriladi.",
                      style: AppTypography.bodyMedium(context)
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                  MainText(text: "Bog`ning barpo etilgan vaqti"),
                  UpdetaCreateTime(
                    serverDate: edit.plantationModel.gardenEstablishedYear !=
                            null
                        ? DateTime(
                            edit.plantationModel.gardenEstablishedYear!.toInt())
                        : null,
                    setSelectedDate: (date) {
                      ref.read(editVm).setSelectedDate(date);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: REdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(
                        color: context.colors.border
                            .withValues(alpha: context.colors.isDark ? 1 : 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MainText(text: "Shartnoma va qaror hujjatlari"),
                        SizedBox(height: 12.h),
                        CustomTextFieldWithLabel(
                          controller: edit.dealNumberController,
                          onTextChanged: (_) {},
                          hintText: "shartnoma raqami kiritilmagan",
                          label: "Shartnoma raqami",
                        ),
                        SizedBox(height: 8.h),
                        CreatedTime(
                          selectedDate: edit.dealDate,
                          setSelectedDate: edit.setDealDate,
                        ),
                        SizedBox(height: 8.h),
                        DocFileRow(
                          label: "Shartnoma fayli (PDF)",
                          fileUrl: edit.plantationModel.dealFile,
                          isUploading: edit.isUploadingDealFile,
                          onTap: () async {
                            final error =
                                await edit.pickAndUploadDocFile(isDeal: true);
                            if (error != null && context.mounted) {
                              Utils.fireTopSnackBar(error,
                                  design_colors.AppColors.error, context);
                            }
                          },
                        ),
                        SizedBox(height: 16.h),
                        Divider(color: context.colors.border),
                        SizedBox(height: 4.h),
                        CustomTextFieldWithLabel(
                          controller: edit.resolutionNumberController,
                          onTextChanged: (_) {},
                          hintText: "qaror raqami kiritilmagan",
                          label: "Qaror raqami",
                        ),
                        SizedBox(height: 8.h),
                        CreatedTime(
                          selectedDate: edit.resolutionDate,
                          setSelectedDate: edit.setResolutionDate,
                        ),
                        SizedBox(height: 8.h),
                        DocFileRow(
                          label: "Qaror fayli (PDF)",
                          fileUrl: edit.plantationModel.resolutionFile,
                          isUploading: edit.isUploadingResolutionFile,
                          onTap: () async {
                            final error =
                                await edit.pickAndUploadDocFile(isDeal: false);
                            if (error != null && context.mounted) {
                              Utils.fireTopSnackBar(error,
                                  design_colors.AppColors.error, context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
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
                    label: "Unumdormi ?",
                    switchValue: ref.watch(switchIsFertile),
                    onChanged: (value) {
                      ref.read(switchIsFertile.notifier).state = value;
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
                      if (edit.isSaving) return;

                      final validation = edit.validateRemoteFields(ref);
                      if (validation != null) {
                        if (context.mounted) {
                          Utils.fireTopSnackBar(validation,
                              design_colors.AppColors.error, context);
                        }
                        return;
                      }

                      final ok =
                          await edit.editPlantationRemote(ref, widget.id);
                      if (!context.mounted) return;
                      if (ok) {
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
                      } else if (edit.errorMessage != null) {
                        Utils.fireTopSnackBar(edit.errorMessage!,
                            design_colors.AppColors.error, context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
