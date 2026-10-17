// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../core/widgets/custom_app_bar_widget.dart';
// import '../../../../core/widgets/custom_card_widget.dart';
// import '../../../../core/widgets/custom_driver.dart';
// import '../../../../core/widgets/custom_list_tile_widget.dart';
// import '../../../../core/widgets/error_state_widget.dart';
// import '../../vm/description_vm.dart';
// import '../../../../core/style/app_colors.dart';

// final descriptionPageVM =
//     ChangeNotifierProvider.autoDispose<DescriptionVm>((ref) {
//   ref.keepAlive();
//   return DescriptionVm();
// });

// class DescriptionPage extends ConsumerStatefulWidget {
//   final int id;
//   const DescriptionPage({super.key, required this.id});

//   @override
//   ConsumerState<DescriptionPage> createState() => _DescriptionPageState();
// }

// class _DescriptionPageState extends ConsumerState<DescriptionPage> {
//   bool isFarmerExpanded = false;
//   bool isGardenExpanded = false;
//   bool isInvestmentsExpanded = false;
//   bool isReservoirsExpanded = false;
//   bool isTrellisesExpanded = false;
//   bool isFruitAreasExpanded = false;
//   bool isSubsidiesExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(descriptionPageVM).getPlantationDescription(widget.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = ref.watch(descriptionPageVM);

//     if (vm.isLoading) {
//       return const Scaffold(
//         appBar: CustomAppBarWidget(title: "To'liq malumotlar", canPop: true),
//         body: Center(
//           child: CircularProgressIndicator(color: AppColors.c28A745),
//         ),
//       );
//     }

//     // Error state
//     if (vm.errorMessage != null) {
//       return Scaffold(
//         appBar: CustomAppBarWidget(title: "To'liq malumotlar", canPop: true),
//         body: ErrorStateWidget(
//           errorMessage: vm.errorMessage ?? "Kutilmagan Javob qaytdi",
//           onTap: () => vm.getPlantationDescription(widget.id),
//         ),
//       );
//     }

//     // Loaded state
//     return Scaffold(
//       appBar: CustomAppBarWidget(title: "To'liq malumotlar", canPop: true),
//       body: Padding(
//         padding: REdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: SingleChildScrollView(
//           child: Column(
//             spacing: 6.h,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Main Garden detail
//               CustomCardWidget(
//                 horizontal: 6.h,
//                 vertical: 4.w,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Asosiy malumotlar",
//                           style: TextStyle(
//                               color: AppColors.c1E1E1E,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16.sp),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               isGardenExpanded =
//                                   !isGardenExpanded; // Toggle visibility
//                             });
//                           },
//                           icon: AnimatedRotation(
//                             turns: isGardenExpanded
//                                 ? 0.5
//                                 : 0, // Rotate 180° if expanded
//                             duration: const Duration(milliseconds: 300),
//                             child: Icon(Icons.keyboard_arrow_down, size: 20.sp),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (isGardenExpanded)
//                 CustomCardWidget(
//                   horizontal: 8.w,
//                   vertical: 8.h,
//                   child: Column(
//                     children: [
//                       CustomListTileWidget(
//                           title: "Tashkilot nome",
//                           contextText:
//                               vm.plantationModel.farmer?.name ?? "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Asoschi",
//                           contextText: vm.plantationModel.farmer?.founderName ??
//                               "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Direktor",
//                           contextText:
//                               vm.plantationModel.farmer?.directorName ??
//                                   "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Telefon raqam",
//                           contextText: vm.plantationModel.farmer?.phoneNumber ??
//                               "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Inn",
//                           contextText: "${vm.plantationModel.farmer?.inn}"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Yaratilgan yil",
//                           contextText:
//                               "${vm.plantationModel.farmer?.establishedYear}"),
//                       8.verticalSpace,
//                     ],
//                   ),
//                 ),

//               /// Farmer detail
//               CustomCardWidget(
//                 horizontal: 6.w,
//                 vertical: 4.h,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Tashkilot haqida malumot",
//                           style: TextStyle(
//                               color: AppColors.c1E1E1E,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16.sp),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               isFarmerExpanded =
//                                   !isFarmerExpanded; // Toggle visibility
//                             });
//                           },
//                           icon: AnimatedRotation(
//                             turns: isFarmerExpanded
//                                 ? 0.5
//                                 : 0, // Rotate 180° if expanded
//                             duration: const Duration(milliseconds: 300),
//                             child: Icon(
//                               Icons.keyboard_arrow_down,
//                               size: 20.sp,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (isFarmerExpanded)
//                 CustomCardWidget(
//                   horizontal: 8.w,
//                   vertical: 8.h,
//                   child: Column(
//                     children: [
//                       CustomListTileWidget(
//                           title: "Tashkilot nome",
//                           contextText:
//                               vm.plantationModel.farmer?.name ?? "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Asoschi",
//                           contextText: vm.plantationModel.farmer?.founderName ??
//                               "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Direktor",
//                           contextText:
//                               vm.plantationModel.farmer?.directorName ??
//                                   "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Telefon raqam",
//                           contextText: vm.plantationModel.farmer?.phoneNumber ??
//                               "Unknow"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Inn",
//                           contextText: "${vm.plantationModel.farmer?.inn}"),
//                       8.verticalSpace,
//                       CustomDriver(),
//                       8.verticalSpace,
//                       CustomListTileWidget(
//                           title: "Yaratilgan yil",
//                           contextText:
//                               "${vm.plantationModel.farmer?.establishedYear}"),
//                       8.verticalSpace,
//                     ],
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
