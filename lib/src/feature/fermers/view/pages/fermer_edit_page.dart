import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../vm/fermer_edit_vm.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/tools/uzbek_phone_formatter.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final fermerEditPageVM =
    ChangeNotifierProvider.autoDispose.family<FermerEditVm, int>((ref, id) {
  return FermerEditVm(farmerId: id);
});

class FermerEditPage extends ConsumerStatefulWidget {
  final int farmerId;

  const FermerEditPage({super.key, required this.farmerId});

  @override
  ConsumerState<FermerEditPage> createState() => _FermerEditPageState();
}

class _FermerEditPageState extends ConsumerState<FermerEditPage> {
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(fermerEditPageVM(widget.farmerId));

    if (vm.isLoadingInitial) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: const CustomAppBarWidget(
            title: "Fermerni tahrirlash", canPop: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.loadError != null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: const CustomAppBarWidget(
            title: "Fermerni tahrirlash", canPop: true),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              vm.loadError!,
              style: TextStyle(color: context.colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar:
          const CustomAppBarWidget(title: "Fermerni tahrirlash", canPop: true),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.getMaxContentWidth(context),
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: context.colors.cardBorder,
                  boxShadow: context.colors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: "INN",
                      controller: vm.inn,
                      // readOnly, не enabled:false — TextField(enabled: false)
                      // отключает весь InputDecorator вместе с suffixIcon,
                      // из-за чего кнопка поиска переставала нажиматься.
                      readOnly: true,
                      isRequired: true,
                      errorText: vm.orgInfoError,
                      keyboardType: TextInputType.number,
                      suffixIcon: vm.isOrgInfoLoading
                          ? Padding(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.search),
                              tooltip: "Tashkilotni INN bo'yicha yangilash",
                              onPressed: vm.refetchOrgInfo,
                            ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Tashkilot nomi",
                      controller: vm.name,
                      hintText: "Firma nomi",
                      isRequired: true,
                      errorText: vm.nameError,
                      maxLength: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            ValidationUtils.nameCharsetFormatter),
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Asoschi",
                      controller: vm.founderName,
                      hintText: "Eshmatov Toshmat",
                      isRequired: true,
                      errorText: vm.founderNameError,
                      maxLength: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            ValidationUtils.nameCharsetFormatter),
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Rahbar",
                      controller: vm.directorName,
                      hintText: "Eshmatov Toshmet",
                      isRequired: true,
                      errorText: vm.directorNameError,
                      maxLength: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            ValidationUtils.nameCharsetFormatter),
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Telefon raqam",
                      controller: vm.phoneNumber,
                      hintText: "+998 90 123-45-67",
                      isRequired: true,
                      errorText: vm.phoneNumberError,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        UzbekPhoneFormatter(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Manzil",
                      controller: vm.address,
                      hintText: "Orientir, manzil",
                      isRequired: true,
                      errorText: vm.addressError,
                      maxLength: 200,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            ValidationUtils.addressCharsetFormatter),
                        LengthLimitingTextInputFormatter(200),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: "Yaratilgan yili",
                      controller: vm.establishedYear,
                      hintText: "2023",
                      isRequired: true,
                      errorText: vm.establishedYearError,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    MainButton(
                      text: "Saqlash",
                      isLoading: vm.isUpdating,
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        if (vm.validateAll()) {
                          final result = await vm.saveChanges();
                          if (!result && context.mounted) {
                            Utils.fireTopSnackBar(
                              vm.errorMessage ?? "Xatolik yuz berdi",
                              design_colors.AppColors.error,
                              context,
                            );
                          } else if (result && context.mounted) {
                            Utils.fireTopSnackBar(
                              "Fermer ma'lumotlari yangilandi",
                              design_colors.AppColors.accentGreen,
                              context,
                            );
                            context.pop(true);
                          }
                        } else {
                          Utils.fireTopSnackBar(
                            "Iltimos, barcha maydonlarni to'g'ri to'ldiring",
                            design_colors.AppColors.error,
                            context,
                          );
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
