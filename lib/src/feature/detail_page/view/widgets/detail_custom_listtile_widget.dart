// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../core/style/app_colors.dart';

// class DetailCustomListtileWidget extends StatelessWidget {
//   final String traling;
//   final String leading;
//   const DetailCustomListtileWidget(
//       {super.key, required this.traling, required this.leading});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         Text(
//           leading,
//           style: TextStyle(color: AppColors.c1E1E1E70, fontSize: 12.sp),
//         ),
//         Text(
//           traling,
//           style: TextStyle(
//             color: AppColors.c1E1E1E90,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Roboto-SemiBold',
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DetailCustomListtileWidget2 extends StatelessWidget {
//   final String traling;
//   final String leading;
//   final VoidCallback openDetails;
//   const DetailCustomListtileWidget2({
//     super.key,
//     required this.traling,
//     required this.leading,
//     required this.openDetails,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         Row(
//           children: [
//             Text(
//               leading,
//               style: TextStyle(
//                 color: AppColors.c1E1E1E70,
//                 fontSize: 12.sp,
//                 fontFamily: 'Roboto-Medium',
//               ),
//             ),
//             // 32.horizontalSpace,
//           ],
//         ),
//         Text(
//           traling,
//           style: TextStyle(
//             color: AppColors.c1E1E1E90,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Roboto-SemiBold',
//           ),
//         ),
//       ],
//     );
//   }
// }
