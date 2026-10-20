import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../design_system/theme/colors.dart' as design_colors;
import '../../vm/create_map_page_vm.dart';

/// Кнопки карты на постоянных местах: неактивная кнопка остаётся на месте
/// серой, а не исчезает — иначе столбик прыгает и легко промахнуться
/// по «+». Очистка без диалога: она откатывается тем же undo.
class CreateMapPageButtonWidgets extends StatelessWidget {
  final CreateMapPageVm vm;
  const CreateMapPageButtonWidgets({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final drawing = vm.drawing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _fab(
          tag: 'mapFab_location',
          tooltip: "Mening joylashuvim",
          onPressed: vm.getCurrentLocation,
          child: vm.isLoading
              ? Padding(
                  padding: REdgeInsets.all(4),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.my_location, size: 24),
        ),
        const SizedBox(height: 10),
        _fab(
          tag: 'mapFab_add_point',
          tooltip: "Nuqta qo'shish",
          onPressed: vm.addPointAtRulerPosition,
          child: const Icon(Icons.add, size: 30),
        ),
        const SizedBox(height: 14),
        _fab(
          tag: 'mapFab_undo',
          tooltip: "Bekor qilish",
          mini: true,
          onPressed: drawing.canUndo ? vm.undo : null,
          child: const Icon(Icons.undo),
        ),
        const SizedBox(height: 8),
        _fab(
          tag: 'mapFab_redo',
          tooltip: "Qaytarish",
          mini: true,
          onPressed: drawing.canRedo ? vm.redo : null,
          child: const Icon(Icons.redo),
        ),
        const SizedBox(height: 8),
        _fab(
          tag: 'mapFab_clear',
          tooltip: "Hammasini o'chirish",
          mini: true,
          onPressed: drawing.points.isNotEmpty ? vm.clearDrawing : null,
          child: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  Widget _fab({
    required String tag,
    required String tooltip,
    required VoidCallback? onPressed,
    required Widget child,
    bool mini = false,
  }) {
    final enabled = onPressed != null;
    return FloatingActionButton(
      heroTag: tag,
      tooltip: tooltip,
      mini: mini,
      backgroundColor:
          enabled ? design_colors.AppColors.primary : Colors.grey.shade400,
      foregroundColor: Colors.white,
      elevation: enabled ? 6 : 0,
      onPressed: onPressed,
      child: child,
    );
  }
}
