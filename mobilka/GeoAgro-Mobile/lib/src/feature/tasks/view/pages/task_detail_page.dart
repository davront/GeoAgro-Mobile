import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agro_employee_public/design_system/components/banners.dart';
import 'package:agro_employee_public/design_system/components/buttons.dart';
import 'package:agro_employee_public/design_system/components/cards.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

import '../../../../../localization/app_strings.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../data/model/task/task_models.dart';
import '../../../../data/model/task/task_status.dart';
import '../../../../data/repository/app_repository_impl.dart';
import '../../vm/task_detail_vm.dart';
import '../widgets/task_comment_sheet.dart';
import '../widgets/task_status_chip.dart';
import 'tasks_page.dart' show tasksVM;

final taskDetailVM =
    ChangeNotifierProvider.autoDispose.family<TaskDetailVm, int>((ref, id) {
  return TaskDetailVm(AppRepositoryImpl(), id);
});

class TaskDetailPage extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskDetailVM(widget.taskId)).load();
    });
  }

  Future<void> _run(TaskAction action) async {
    final vm = ref.read(taskDetailVM(widget.taskId));

    String? comment;
    if (action.commentRequired) {
      comment = await showTaskCommentSheet(context, action: action);
      if (comment == null) return;
    }

    final result = await vm.apply(action, comment: comment);
    if (!mounted) return;

    if (result.ignored) return;

    if (result.errorMessage != null) {
      AppSnackBar.error(context, message: result.errorMessage!);
      return;
    }

    final updated = vm.task;
    if (updated != null) ref.read(tasksVM).applyUpdated(updated);
    AppSnackBar.success(context, message: AppStrings.taskStatusUpdated);
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    AppSnackBar.error(context, message: AppStrings.taskFileOpenFailed);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(taskDetailVM(widget.taskId));
    final task = vm.task;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBarWidget(title: AppStrings.taskTitle, canPop: true),
      body: Builder(
        builder: (context) {
          if (vm.isLoading && task == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (task == null) {
            return ErrorStateWidget(
              errorMessage: vm.errorMessage ?? AppStrings.taskNotFound,
              onTap: () => ref.read(taskDetailVM(widget.taskId)).load(),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.getMaxContentWidth(context),
              ),
              child: RefreshIndicator(
                onRefresh: () => ref.read(taskDetailVM(widget.taskId)).load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: REdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    _Header(task: task),
                    12.verticalSpace,
                    if (task.description != null) ...[
                      _SectionCard(
                        title: AppStrings.taskDescription,
                        child: _BodyText(task.description!),
                      ),
                      12.verticalSpace,
                    ],
                    _InfoCard(task: task),
                    if (task.hasFile) ...[
                      12.verticalSpace,
                      AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.attach_file,
                                size: 20.sp,
                                color: context.colors.textSecondary),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                AppStrings.taskFile,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            AppButtonText(
                              text: AppStrings.taskFileOpen,
                              onPressed: () => _openFile(task.file!),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (task.plantation != null) ...[
                      12.verticalSpace,
                      _PlantationCard(
                        plantation: task.plantation!,
                        onEdited: () =>
                            ref.read(taskDetailVM(widget.taskId)).load(),
                      ),
                    ],
                    if (task.resultComment != null) ...[
                      12.verticalSpace,
                      _SectionCard(
                        title: AppStrings.taskResultComment,
                        child: _BodyText(task.resultComment!),
                      ),
                    ],
                    if (task.reviewComment != null) ...[
                      12.verticalSpace,
                      _SectionCard(
                        title: AppStrings.taskReviewComment,
                        child: _BodyText(task.reviewComment!),
                      ),
                    ],
                    24.verticalSpace,
                    ..._actions(vm),
                    24.verticalSpace,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _actions(TaskDetailVm vm) {
    final actions = vm.availableActions;
    if (actions.isEmpty) return const [];

    return [
      for (final action in actions) ...[
        action == TaskAction.submit
            ? AppButton(
                text: action.label,
                isFullWidth: true,
                isLoading: vm.isSubmitting,
                onPressed: vm.isSubmitting ? null : () => _run(action),
              )
            : AppButtonOutlined(
                text: action.label,
                isFullWidth: true,
                onPressed: vm.isSubmitting ? null : () => _run(action),
              ),
        8.verticalSpace,
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  final TaskDetail task;

  const _Header({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        12.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            TaskStatusChip(status: task.status),
            if (task.isOverdue) const TaskOverdueChip(),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TaskDetail task;

  const _InfoCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          if (task.deadline != null)
            _Row(label: AppStrings.taskDeadline, value: _dt(task.deadline!)),
          if (task.assigner != null)
            _Row(
                label: AppStrings.taskAssignedBy,
                value: task.assigner!.displayName),
          if (task.district != null)
            _Row(label: AppStrings.taskDistrict, value: task.district!.name),
          if (task.createdAt != null)
            _Row(label: AppStrings.taskCreatedAt, value: _dt(task.createdAt!)),
          if (task.startedAt != null)
            _Row(label: AppStrings.taskStartedAt, value: _dt(task.startedAt!)),
          if (task.completedAt != null)
            _Row(
                label: AppStrings.taskCompletedAt,
                value: _dt(task.completedAt!)),
          if (task.reviewedAt != null)
            _Row(
                label: AppStrings.taskReviewedAt, value: _dt(task.reviewedAt!)),
        ],
      ),
    );
  }
}

class _PlantationCard extends StatelessWidget {
  final TaskPlantationRef plantation;
  final VoidCallback? onEdited;

  const _PlantationCard({required this.plantation, this.onEdited});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.taskPlantationNumber(plantation.id),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          8.verticalSpace,
          if (plantation.districtName != null)
            _Row(
                label: AppStrings.taskDistrict,
                value: plantation.districtName!),
          if (plantation.totalArea != null)
            _Row(
              label: AppStrings.taskPlantationArea,
              value: "${plantation.totalArea} ${AppStrings.fieldGa}",
            ),
          if (plantation.moderationStatus != null)
            _Row(
                label: AppStrings.taskPlantationModeration,
                value: plantation.moderationStatus!),
          if (plantation.isRejected) ...[
            8.verticalSpace,
            Text(
              AppStrings.taskMustResubmitPlantation,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.colors.textSecondary,
              ),
            ),
          ],
          8.verticalSpace,
          AppButton(
            text: AppStrings.taskEditOnSite,
            isFullWidth: true,
            icon: Icons.edit_location_alt_outlined,
            onPressed: () async {
              await context.push(
                "${AppRouteNames.home}${AppRouteNames.editPage}",
                extra: plantation.id,
              );
              onEdited?.call();
            },
          ),
          8.verticalSpace,
          AppButtonOutlined(
            text: AppStrings.mapViewPlantation,
            isFullWidth: true,
            icon: Icons.open_in_new,
            onPressed: () => context.push(
              "${AppRouteNames.home}${AppRouteNames.plantationView}",
              extra: plantation.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textTertiary,
            ),
          ),
          6.verticalSpace,
          child,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.4,
          color: context.colors.textPrimary,
        ),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.colors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dt(DateTime value) =>
    app_date.DateUtils.formatDateTime(value.toLocal());
