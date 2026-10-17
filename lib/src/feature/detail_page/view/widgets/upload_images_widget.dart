// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'images_upload_widget.dart'; // ImagesUploadWidget importi

// class ImageUploadListWidget extends StatelessWidget {
//   final Function(int) pickImageFromCamera; // Kameradan rasm olish
//   final Function(int) getImageFile; // Rasmni olish

//   const ImageUploadListWidget({
//     super.key,
//     required this.pickImageFromCamera,
//     required this.getImageFile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 122.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 4,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: REdgeInsets.only(right: 16.0, left: 2),
//             child: ImagesUploadWidget(
//               cardId: index + 1,
//               uploadImage: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (context) {
//                     return Padding(
//                       padding: REdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ListTile(
//                             leading: const Icon(Icons.camera),
//                             title: const Text('Camera'),
//                             onTap: () async {
//                               await pickImageFromCamera(index);
//                               if (context.mounted) {
//                                 Navigator.pop(context);
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//               uploadedImage: getImageFile(index),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
