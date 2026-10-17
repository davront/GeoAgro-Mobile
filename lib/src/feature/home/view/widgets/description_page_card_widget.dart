// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../core/widgets/custom_card_widget.dart';
// import '../../../../core/widgets/custom_driver.dart';
// import '../../../../core/widgets/custom_list_tile_widget.dart';
// import '../../../../data/model/plantation/plantation_model.dart';

// class DescriptionPageCardWidget extends StatelessWidget {
//   final PlantationModel plantation;
//   const DescriptionPageCardWidget({super.key, required this.plantation});

//   @override
//   Widget build(BuildContext context) {
//     return CustomCardWidget(
//       horizontal: 16.h,
//       vertical: 16.h,
//       child: Column(
//         children: [
//           CustomListTileWidget(
//             title: "Fermer",
//             contextText: plantation.farmer?.name ?? "Unknow",
//           ),
//           12.verticalSpace,
//           const CustomDriver(),
//           12.verticalSpace,
//           CustomListTileWidget(
//             title: "Adress",
//             contextText: plantation.farmer?.address ?? "Unknow",
//           ),
//         ],
//       ),
//     );
//   }
// }
