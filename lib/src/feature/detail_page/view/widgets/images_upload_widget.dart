import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class ImageUploadListWidget extends StatelessWidget {
  final Function(BuildContext, int)
      showImagePicker; // Обновлено: принимает context
  final Function(int) getImageFile;
  final Function(int)? removeImage; // Новый параметр для удаления
  final Function(int)? getPhotoDescription; // Описание для каждого фото
  final Future<void> Function(int, {BuildContext? context})?
      pickImageFromGallery; // Выбрать из галереи
  final Future<void> Function(int, {BuildContext? context})?
      pickImageFromCamera; // Сфотографировать
  final List<String>? images;
  final int itemCount; // Количество полей для отображения
  final bool isSpecialUser; // Флаг специального пользователя

  const ImageUploadListWidget({
    super.key,
    required this.showImagePicker,
    required this.getImageFile,
    this.removeImage,
    this.getPhotoDescription,
    this.pickImageFromGallery,
    this.pickImageFromCamera,
    this.images,
    this.itemCount = 4, // По умолчанию 4 поля
    this.isSpecialUser = false, // По умолчанию false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h, // Увеличена высота для подписей
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          File? uploadedImage = getImageFile(index);
          String? networkImage = (images != null && images!.length > index)
              ? images![index]
              : null;
          final hasImage = uploadedImage != null || networkImage != null;

          final photoDescription = getPhotoDescription != null
              ? getPhotoDescription!(index)
              : 'Rasm ${index + 1}';

          return Padding(
            padding: REdgeInsets.only(right: 16.0, left: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        if (hasImage && removeImage != null) {
                          // Показываем bottom sheet с опциями
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    title: const Text('O\'chirish'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Rasmni o\'chirish'),
                                          content: const Text(
                                              'Bu rasmni o\'chirmoqchimisiz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Bekor qilish'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                removeImage!(index);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('O\'chirish',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  // Показываем опцию галереи только для специальных пользователей
                                  if (isSpecialUser) ...[
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Galereyadan tanlash'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (pickImageFromGallery != null) {
                                          pickImageFromGallery!(index,
                                              context: context);
                                        } else {
                                          showImagePicker(context, index);
                                        }
                                      },
                                    ),
                                  ],
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Kameradan olish'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (pickImageFromCamera != null) {
                                        pickImageFromCamera!(index,
                                            context: context);
                                      } else {
                                        showImagePicker(context, index);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Используем новый метод showImagePicker из VM
                          showImagePicker(context, index);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.zero,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(16.r),
                          color: Colors.grey,
                          strokeWidth: 2,
                          dashPattern: const [8, 4],
                        ),
                        child: Container(
                          width: 160.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: uploadedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(
                                    uploadedImage,
                                    semanticLabel: "Yuklangan rasm",
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (networkImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: CachedNetworkImage(
                                        imageUrl: networkImage,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Rasm yuklang ${index + 1}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                      ),
                    ),
                  ],
                ),
                // Подпись под фото
                SizedBox(height: 4.h),
                SizedBox(
                  width: 160.w,
                  child: Text(
                    photoDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
