import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class EditImageUploadListWidget extends StatelessWidget {
  final Function(BuildContext, int) showImagePicker; // Обновлено: новый метод
  final Function(int) getImageFile;
  final List<String>? existingImages;
  final Future<String?> Function(int)? removeExistingImage;
  final bool Function(int)? isUploadingAt;
  final int itemCount; // Количество полей для отображения

  const EditImageUploadListWidget({
    super.key,
    required this.showImagePicker,
    required this.getImageFile,
    this.existingImages,
    this.removeExistingImage,
    this.isUploadingAt,
    this.itemCount = 4, // По умолчанию 4 поля
  });

  @override
  Widget build(BuildContext context) {
    // Используем переданное количество слотов
    final totalSlots = itemCount;

    return SizedBox(
      height: 122.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSlots,
        itemBuilder: (context, index) {
          File? uploadedImage = getImageFile(index);
          String? networkImage =
              (existingImages != null && existingImages!.length > index)
                  ? existingImages![index]
                  : null;

          return Padding(
            padding: REdgeInsets.only(right: 16.0, left: 2),
            child: MaterialButton(
              onPressed: () async {
                // Если есть существующее изображение, показываем опцию удаления
                if (networkImage != null && removeExistingImage != null) {
                  final action = await showModalBottomSheet<String>(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
                              title: const Text('O\'chirish'),
                              onTap: () => Navigator.pop(context, 'delete'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('O\'zgartirish'),
                              onTap: () => Navigator.pop(context, 'edit'),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (action == 'delete') {
                    final msg = await removeExistingImage!(index);
                    if (context.mounted && msg != null && msg.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                    return;
                  } else if (action == 'edit') {
                    // Продолжаем к выбору изображения
                    if (context.mounted) {
                      showImagePicker(context, index);
                    }
                    return;
                  }
                } else {
                  // Нет существующего изображения - сразу показываем выбор
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Base content (original styles)
                      if (uploadedImage != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(
                              uploadedImage,
                              semanticLabel: "Yuklangan rasm",
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (networkImage != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: CachedNetworkImage(
                              imageUrl: networkImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                          ),
                        ),
                      // Loader overlay
                      if (isUploadingAt?.call(index) == true)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
