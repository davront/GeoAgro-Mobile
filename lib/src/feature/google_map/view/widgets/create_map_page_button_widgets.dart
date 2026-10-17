import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../design_system/theme/colors.dart' as design_colors;
import '../../vm/create_map_page_vm.dart';

class CreateMapPageButtonWidgets extends StatelessWidget {
  final CreateMapPageVm vm;
  const CreateMapPageButtonWidgets({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Кнопка "Мое местоположение" - приближать на локацию пользователя
        FloatingActionButton(
          heroTag: 'mapFab_location',
          backgroundColor: design_colors.AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: () async {
            await vm.getCurrentLocation();
          },
          child: vm.isLoading
              ? Center(
                  child: Padding(
                    padding: REdgeInsets.all(4),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : const Icon(Icons.my_location, size: 24),
        ),
        const SizedBox(height: 10),
        // Кнопка "Добавить точку" - всегда доступна для добавления точек
        FloatingActionButton(
          heroTag: 'mapFab_add_point',
          backgroundColor: design_colors.AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          mini: false,
          onPressed: () {
            vm.addPointAtRulerPosition();
          },
          child: const Icon(Icons.add, size: 28),
        ),
        const SizedBox(height: 10),
        // Кнопка "Отменить последнюю точку" - возвращать чертеж на шаг назад
        if (vm.drawingPoints.isNotEmpty)
          FloatingActionButton(
            heroTag: 'mapFab_undo',
            backgroundColor: design_colors.AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            onPressed: () {
              vm.removeLastPoint();
            },
            child: const Icon(Icons.undo),
          ),
      ],
    );
  }
}