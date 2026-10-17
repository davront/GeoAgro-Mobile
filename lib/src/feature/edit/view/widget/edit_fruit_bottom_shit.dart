import 'package:agro_employee_public/src/feature/edit/vm/edit_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../../core/setting/setup.dart';
import '../../../../core/widgets/mian_text.dart';
import '../../../detail_page/view/widgets/created_time_widget.dart';
import '../../../detail_page/view/widgets/detail_text_fild_widget.dart';
import '../../../detail_page/view/widgets/generic_drop_widget.dart';
import '../../../detail_page/view/widgets/switch_card_widget.dart';

class EditFruitBottomShit extends ConsumerWidget {
  final EditVM viewModelm;

  const EditFruitBottomShit({super.key, required this.viewModelm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editVM = ref.watch(editVm);
    final isFenced = ref.watch(switchFenced);
    final isIqtisodiy = ref.watch(editVM.switchIqtisodiy);

    return Padding(
      padding: REdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(text: "Maydon haqida ma`lumotlar"),
            CustomSwitchCard(
              label: "Iqtisodiy samarasiz va kam hosilli bog' (tok) maydoni",
              switchValue: isIqtisodiy,
              onChanged: (value) {
                ref.read(editVM.switchIqtisodiy.notifier).state = value;
                if (!value) {
                  // Выключаем экономически неэффективный режим - очищаем его поля
                  editVM.economicInefficientAreaController.clear();
                } else {
                  // Включаем экономически неэффективный режим - очищаем поля обычной посадки
                  editVM.cultivatedArea.clear();
                  editVM.tonnaController.clear();
                  editVM.sxema1.clear();
                  editVM.sxema2.clear();
                  editVM.clearSelectedDate2();
                  editVM.selectedFruitRoot = null;
                  ref.read(switchFenced.notifier).state = false;
                }
              },
              childWidgets: [
                SizedBox(height: 10.h),
                CustomTextFieldWithLabel(
                  controller: editVM.economicInefficientAreaController,
                  onTextChanged: editVM.setEconomicInefficientArea,
                  hintText: "iqtisodiy samarasiz maydon",
                  label: "Iqtisodiy samarasiz maydon: GA",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            GenericDropWidget(
              labelText: "Meva turi:",
              items: fruitList,
              selectedItem: editVM.selectedFruit,
              isLoading: editVM.isLoading2,
              onChanged: (value) async {
                editVM.setFruit(value);
                editVM.selectedFruitVariety = null;
                editVM.selectedFruitRoot = null;
                if (value != null) {
                  await Future.wait([
                    editVM.getFruitVerity(verity: value.id.toString()),
                    editVM.getFruitRootstocks(rootstocks: value.name),
                  ]);
                }
              },
              itemLabel: (item) => item.name,
            ),
            SizedBox(height: 10.h),
            GenericDropWidget(
              labelText: "Meva navi:",
              items: editVM.fruitVerityList,
              selectedItem: editVM.selectedFruitVariety,
              isLoading: editVM.isLoading2,
              onChanged: (value) async {
                editVM.setFruitVariety(value);
              },
              itemLabel: (item) => item.name,
            ),
            SizedBox(height: 10.h),
            if (!isIqtisodiy) ...[
              GenericDropWidget(
                labelText: "Payvandag' turi:",
                items: editVM.fruitRootList,
                selectedItem: editVM.selectedFruitRoot,
                isLoading: editVM.isLoading2,
                onChanged: (value) async {
                  editVM.setFruitRoot(value);
                },
                itemLabel: (item) => item.name,
              ),
              SizedBox(height: 10.h),
              MainText(text: "Ekilgan yilini kiriting:"),
              CreatedTime(
                selectedDate: editVM.selectedDate2,
                setSelectedDate: editVM.setSelectedDate2,
              ),
              SizedBox(height: 10.h),
              CustomTextFieldWithLabel(
                controller: editVM.cultivatedArea,
                onTextChanged: editVM.setCultivatedArea,
                hintText: "Ekilgan yer maydoni",
                label: "Ekilgan yer maydoni : GA",
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextFieldWithLabel(
                label: "Kutilayotgan hosil miqdori",
                controller: editVM.tonnaController,
                onTextChanged: editVM.setTonna,
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
                        controller: editVM.sxema1,
                        onTextChanged: editVM.setSxema1,
                        hintText: "sxema 1:",
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                        ]),
                  ),
                  SizedBox(width: 8.h),
                  MainText(text: "X"),
                  SizedBox(width: 8.h),
                  Expanded(
                    flex: 1,
                    child: CustomTextFieldWithLabel(
                      controller: editVM.sxema2,
                      onTextChanged: editVM.setSxema2,
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
                label: "Ximoya to`siq bilan\n o`ralganmi ?",
                switchValue: isFenced,
                onChanged: (value) {
                  ref.read(switchFenced.notifier).state = value;
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
                        "${editVM.getTotalArea(ref).toStringAsFixed(1)} GA",
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
                        editVM.resetFields(ref);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Bekor qilish",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          )),
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
                        final isIqtisodiy = ref.read(editVM.switchIqtisodiy);

                        if (editVM.selectedFruit == null) {
                          errorMessage = "Meva turi tanlanmagan.";
                        } else if (editVM.selectedFruitVariety == null) {
                          errorMessage = "Meva navi tanlanmagan.";
                        } else if (isIqtisodiy) {
                          // Экономически неэффективная площадь (rootstock опционален)
                          if (editVM.economicInefficientAreaController.text
                                  .isEmpty ||
                              double.tryParse(editVM
                                      .economicInefficientAreaController.text
                                      .replaceAll(',', '.')) ==
                                  null ||
                              (double.tryParse(editVM
                                          .economicInefficientAreaController
                                          .text
                                          .replaceAll(',', '.')) ??
                                      0) <
                                  0.1) {
                            errorMessage =
                                "Iqtisodiy samarasiz maydon noto'g'ri yoki juda kichik (kamida 0.1 ga).";
                          }
                        } else {
                          // Обычная посадка (rootstock опционален)
                          if (editVM.selectedDate2 == null) {
                            errorMessage = "Ekilgan yil tanlanmagan.";
                          } else if (editVM.cultivatedArea.text.isEmpty ||
                              double.tryParse(editVM.cultivatedArea.text
                                      .replaceAll(',', '.')) ==
                                  null ||
                              (double.tryParse(editVM.cultivatedArea.text
                                          .replaceAll(',', '.')) ??
                                      0) <
                                  0.1) {
                            errorMessage =
                                "Maydon noto'g'ri yoki juda kichik (kamida 0.1 ga).";
                          } else if (editVM.sxema1.text.isEmpty ||
                              editVM.sxema2.text.isEmpty ||
                              double.tryParse(editVM.sxema1.text) == null ||
                              double.tryParse(editVM.sxema2.text) == null) {
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
                        editVM.addSelectedDetail(ref);
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
