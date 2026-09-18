import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:agro_employee_public/design_system/components/chips_and_badges.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/utils/responsive.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../data/model/task/task_status.dart';
import '../../../../data/repository/app_repository_impl.dart';
import '../../vm/tasks_vm.dart';
import '../widgets/task_card_widget.dart';

final tasksVM = ChangeNotifierProvider<TasksVm>((ref) {
  return TasksVm(AppRepositoryImpl());
});

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(tasksVM);
      if (vm.tasks.isEmpty && !vm.isLoading) vm.load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(tasksVM);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBarWidget(
        title: AppStrings.tasks,
        canPop: false,
        actions: [
          if (vm.hasFilters)
            IconButton(
              tooltip: AppStrings.tasksClearFilter,
              onPressed: () => ref.read(tasksVM).clearFilters(),
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          _FiltersBar(vm: vm),
          Expanded(child: _buildBody(vm)),
        ],
      ),
    );
  }

  Widget _buildBody(TasksVm vm) {
    if (vm.isLoading && vm.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.tasks.isEmpty) {
      return ErrorStateWidget(
        errorMessage: vm.errorMessage!,
        onTap: () => ref.read(tasksVM).refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksVM).refresh(),
      color: design_colors.AppColors.accentGreen,
      backgroundColor: context.colors.surface,
      child: vm.tasks.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyStateWidget(
                    message: vm.hasFilters
                        ? AppStrings.tasksEmptyFiltered
                        : AppStrings.tasksEmpty,
                    subMessage: AppStrings.pullToRefresh,
                  ),
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.getMaxContentWidth(context),
                ),
                child: ListView.separated(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: REdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  separatorBuilder: (_, __) => 12.verticalSpace,
                  itemCount: vm.tasks.length + (vm.canLoadNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == vm.tasks.length) {
                      return _LoadMoreButton(vm: vm);
                    }
                    final task = vm.tasks[index];
                    return TaskCardWidget(
                      task: task,
                      onTap: () => context.push(
                        "${AppRouteNames.home}${AppRouteNames.taskDetail}",
                        extra: task.id,
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _FiltersBar extends ConsumerWidget {
  final TasksVm vm;

  const _FiltersBar({required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusStats = vm.statusStats;
    final overallStats = vm.overallStats;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (final status in TaskStatus.values) ...[
            AppChip(
              label: statusStats == null
                  ? status.label
                  : "${status.label} · ${statusStats.countOf(status)}",
              selected: vm.statusFilter.contains(status),
              onTap: () => ref.read(tasksVM).toggleStatus(status),
            ),
            8.horizontalSpace,
          ],
          AppChip(
            label: overallStats == null
                ? AppStrings.taskOverdue
                : "${AppStrings.taskOverdue} · ${vm.overdueCount}",
            icon: Icons.alarm_outlined,
            selected: vm.overdueOnly,
            onTap: () => ref.read(tasksVM).toggleOverdue(),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  final TasksVm vm;

  const _LoadMoreButton({required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: vm.isFetchingMore
            ? null
            : () => ref.read(tasksVM).load(isLoadMore: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: design_colors.AppColors.accentGreen,
          foregroundColor: Colors.white,
          padding: REdgeInsets.symmetric(vertical: 14, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: vm.isFetchingMore
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text("Qolganlarini ko'rish", style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}
