import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../core/utils/dio_error_utils.dart';
import '../../../../data/repository/app_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import '../../../../data/model/plantation/plantations_list_model.dart';
import '../../../../core/server/api/api.dart';
import '../../../../core/server/api/api_constants.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_route_names.dart';
import '../widgets/home_page_card_widget.dart';
import '../widgets/plantation_list_or_grid_widget.dart';
import '../../vm/home_page_vm.dart'; // Import HomePageVm directly

// Shared HomePageVM provider for other pages to use deletion functionality
final sharedHomePageVM = ChangeNotifierProvider.autoDispose<HomePageVm>((ref) {
  return HomePageVm(AppRepositoryImpl());
});

final approvedPageVM = ChangeNotifierProvider.autoDispose<_ApprovedVm>((ref) {
  return _ApprovedVm();
});

class _ApprovedVm extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  bool canLoadNext = true;
  bool isFetchingMore = false;
  final List<Result> list = [];
  String? _searchQuery;
  bool get isSearching => (_searchQuery?.isNotEmpty ?? false);

  _ApprovedVm() {
    fetch();
  }

  Future<void> fetch({bool isLoadMore = false, String? search}) async {
    if ((!canLoadNext && isLoadMore) || (isLoadMore && isFetchingMore)) return;
    if (isLoadMore && (_searchQuery?.isNotEmpty ?? false)) {
      return; // disable pagination while searching
    }

    // If search query changed, reset pagination
    if (search != _searchQuery && !isLoadMore) {
      _searchQuery = search;
    }

    errorMessage = null;
    if (!isLoadMore) {
      currentPage = 1;
      canLoadNext = true;
      list.clear();
      isLoading = true;
    } else {
      isFetchingMore = true;
    }
    notifyListeners();

    try {
      final query = ApiParams.pageWithSearchParams(
          page: currentPage, search: _searchQuery);
      final data =
          await ApiService.get(ApiConst.apiPlantationsFormeApproved, query);
      if (data == null) {
        errorMessage = AppRepositoryImpl.lastErrorMessage ??
            "Server bilan bog'liq xatolik yuzaga keldi.";
      } else {
        final model = PlantationsListModel.fromJson(jsonDecode(data));
        final incomingItems = model.results ?? [];

        // Просто добавляем все приходящие данные в массив
        list.addAll(incomingItems);

        debugPrint(
            "APPROVED PAGE $currentPage: Added ${incomingItems.length} plantations (search: $_searchQuery)");
        debugPrint("Total plantations: ${list.length}");

        currentPage++;
        canLoadNext = model.next != null;
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      isFetchingMore = false;
      isLoading = false;
      notifyListeners();
    }
  }
}

class ApprovedPage extends ConsumerStatefulWidget {
  const ApprovedPage({super.key});

  @override
  ConsumerState<ApprovedPage> createState() => _ApprovedPageState();
}

class _ApprovedPageState extends ConsumerState<ApprovedPage> {
  late ScrollController _controller;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(approvedPageVM); // Use approvedPageVM for display

    if (vm.isLoading) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: _isSearchExpanded ? "" : "Tasdiqlangan",
          canPop: true,
          actions: [
            SearchBarWidget(
              key: const ValueKey('approved_search'),
              onSearchChanged: (query) {
                vm.fetch(
                    isLoadMore: false, search: query.isEmpty ? null : query);
              },
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isSearchExpanded = isExpanded;
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => vm.fetch(isLoadMore: false),
          color: design_colors.AppColors.accentGreen,
          backgroundColor: context.colors.background,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Center(
                    child: CircularProgressIndicator(
                        color: design_colors.AppColors.accentGreen)),
              ),
            ),
          ),
        ),
      );
    }
    if (vm.errorMessage != null) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: _isSearchExpanded ? "" : "Tasdiqlangan",
          canPop: true,
          actions: [
            SearchBarWidget(
              key: const ValueKey('approved_search'),
              onSearchChanged: (query) {
                vm.fetch(
                    isLoadMore: false, search: query.isEmpty ? null : query);
              },
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isSearchExpanded = isExpanded;
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => vm.fetch(isLoadMore: false),
          color: design_colors.AppColors.accentGreen,
          backgroundColor: context.colors.background,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: ErrorStateWidget(
                  errorMessage: vm.errorMessage ?? "Kutilmagan javob",
                  onTap: () => vm.fetch(isLoadMore: false),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: _isSearchExpanded ? "" : "Tasdiqlangan",
        canPop: true,
        actions: [
          SearchBarWidget(
            key: const ValueKey('approved_search'),
            onSearchChanged: (query) {
              vm.fetch(isLoadMore: false, search: query.isEmpty ? null : query);
            },
            onExpansionChanged: (isExpanded) {
              setState(() {
                _isSearchExpanded = isExpanded;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => vm.fetch(isLoadMore: false),
        color: design_colors.AppColors.accentGreen,
        backgroundColor: context.colors.background,
        child: vm.list.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const EmptyStateWidget(
                      message: "Tasdiqlangan plantatsiyalar topilmadi",
                      subMessage:
                          "Ma'lumotlarni yangilash uchun pastga torting",
                    ),
                  ),
                ),
              )
            : PlantationListOrGridWidget(
                items: vm.list,
                controller: _controller,
                canLoadNext: vm.canLoadNext && !vm.isSearching,
                isFetchingMore: vm.isFetchingMore,
                onLoadMore: () => vm.fetch(isLoadMore: true),
                itemBuilder: (plantation) => InkWell(
                  onTap: () {
                    if (plantation.id != null) {
                      context.go(
                          "${AppRouteNames.home}${AppRouteNames.plantationView}",
                          extra: plantation.id);
                    }
                  },
                  child: HomePageCardWidget(
                    plantation: plantation,
                    showEditButton: true,
                    customProvider:
                        sharedHomePageVM, // Use shared provider for deletion
                    onDeleteSuccess: () {
                      // Обновляем список после успешного удаления
                      ref.read(approvedPageVM.notifier).fetch();
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
