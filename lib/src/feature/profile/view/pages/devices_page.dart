import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

import '../../../../core/services/fcm_service.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../data/repository/app_repository_impl.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final _devicesVmProvider =
    ChangeNotifierProvider.autoDispose<_DevicesVm>((ref) {
  return _DevicesVm()..load();
});

class _DeviceItem {
  final String token;
  final String? platform;
  final String? appVersion;
  final String? deviceName;
  final DateTime? createdAt;
  final DateTime? lastUsed;

  _DeviceItem({
    required this.token,
    this.platform,
    this.appVersion,
    this.deviceName,
    this.createdAt,
    this.lastUsed,
  });

  factory _DeviceItem.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.tryParse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return _DeviceItem(
      token: (json['device_token'] ?? json['token'] ?? '').toString(),
      platform: json['platform']?.toString(),
      appVersion: json['app_version']?.toString(),
      deviceName:
          json['device_name']?.toString() ?? json['device_model']?.toString(),
      createdAt: parse(json['created_at']),
      lastUsed: parse(json['last_used'] ?? json['updated_at']),
    );
  }
}

class _DevicesVm extends ChangeNotifier {
  final AppRepositoryImpl _repo = AppRepositoryImpl();
  bool isLoading = false;
  String? errorMessage;
  List<_DeviceItem> devices = [];
  String? currentToken;
  final Set<String> _revoking = {};

  bool isRevoking(String token) => _revoking.contains(token);

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentToken = FcmService().fcmToken ??
          await AppStorage.$read(key: StorageKey.fcmToken);
    } catch (_) {
      currentToken = null;
    }

    try {
      final raw = await _repo.getDeviceTokens();
      if (raw == null) {
        errorMessage = "Server bilan bog'liq xatolik";
      } else {
        final decoded = jsonDecode(raw);
        final list = decoded is Map<String, dynamic>
            ? (decoded['device_tokens'] ?? decoded['results'] ?? []) as List
            : (decoded as List);
        devices = list
            .whereType<Map<String, dynamic>>()
            .map(_DeviceItem.fromJson)
            .where((d) => d.token.isNotEmpty)
            .toList();
      }
    } catch (e) {
      errorMessage = "Ma'lumotlarni yuklashda xatolik";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> revoke(String token) async {
    _revoking.add(token);
    notifyListeners();
    try {
      final res = await _repo.removeDeviceToken(token: token);
      if (res != null) {
        devices.removeWhere((d) => d.token == token);
        return true;
      }
      return false;
    } finally {
      _revoking.remove(token);
      notifyListeners();
    }
  }
}

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(_devicesVmProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const CustomAppBarWidget(
        title: "Ulangan qurilmalar",
        canPop: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.getMaxContentWidth(context),
          ),
          child: RefreshIndicator(
            onRefresh: () => ref.read(_devicesVmProvider.notifier).load(),
            color: design_colors.AppColors.accentGreen,
            backgroundColor: context.colors.surface,
            child: _buildBody(context, ref, vm),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, _DevicesVm vm) {
    if (vm.isLoading) {
      return LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: c.maxHeight,
            child: Center(
              child: CircularProgressIndicator(
                  color: design_colors.AppColors.accentGreen),
            ),
          ),
        ),
      );
    }
    if (vm.errorMessage != null) {
      return LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: c.maxHeight,
            child: Center(
              child: Text(vm.errorMessage!,
                  style: AppTypography.bodyLarge(context)),
            ),
          ),
        ),
      );
    }
    if (vm.devices.isEmpty) {
      return LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: c.maxHeight,
            child: Center(
              child: Text("Ulangan qurilmalar yo'q",
                  style: AppTypography.bodyLarge(context)),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: vm.devices.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final d = vm.devices[i];
        final isCurrent = vm.currentToken != null && vm.currentToken == d.token;
        final revoking = vm.isRevoking(d.token);
        return _DeviceCard(
          item: d,
          isCurrent: isCurrent,
          isRevoking: revoking,
          onRevoke: () => _confirmRevoke(context, ref, d),
        );
      },
    );
  }

  Future<void> _confirmRevoke(
      BuildContext context, WidgetRef ref, _DeviceItem d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Qurilmani o'chirish"),
        content: const Text(
            "Bu qurilmani ro'yxatdan olib tashlamoqchimisiz? Push-bildirishnomalar bu qurilmaga kelmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success =
          await ref.read(_devicesVmProvider.notifier).revoke(d.token);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(success ? "Qurilma o'chirildi" : "Xatolik yuz berdi")));
      }
    }
  }
}

class _DeviceCard extends StatelessWidget {
  final _DeviceItem item;
  final bool isCurrent;
  final bool isRevoking;
  final VoidCallback onRevoke;

  const _DeviceCard({
    required this.item,
    required this.isCurrent,
    required this.isRevoking,
    required this.onRevoke,
  });

  IconData _icon() {
    switch (item.platform?.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      default:
        return Icons.devices_other;
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    return "${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} "
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final title = item.deviceName ??
        '${item.platform ?? "Qurilma"} ${item.appVersion ?? ""}'.trim();
    final lastUsed = _formatDate(item.lastUsed ?? item.createdAt);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCurrent
              ? design_colors.AppColors.accentGreen
              : context.colors.border.withValues(alpha: 0.4),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(_icon(),
              size: 32.sp, color: design_colors.AppColors.accentGreen),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: design_colors.AppColors.accentGreen
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "Joriy",
                          style: AppTypography.bodySmall(context).copyWith(
                            color: design_colors.AppColors.accentGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                if (lastUsed.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    "Oxirgi faollik: $lastUsed",
                    style: AppTypography.bodySmall(context).copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              onPressed: isRevoking ? null : onRevoke,
              icon: isRevoking
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, color: Colors.red),
              tooltip: "O'chirish",
            ),
        ],
      ),
    );
  }
}
