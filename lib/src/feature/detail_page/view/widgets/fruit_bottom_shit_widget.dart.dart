import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/mian_text.dart';
import '../../vm/detail_vm.dart';
import 'generic_drop_widget.dart';
import 'created_time_widget.dart';
import 'detail_text_fild_widget.dart';
import 'switch_card_widget.dart';

/// Форматтер, ограничивающий количество цифр (не считая точку/запятую)
class _MaxDigitsFormatter extends TextInputFormatter {
  final int maxDigits;

  _MaxDigitsFormatter({required this.maxDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Подсчитываем количество цифр в новом значении
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Если количество цифр превышает максимум, возвращаем старое значение
    if (digitsOnly.length > maxDigits) {
      return oldValue;
    }

    return newValue;
  }
}

class FruitBottomShitWidget extends ConsumerWidget {
  final DetailVM detailVm;
  const FruitBottomShitWidget({super.key, required this.detailVm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailVm = ref.watch(detailVM);
    final switchFenced = ref.watch(detailVm.switchFenced);
    final switchIqtisodiy = ref.watch(detailVm.switchIqtisodiy);

    return Padding(
      padding: REdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(text: "Maydon haqida ma`lumotlar"),
            CustomSwitchCard(
              label: "Iqtisodiy samarasiz va kam hosilli\nbog' (tok) maydoni",
              switchValue: switchIqtisodiy,
              onChanged: (value) {
                // print('[UI] switchIqtisodiy changed to: $value');
                ref.read(detailVm.switchIqtisodiy.notifier).state = value;
                // print('[UI] switchIqtisodiy after set: ${ref.read(detailVm.switchIqtisodiy)}');
                if (!value) {
                  // Выключаем экономически неэффективный режим - очищаем его поля
                  detailVm.economicInefficientAreaController.clear();
                } else {
                  // Включаем экономически неэффективный режим - очищаем поля обычной посадки
                  detailVm.cultivatedArea.clear();
                  detailVm.tonnaController.clear();
                  detailVm.sxema1.clear();
                  detailVm.sxema2.clear();
                  detailVm.clearSelectedDate2();
                  detailVm.selectedFruitRoot = null;
                  ref.read(detailVm.switchFenced.notifier).state = false;
                }
              },
              childWidgets: [
                SizedBox(height: 10.h),
                CustomTextFieldWithLabel(
                  controller: detailVm.economicInefficientAreaController,
                  onTextChanged: detailVm.setEconomicInefficientArea,
                  hintText: "iqtisodiy samarasiz maydon",
                  label: "Iqtisodiy samarasiz maydon: GA",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    _MaxDigitsFormatter(maxDigits: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            GenericDropWidget(
              labelText: "Meva turi:",
              items: detailVm.fruitList,
              selectedItem: detailVm.fruitList.contains(detailVm.selectedFruit)
                  ? detailVm.selectedFruit
                  : null,
              isLoading: detailVm.isLoading,
              onChanged: (value) async {
                detailVm.setFruit(value);
                detailVm.selectedFruitVariety = null;
                detailVm.selectedFruitRoot = null;
                if (value != null) {
                  await Future.wait([
                    detailVm.getFruitVerity(verity: value.id.toString()),
                    detailVm.getFruitRootstocks(rootstocks: value.name)
                  ]);
                }
              },
              itemLabel: (item) => item.name,
            ),
            SizedBox(height: 10.h),
            GenericDropWidget(
              labelText: "Meva navi:",
              items: detailVm.fruitVerityList,
              selectedItem: detailVm.fruitVerityList
                      .contains(detailVm.selectedFruitVariety)
                  ? detailVm.selectedFruitVariety
                  : null,
              isLoading: detailVm.isLoading2,
              onChanged: (value) async {
                detailVm.setFruitVariety(value);
              },
              itemLabel: (item) => item.name,
            ),
            SizedBox(height: 10.h),
            if (!switchIqtisodiy) ...[
              GenericDropWidget(
                labelText: "Payvandag' turi:",
                items: detailVm.fruitRootList,
                selectedItem:
                    detailVm.fruitRootList.contains(detailVm.selectedFruitRoot)
                        ? detailVm.selectedFruitRoot
                        : null,
                isLoading: detailVm.isLoading2,
                onChanged: (value) async {
                  detailVm.setFruitRoot(value);
                },
                itemLabel: (item) => item.name,
              ),
              SizedBox(height: 10.h),
              MainText(text: "Ekilgan yilini kiriting:"),
              CreatedTime(
                  selectedDate: detailVm.selectedDate2,
                  setSelectedDate: detailVm.setSelectedDate2),
              SizedBox(height: 10.h),
              CustomTextFieldWithLabel(
                controller: detailVm.cultivatedArea,
                onTextChanged: detailVm.setCultivatedArea,
                hintText: "Ekilgan yer maydoni",
                label: "Ekilgan yer maydoni : GA",
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  _MaxDigitsFormatter(maxDigits: 8),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextFieldWithLabel(
                label: "Kutilayotgan hosil miqdori",
                controller: detailVm.tonnaController,
                onTextChanged: detailVm.setTonna,
                hintText: "kutilayotgan hosil miqdori: T",
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10.h),
              MainText(text: "Ekinlagan ko`chat sxemasi"),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: CustomTextFieldWithLabel(
                          controller: detailVm.sxema1,
                          onTextChanged: detailVm.setSxema1,
                          hintText: "sxema 1:",
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ])),
                  SizedBox(width: 8.h),
                  MainText(text: "X"),
                  SizedBox(width: 8.h),
                  Expanded(
                    flex: 1,
                    child: CustomTextFieldWithLabel(
                      controller: detailVm.sxema2,
                      onTextChanged: detailVm.setSxema2,
                      hintText: "sxema 2:",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              CustomSwitchCard(
                label: "Ximoya to`siq bilan\no`ralganmi ?",
                switchValue: switchFenced,
                onChanged: (value) {
                  ref.read(detailVm.switchFenced.notifier).state = value;
                },
              ),
            ],
            SizedBox(height: 16.h),
            Consumer(
              builder: (context, ref, child) {
                return Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                        "${detailVm.getTotalArea(ref).toStringAsFixed(1)} GA",
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom
                            : 16),
                    child: ElevatedButton(
                      onPressed: () {
                        detailVm.resetFields(ref);
                        Navigator.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Bekor qilish",
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom
                            : 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validatsiya
                        String? errorMessage;
                        final isIqtisodiy = ref.read(detailVm.switchIqtisodiy);
                        // print('[UI] Validation: isIqtisodiy = $isIqtisodiy');

                        if (detailVm.selectedFruit == null) {
                          errorMessage = "Meva turi tanlanmagan.";
                        } else if (detailVm.selectedFruitVariety == null) {
                          errorMessage = "Meva navi tanlanmagan.";
                        } else if (isIqtisodiy) {
                          // Экономически неэффективная площадь (rootstock опционален)
                          // print('[UI] Validating iqtisodiy mode');
                          final areaValue = double.tryParse(detailVm
                              .economicInefficientAreaController.text
                              .replaceAll(',', '.'));

                          if (detailVm.economicInefficientAreaController.text
                                  .isEmpty ||
                              areaValue == null ||
                              areaValue < 0.1) {
                            errorMessage =
                                "Iqtisodiy samarasiz maydon noto'g'ri yoki juda kichik (kamida 0.1 ga).";
                          }
                        } else {
                          // Обычная посадка (rootstock опционален)
                          if (detailVm.selectedDate2 == null) {
                            errorMessage = "Ekilgan yil tanlanmagan.";
                          } else if (detailVm.cultivatedArea.text.isEmpty ||
                              double.tryParse(detailVm.cultivatedArea.text
                                      .replaceAll(',', '.')) ==
                                  null ||
                              (double.tryParse(detailVm.cultivatedArea.text
                                          .replaceAll(',', '.')) ??
                                      0) <
                                  0.1) {
                            errorMessage =
                                "Maydon noto'g'ri yoki juda kichik (kamida 0.1 ga).";
                          } else if (detailVm.sxema1.text.isEmpty ||
                              detailVm.sxema2.text.isEmpty ||
                              double.tryParse(detailVm.sxema1.text) == null ||
                              double.tryParse(detailVm.sxema2.text) == null) {
                            errorMessage =
                                "Ko'chat sxemasi noto'g'ri yoki bo'sh.";
                          }
                        }
                        if (errorMessage != null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Xatolik",
                                  style: TextStyle(fontSize: 14.sp)),
                              content: Text(errorMessage!,
                                  style: TextStyle(fontSize: 12.sp)),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK",
                                      style: TextStyle(fontSize: 12.sp)),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        detailVm.addSelectedDetail(ref);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: Text("   Qo‘shish   ",
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
