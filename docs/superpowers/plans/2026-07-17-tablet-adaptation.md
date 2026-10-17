# Адаптация под планшеты — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Приложение GeoAgro Mobile корректно работает и выглядит адаптированным на Android-планшетах в portrait и landscape, не только растягиваясь.

**Architecture:** Клэмпим `flutter_screenutil` сверху одной обёрткой (не переписываем сотни `.sp/.w/.h`-мест). Активируем существующий, но неиспользуемый `Responsive` класс (`lib/design_system/utils/responsive.dart`) как единственный источник breakpoints. Точечно перестраиваем 4 области: навигация (`NavigationRail` на широких экранах), списки (grid), формы (ограничение ширины), карта рисования полигона (боковая панель в landscape).

**Tech Stack:** Flutter (Dart ^3.6.0), `flutter_screenutil`, `flutter_riverpod`, `google_maps_flutter`.

## Global Constraints

- `flutter analyze` должен быть чист (без новых issues) после каждой задачи.
- Не менять `designSize` в `ScreenUtilInit` — остаётся `Size(375, 812)`.
- Не создавать новый responsive-механизм — использовать только `Responsive` из `lib/design_system/utils/responsive.dart`.
- Телефонное поведение (compact width, `Responsive.isCompact == true`) не должно визуально измениться ни в одной задаче — всегда сохранять текущую ветку как fallback/default.
- Каждая задача заканчивается коммитом.

---

### Task 1: Клэмп ScreenUtil на широких экранах

**Files:**
- Modify: `lib/src/core/widgets/custom_screen_util.dart`

**Interfaces:**
- Consumes: ничего нового — оборачивает существующий `ScreenUtilInit`.
- Produces: `CustomScreenUtil` продолжает иметь тот же публичный API (`{required Widget child, required bool enabledPreview}`), поведение внутри меняется. Ничего экспортируемого не добавляется.

Текущий файл:
```dart
// import "package:device_preview/device_preview.dart";
// import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

class CustomScreenUtil extends StatelessWidget {
  final Widget child;
  final bool enabledPreview;

  const CustomScreenUtil({
    required this.child,
    required this.enabledPreview,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: child,
       
      );
}
```

- [ ] **Step 1: Заменить файл клэмпящей версией**

```dart
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

/// Максимальная ширина/высота, которую видит ScreenUtil при расчёте
/// .sp/.w/.h — выше этого предела реальный (более широкий) экран
/// планшета клэмпится, чтобы весь существующий .sp/.w/.h-код в
/// проекте (сотни мест, дизайн под designSize 375x812) не растягивался
/// пропорционально ширине экрана. 600x960 — примерно верхняя граница
/// compact/medium breakpoint (Responsive.compact = 600).
const double _kScreenUtilMaxWidth = 600;
const double _kScreenUtilMaxHeight = 960;

class CustomScreenUtil extends StatelessWidget {
  final Widget child;
  final bool enabledPreview;

  const CustomScreenUtil({
    required this.child,
    required this.enabledPreview,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final realSize = mediaQuery.size;
    final clampedSize = Size(
      realSize.width > _kScreenUtilMaxWidth
          ? _kScreenUtilMaxWidth
          : realSize.width,
      realSize.height > _kScreenUtilMaxHeight
          ? _kScreenUtilMaxHeight
          : realSize.height,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(size: clampedSize),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: child,
      ),
    );
  }
}
```

- [ ] **Step 2: Запустить flutter analyze**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/core/widgets/custom_screen_util.dart`
Expected: `No issues found!`

- [ ] **Step 3: Проверить на телефонном эмуляторе (регрессия)**

Запустить приложение на `emulator-5554` (Pixel 3a/9 Pro, 375-420dp шириной — ниже клэмпа, `MediaQuery.copyWith` вернёт исходный `realSize` без изменений). Визуально сверить главный экран/карточки/шрифты — должны выглядеть идентично состоянию до правки.

- [ ] **Step 4: Проверить на планшетном эмуляторе**

Запустить на `Pixel_Tablet` эмуляторе (portrait ~800dp, landscape ~1280dp ширины — оба выше клэмпа). Шрифты/кнопки/паддинги должны быть заметно меньше, чем без клэмпа (не растянуты пропорционально ширине экрана).

- [ ] **Step 5: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/core/widgets/custom_screen_util.dart
git commit -m "$(cat <<'EOF'
fix: clamp ScreenUtil scaling on wide screens for tablet support

ScreenUtilInit scales all .sp/.w/.h values linearly from screen width
against designSize 375x812 — on a 10" tablet (768-1280dp) this produced
oversized fonts/buttons across the app. Wraps ScreenUtilInit in a
MediaQuery that clamps the size it sees to 600x960, so the hundreds of
existing .sp/.w/.h call sites keep working unchanged while getting
sane absolute values on tablets. Phone screens (below the clamp) are
unaffected.
EOF
)"
```

---

### Task 2: NavigationRail на широких экранах (HomePage)

**Files:**
- Modify: `lib/src/feature/home/view/pages/home_page.dart:155-260` (метод `build`)

**Interfaces:**
- Consumes: `Responsive.shouldShowSidebar(BuildContext)` — уже существует в `lib/design_system/utils/responsive.dart:128-130`, возвращает `bool` (true для `isExpanded`/`isLarge`/`isExtraLarge`, т.е. width >= 1200dp — `Responsive.expanded`).
- Produces: ничего нового наружу — `HomePage` остаётся тем же публичным виджетом.

Текущий `build()` (строки 155-260, уже прочитан) строит `Scaffold` с `body: IndexedStack(...)` и `bottomNavigationBar: Container(...NavigationBar...)`. `_selectedIndex`, `_builtTabs`, `onDestinationSelected` callback (устанавливает `_selectedIndex`, добавляет в `_builtTabs`, зовёт `_loadTabData(index)`) — используются как есть, без изменений сигнатур.

- [ ] **Step 1: Добавить импорт Responsive**

В начало `lib/src/feature/home/view/pages/home_page.dart`, рядом с другими импортами дизайн-системы:
```dart
import 'package:agro_employee_public/design_system/utils/responsive.dart';
```

- [ ] **Step 2: Извлечь destinations и общий callback в поля класса**

Внутри `_HomePageState`, перед методом `build`, добавить:
```dart
  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: "Uy",
    ),
    NavigationDestination(
      icon: Icon(Icons.agriculture_outlined),
      selectedIcon: Icon(Icons.agriculture),
      label: "Fermerlar",
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: "Statistika",
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: "Profil",
    ),
  ];

  void _onNavSelect(int index) {
    setState(() {
      _selectedIndex = index;
      _builtTabs.add(index);
    });
    _loadTabData(index);
  }
```

- [ ] **Step 3: Заменить существующий inline-список `destinations` в NavigationBar на `_navDestinations`**

Найти в текущем `build()`:
```dart
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: "Uy",
                ),
                NavigationDestination(
                  icon: Icon(Icons.agriculture_outlined),
                  selectedIcon: Icon(Icons.agriculture),
                  label: "Fermerlar",
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: "Statistika",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: "Profil",
                ),
              ],
```
Заменить на:
```dart
              destinations: _navDestinations,
```

И заменить существующий `onDestinationSelected` callback:
```dart
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  _builtTabs.add(index);
                });
                _loadTabData(index);
              },
```
на:
```dart
              onDestinationSelected: _onNavSelect,
```

- [ ] **Step 4: Обернуть Scaffold body/bottomNavigationBar в проверку Responsive.shouldShowSidebar**

Текущая структура (после Step 3):
```dart
    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
        decoration: BoxDecoration(/* ... */),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(/* ... */),
            child: NavigationBar(
              height: 64,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavSelect,
              destinations: _navDestinations,
            ),
          ),
        ),
      ),
    );
```

Заменить на:
```dart
    final showSidebar = Responsive.shouldShowSidebar(context);

    if (showSidebar) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavSelect,
              labelType: NavigationRailLabelType.all,
              backgroundColor: context.colors.surfaceVariant,
              selectedIconTheme: IconThemeData(
                color: design_colors.AppColors.accentGreen,
              ),
              selectedLabelTextStyle: TextStyle(
                color: design_colors.AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: context.colors.textTertiary,
              ),
              destinations: _navDestinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: tabs,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: BorderRadius.circular(24.r),
          border: context.colors.cardBorder,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: context.colors.isDark ? 0.08 : 0.06),
              blurRadius: context.colors.isDark ? 24 : 16,
              offset: const Offset(0, 4),
            ),
            if (!context.colors.isDark)
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 1,
                offset: Offset(0, 0),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor:
                  design_colors.AppColors.accentGreen.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 12.sp,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: states.contains(WidgetState.selected)
                      ? design_colors.AppColors.accentGreen
                      : context.colors.textTertiary,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  size: 22.sp,
                  color: states.contains(WidgetState.selected)
                      ? design_colors.AppColors.accentGreen
                      : context.colors.textTertiary,
                ),
              ),
              elevation: 0,
            ),
            child: NavigationBar(
              height: 64,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavSelect,
              destinations: _navDestinations,
            ),
          ),
        ),
      ),
    );
```

**Важно**: остальная часть текущего `build()` (переменная `vm`, список `tabs`) остаётся выше этого блока без изменений — только финальный `return Scaffold(...)` расщепляется на две ветки, как показано.

- [ ] **Step 5: flutter analyze**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/feature/home/view/pages/home_page.dart`
Expected: `No issues found!`

- [ ] **Step 6: Проверить на телефоне и планшете**

Телефон (`emulator-5554`) — `NavigationBar` внизу без изменений. Планшет landscape (`Pixel_Tablet`, ширина ~1280dp >= 1200 expanded) — `NavigationRail` слева, переключение вкладок работает, `_builtTabs`/`_loadTabData` логика не сломана (фермеры/статистика/профиль по-прежнему грузятся при первом посещении). Планшет portrait (~800dp, medium — НЕ expanded) — остаётся `NavigationBar` внизу (это ожидаемо: `shouldShowSidebar` требует expanded+, т.е. >= 1200dp).

- [ ] **Step 7: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/feature/home/view/pages/home_page.dart
git commit -m "$(cat <<'EOF'
feat: use NavigationRail instead of bottom nav on wide screens

HomePage always used a bottom NavigationBar, wasting vertical space on
tablets in landscape. Responsive.shouldShowSidebar (existing, unused
until now) now switches to a side NavigationRail with the same 4
destinations/selection logic on expanded+ width (>=1200dp). Phone and
tablet-portrait layouts are unchanged.

Note: the actual committed message for this task (4ecfadd) says
">=840dp" — a documentation inaccuracy caught during final review,
fixed here in the plan but not rewritten in git history.
EOF
)"
```

---

### Task 3: Grid для списка плантаций на главной

**Files:**
- Modify: `lib/src/feature/home/view/pages/home_page.dart` (метод `_buildContent`, ветка с `ListView.separated`)

**Interfaces:**
- Consumes: `Responsive.getGridColumns(BuildContext)` (существует, `responsive.dart:82-88`, возвращает `int`: 2 compact→ фактически не используется тут т.к. решение "grid только не-compact", 3 medium/expanded, 4 large+). `Responsive.isCompact(BuildContext)` — `bool`.
- Produces: ничего наружу.

Текущий код (уже прочитан ранее, `home_page.dart` строки ~403-494) — ветка `vm.plantationsList.isEmpty ? EmptyState : RefreshIndicator(child: ListView.separated(...))`. Точный текущий блок (после условия `isEmpty`):

```dart
          : RefreshIndicator(
              onRefresh: () async {
                await vm.getPlantationsModel(isLoadMore: false);
              },
              color: design_colors.AppColors.accentGreen,
              backgroundColor: context.colors.surface,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                separatorBuilder: (_, __) => 16.verticalSpace,
                padding: REdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: vm.plantationsList.length +
                    ((vm.canLoadNext && !vm.isSearching) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == vm.plantationsList.length && !vm.isSearching) {
                    return Container(
                      margin: REdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: vm.isFetchingMore
                            ? null
                            : () {
                                vm.getPlantationsModel(isLoadMore: true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design_colors.AppColors.accentGreen,
                          foregroundColor: Colors.white,
                          padding: REdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: vm.isFetchingMore
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  8.horizontalSpace,
                                  Text("Yuklanmoqda...",
                                      style: TextStyle(fontSize: 16.sp)),
                                ],
                              )
                            : Text("Qolganlarini ko'rish",
                                style: TextStyle(fontSize: 16.sp)),
                      ),
                    );
                  }
                  Result plantation = vm.plantationsList[index];
                  return Padding(
                    padding: REdgeInsets.symmetric(horizontal: 4),
                    child: HomePageCardWidget(
                      plantation: plantation,
                      showEditButton: true,
                      onDeleteSuccess: () {
                        ref
                            .read(homePageVM)
                            .getPlantationsModel(isLoadMore: false);
                      },
                    ),
                  );
                },
              ),
            ),
```

- [ ] **Step 1: Добавить импорт Responsive** (если ещё не добавлен в Task 2 — уже будет)

- [ ] **Step 2: Извлечь load-more кнопку в отдельный приватный метод**

Внутри `_HomePageState`, добавить приватный метод (переиспользуется и в list-, и в grid-ветке):
```dart
  Widget _buildLoadMoreButton(HomePageVm vm) {
    return Container(
      margin: REdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: vm.isFetchingMore
            ? null
            : () {
                vm.getPlantationsModel(isLoadMore: true);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: design_colors.AppColors.accentGreen,
          foregroundColor: Colors.white,
          padding: REdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: vm.isFetchingMore
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  8.horizontalSpace,
                  Text("Yuklanmoqda...", style: TextStyle(fontSize: 16.sp)),
                ],
              )
            : Text("Qolganlarini ko'rish", style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
```

- [ ] **Step 3: Заменить ListView.separated блок на условную list/grid-ветку**

Заменить блок из шапки задачи (весь `RefreshIndicator(child: ListView.separated(...))`) на:
```dart
          : RefreshIndicator(
              onRefresh: () async {
                await vm.getPlantationsModel(isLoadMore: false);
              },
              color: design_colors.AppColors.accentGreen,
              backgroundColor: context.colors.surface,
              child: Responsive.isCompact(context)
                  ? ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      separatorBuilder: (_, __) => 16.verticalSpace,
                      padding:
                          REdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: vm.plantationsList.length +
                          ((vm.canLoadNext && !vm.isSearching) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == vm.plantationsList.length &&
                            !vm.isSearching) {
                          return _buildLoadMoreButton(vm);
                        }
                        final plantation = vm.plantationsList[index];
                        return Padding(
                          padding: REdgeInsets.symmetric(horizontal: 4),
                          child: HomePageCardWidget(
                            plantation: plantation,
                            showEditButton: true,
                            onDeleteSuccess: () {
                              ref
                                  .read(homePageVM)
                                  .getPlantationsModel(isLoadMore: false);
                            },
                          ),
                        );
                      },
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          REdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: Responsive.getGridColumns(context),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.4,
                            ),
                            itemCount: vm.plantationsList.length,
                            itemBuilder: (context, index) {
                              final plantation = vm.plantationsList[index];
                              return HomePageCardWidget(
                                plantation: plantation,
                                showEditButton: true,
                                onDeleteSuccess: () {
                                  ref
                                      .read(homePageVM)
                                      .getPlantationsModel(isLoadMore: false);
                                },
                              );
                            },
                          ),
                          if (vm.canLoadNext && !vm.isSearching)
                            _buildLoadMoreButton(vm),
                        ],
                      ),
                    ),
            ),
```

**Примечание про `childAspectRatio: 1.4`**: это стартовое значение, подобранное для примерной пропорции существующей `HomePageCardWidget` в 2-3-колоночной сетке — при визуальной проверке на планшете (Step 5) при обрезании/лишнем пустом пространстве в карточке скорректировать это число на месте (не является жёстким требованием плана, карточка не должна выглядеть сломанной).

- [ ] **Step 4: flutter analyze**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/feature/home/view/pages/home_page.dart`
Expected: `No issues found!`

- [ ] **Step 5: Проверить на телефоне и планшете**

Телефон — список без изменений (compact ветка). Планшет portrait (medium, 2 колонки) и landscape (expanded, 3 колонки) — карточки в сетке, не обрезаны/не переполнены текстом, "Qolganlarini ko'rish" под сеткой на всю ширину, pull-to-refresh работает в обоих режимах.

- [ ] **Step 6: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/feature/home/view/pages/home_page.dart
git commit -m "$(cat <<'EOF'
feat: grid layout for plantation list on tablet-width screens

The plantation list was a single-column ListView.separated regardless
of screen width, wasting horizontal space on tablets. Compact width
keeps the existing ListView; medium+ switches to a GridView.builder
with Responsive.getGridColumns (2 cols medium, 3 expanded+). Load-more
button extracted to _buildLoadMoreButton, shared between both layouts.
EOF
)"
```

---

### Task 4: Grid для списка фермеров

**Files:**
- Modify: `lib/src/feature/fermers/view/pages/fermers_page.dart` (класс `_FarmersList`, метод `build`)

**Interfaces:**
- Consumes: `Responsive.isCompact`, `Responsive.getGridColumns` — те же, что в Task 3.
- Produces: ничего наружу — `_FarmersList` остаётся приватным, тот же конструктор `_FarmersList({required this.vm})`.

Текущий `_FarmersList.build()` (прочитан ранее, `fermers_page.dart:399-440`):
```dart
class _FarmersList extends StatelessWidget {
  final FermerVm vm;

  const _FarmersList({
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          vm.fermersList.length + (vm.isFetchingMore ? 1 : 0),
          (index) {
            if (index == vm.fermersList.length) {
              return Padding(
                padding: REdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: design_colors.AppColors.accentGreen,
                  ),
                ),
              );
            }

            final farmer = vm.fermersList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: FermerPageCardWidget(
                onPressed: () {
                  context.push(
                    "/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}",
                    extra: farmer.id,
                  );
                },
                fermerModel: farmer,
              ),
            );
          },
        ),
        // ... (вероятно есть ещё содержимое ниже — не трогать, дописать после этого блока)
      ],
    );
  }
}
```

- [ ] **Step 1: Добавить импорт Responsive**

В начало `lib/src/feature/fermers/view/pages/fermers_page.dart`:
```dart
import 'package:agro_employee_public/design_system/utils/responsive.dart';
```

- [ ] **Step 2: Заменить `List.generate`-блок на условную list/grid-ветку**

Заменить:
```dart
        ...List.generate(
          vm.fermersList.length + (vm.isFetchingMore ? 1 : 0),
          (index) {
            if (index == vm.fermersList.length) {
              return Padding(
                padding: REdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: design_colors.AppColors.accentGreen,
                  ),
                ),
              );
            }

            final farmer = vm.fermersList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: FermerPageCardWidget(
                onPressed: () {
                  context.push(
                    "/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}",
                    extra: farmer.id,
                  );
                },
                fermerModel: farmer,
              ),
            );
          },
        ),
```

на:
```dart
        if (Responsive.isCompact(context))
          ...List.generate(
            vm.fermersList.length + (vm.isFetchingMore ? 1 : 0),
            (index) {
              if (index == vm.fermersList.length) {
                return Padding(
                  padding: REdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: design_colors.AppColors.accentGreen,
                    ),
                  ),
                );
              }

              final farmer = vm.fermersList[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: FermerPageCardWidget(
                  onPressed: () {
                    context.push(
                      "/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}",
                      extra: farmer.id,
                    );
                  },
                  fermerModel: farmer,
                ),
              );
            },
          )
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.getGridColumns(context),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: vm.fermersList.length,
            itemBuilder: (context, index) {
              final farmer = vm.fermersList[index];
              return FermerPageCardWidget(
                onPressed: () {
                  context.push(
                    "/${AppRouteNames.farmers}/${AppRouteNames.googleMaps}",
                    extra: farmer.id,
                  );
                },
                fermerModel: farmer,
              );
            },
          ),
          if (vm.isFetchingMore)
            Padding(
              padding: REdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: design_colors.AppColors.accentGreen,
                ),
              ),
            ),
        ],
```

**Примечание про `childAspectRatio: 1.6`**: `FermerPageCardWidget` короче, чем плантация-карточка (имя+INN-чип+адрес, без картинки) — стартовое значение шире/площе, скорректировать при визуальной проверке (Step 4), как в Task 3.

- [ ] **Step 3: flutter analyze**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/feature/fermers/view/pages/fermers_page.dart`
Expected: `No issues found!`

- [ ] **Step 4: Проверить на телефоне и планшете**

Тот же чеклист, что Task 3 Step 5, для страницы фермеров.

- [ ] **Step 5: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/feature/fermers/view/pages/fermers_page.dart
git commit -m "$(cat <<'EOF'
feat: grid layout for farmer list on tablet-width screens

Same pattern as the plantation list (Task 3) — _FarmersList's
List.generate becomes a GridView.builder on medium+ width, keeping the
existing single-column layout on phones.
EOF
)"
```

---

### Task 5: Ограничение ширины форм (create/edit плантации, create/edit фермера)

**Files:**
- Modify: `lib/src/feature/detail_page/view/pages/detail_page.dart`
- Modify: `lib/src/feature/edit/view/page/edit_page.dart`
- Modify: `lib/src/feature/fermers/view/pages/fermer_create_page.dart`
- Modify: `lib/src/feature/fermers/view/pages/fermer_edit_page.dart`

**Interfaces:**
- Consumes: `Responsive.getMaxContentWidth(BuildContext)` — существует, `responsive.dart:107-112`, возвращает `double` (`double.infinity` на compact, 720/960/1200 на wider).
- Produces: ничего наружу.

Каждый из 4 файлов имеет форму как `Scaffold.body`, обычно `SingleChildScrollView`/`Form` напрямую под `Scaffold`. Паттерн одинаков во всех четырёх — обернуть существующее `body:` значение в `Center(child: ConstrainedBox(...))`, не трогая содержимое самой формы.

- [ ] **Step 1: Прочитать текущую структуру body каждого из 4 файлов**

Перед правкой в каждом файле найти точную границу `body:` в `Scaffold(...)` командой:
```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
grep -n "body:" lib/src/feature/detail_page/view/pages/detail_page.dart
grep -n "body:" lib/src/feature/edit/view/page/edit_page.dart
grep -n "body:" lib/src/feature/fermers/view/pages/fermer_create_page.dart
grep -n "body:" lib/src/feature/fermers/view/pages/fermer_edit_page.dart
```

- [ ] **Step 2: Добавить импорт Responsive в каждый из 4 файлов**

```dart
import 'package:agro_employee_public/design_system/utils/responsive.dart';
```
(в `detail_page.dart`, `edit_page.dart`, `fermer_create_page.dart`, `fermer_edit_page.dart` — путь импорта одинаковый, добавить рядом с другими `design_system` импортами в каждом файле).

- [ ] **Step 3: В каждом файле обернуть существующее значение `body:` в Center+ConstrainedBox**

Общий паттерн — было:
```dart
      body: <ExistingBodyWidget>,
```
Стало:
```dart
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.getMaxContentWidth(context),
          ),
          child: <ExistingBodyWidget>,
        ),
      ),
```

Применить это преобразование к `body:` в каждом из 4 файлов, используя точную позицию, найденную в Step 1. `<ExistingBodyWidget>` — весь существующий виджет, который сейчас присвоен `body:`, без единого изменения внутри него.

**Важно**: если в каком-то из 4 файлов `body` уже обёрнут в `SafeArea` снаружи (проверить при чтении в Step 1) — `Center`+`ConstrainedBox` вставляется ВНУТРИ `SafeArea`, не снаружи (`SafeArea(child: Center(child: ConstrainedBox(...)))`), чтобы safe-area отступы не потерялись.

- [ ] **Step 4: flutter analyze всех 4 файлов**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/feature/detail_page/view/pages/detail_page.dart lib/src/feature/edit/view/page/edit_page.dart lib/src/feature/fermers/view/pages/fermer_create_page.dart lib/src/feature/fermers/view/pages/fermer_edit_page.dart`
Expected: `No issues found!`

- [ ] **Step 5: Проверить на телефоне и планшете все 4 экрана**

Телефон — `getMaxContentWidth` возвращает `double.infinity`, форма выглядит идентично текущему состоянию. Планшет (portrait и landscape) — форма центрирована, не растянута на всю ширину, поля/дропдауны/кнопки читаемы, ничего не обрезано по краям.

- [ ] **Step 6: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/feature/detail_page/view/pages/detail_page.dart lib/src/feature/edit/view/page/edit_page.dart lib/src/feature/fermers/view/pages/fermer_create_page.dart lib/src/feature/fermers/view/pages/fermer_edit_page.dart
git commit -m "$(cat <<'EOF'
fix: constrain form width on wide screens (create/edit plantation, farmer)

Plantation and farmer create/edit forms stretched to full screen width
on tablets, making long single-column forms awkward to read. Body
wrapped in Center + ConstrainedBox(maxWidth: getMaxContentWidth) —
infinity on phones (no change), capped at 720-1200dp on wider screens.
Form content itself is unchanged, still single-column.
EOF
)"
```

---

### Task 6: Карта рисования полигона — боковая панель в landscape

**Files:**
- Modify: `lib/src/feature/google_map/view/pages/create_map_page.dart`

**Interfaces:**
- Consumes: `Responsive.shouldShowSidebar(BuildContext)` (Task 2), `CreateMapPageButtonWidgets({required CreateMapPageVm vm})` (существует, `lib/src/feature/google_map/view/widgets/create_map_page_button_widgets.dart` — принимает `vm`, не меняется), `CenterRulerWidget({required bool isDrawingMode})` (существует, самодостаточно оборачивает в `Center`, не меняется).
- Produces: ничего наружу — `CreateMapPage` остаётся тем же публичным виджетом с тем же конструктором `{required int farmerId}`.

Текущая структура `build()` (уже прочитана полностью, `create_map_page.dart:46-379`) — `Scaffold` с `appBar` (не трогаем) и `body: Stack(children: [GoogleMap, Positioned(легенда), Positioned(площадь), Positioned(loading), CenterRulerWidget(), Positioned(диалог плантации)])`, `floatingActionButton: CreateMapPageButtonWidgets(vm: vm)`.

- [ ] **Step 1: Добавить импорт Responsive**

В начало `lib/src/feature/google_map/view/pages/create_map_page.dart`:
```dart
import 'package:agro_employee_public/design_system/utils/responsive.dart';
```

- [ ] **Step 2: Извлечь легенду статусов в приватный метод виджет**

Текущий inline-код легенды (строки ~143-179 в текущем файле):
```dart
          Positioned(
            bottom: 100,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plantatsiyalar holati:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      'Tekshirilgan', design_colors.AppColors.success),
                  _buildLegendItem(
                      'Tekshirilmagan', design_colors.AppColors.warning),
                ],
              ),
            ),
          ),
```

Заменить телом метода (добавить рядом с существующим `_buildLegendItem` в классе `_CreateMapPageState`):
```dart
  Widget _buildLegendCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantatsiyalar holati:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('Tekshirilgan', design_colors.AppColors.success),
          _buildLegendItem('Tekshirilmagan', design_colors.AppColors.warning),
        ],
      ),
    );
  }
```

Тогда исходный `Positioned(...)`-блок легенды в `Stack` заменяется на:
```dart
          Positioned(
            bottom: 100,
            left: 16,
            child: _buildLegendCard(context),
          ),
```
(используется в portrait/compact-ветке ниже, Step 5).

- [ ] **Step 3: Извлечь индикатор площади в приватный метод**

Текущий inline-код (строки ~181-208):
```dart
          if (vm.drawingPoints.isNotEmpty && vm.drawingPoints.length >= 3)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${vm.getPolygonArea().toStringAsFixed(2)} га',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
```

Добавить метод:
```dart
  Widget _buildAreaCard(BuildContext context, CreateMapPageVm vm) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${vm.getPolygonArea().toStringAsFixed(2)} га',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
```

Исходный блок в `Stack` (compact-ветка) остаётся структурно тем же, но вызывает метод:
```dart
          if (vm.drawingPoints.isNotEmpty && vm.drawingPoints.length >= 3)
            Positioned(
              top: 16,
              left: 16,
              child: _buildAreaCard(context, vm),
            ),
```

- [ ] **Step 4: Собрать sidebar-панель (используется только в landscape/expanded+ ветке)**

Добавить новый приватный метод в `_CreateMapPageState`:
```dart
  Widget _buildSidePanel(BuildContext context, CreateMapPageVm vm) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      color: context.colors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLegendCard(context),
            const SizedBox(height: 16),
            if (vm.drawingPoints.isNotEmpty && vm.drawingPoints.length >= 3)
              _buildAreaCard(context, vm),
            if (vm.isLoadingNearby) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Plantatsiyalar yuklanmoqda...',
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textPrimary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            CreateMapPageButtonWidgets(vm: vm),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 5: Разделить корневой `build()` на compact- и sidebar-ветку**

Текущий `build()` (строки 46-379, полная структура уже известна из прочтения ранее) заканчивается:
```dart
      body: Stack(
        children: [
          GoogleMap(...),
          Positioned(/* легенда */),
          if (...) Positioned(/* площадь */),
          if (vm.isLoadingNearby) Positioned(/* loading */),
          CenterRulerWidget(isDrawingMode: vm.isDrawingMode),
          if (vm.showPlantationDialog && vm.selectedPlantation != null)
            Positioned(/* диалог плантации, весь текущий большой блок */),
        ],
      ),
      floatingActionButton: CreateMapPageButtonWidgets(vm: vm),
    );
  }
```

Заменить финальную часть `Scaffold(...)` (начиная от `body:` до закрывающего `);` метода `build`) на:
```dart
      body: Responsive.shouldShowSidebar(context)
          ? Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: vm.currentLocation ?? vm.uzbLatLng,
                          zoom: 10,
                        ),
                        onMapCreated: vm.onMapCreated,
                        mapType: MapType.satellite,
                        zoomControlsEnabled: false,
                        polylines: vm.polylines,
                        polygons: {
                          ...vm.regionBoundaries,
                          if (vm.arePolygonsVisible) ...vm.nearbyPolygons,
                          ...vm.polygons,
                        },
                        markers: vm.markers,
                        onCameraMove: vm.onClusterCameraMove,
                        onTap: vm.onTap,
                      ),
                      CenterRulerWidget(isDrawingMode: vm.isDrawingMode),
                      if (vm.showPlantationDialog &&
                          vm.selectedPlantation != null)
                        _buildPlantationDialog(context, vm),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                _buildSidePanel(context, vm),
              ],
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.currentLocation ?? vm.uzbLatLng,
                    zoom: 10,
                  ),
                  onMapCreated: vm.onMapCreated,
                  mapType: MapType.satellite,
                  zoomControlsEnabled: false,
                  polylines: vm.polylines,
                  polygons: {
                    ...vm.regionBoundaries,
                    if (vm.arePolygonsVisible) ...vm.nearbyPolygons,
                    ...vm.polygons,
                  },
                  markers: vm.markers,
                  onCameraMove: vm.onClusterCameraMove,
                  onTap: vm.onTap,
                ),
                Positioned(
                  bottom: 100,
                  left: 16,
                  child: _buildLegendCard(context),
                ),
                if (vm.drawingPoints.isNotEmpty && vm.drawingPoints.length >= 3)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildAreaCard(context, vm),
                  ),
                if (vm.isLoadingNearby)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Plantatsiyalar yuklanmoqda...',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                CenterRulerWidget(isDrawingMode: vm.isDrawingMode),
                if (vm.showPlantationDialog && vm.selectedPlantation != null)
                  _buildPlantationDialog(context, vm),
              ],
            ),
      floatingActionButton: Responsive.shouldShowSidebar(context)
          ? null
          : CreateMapPageButtonWidgets(vm: vm),
    );
  }
```

**Важно**: `GoogleMap(...)` конфигурация дублируется буквально идентично в обеих ветках (sidebar/compact) — это осознанно, не рефакторить в общий метод в рамках этой задачи (YAGNI, `GoogleMap` не параметризуется по-разному между ветками, просто позиционируется в разных родителях `Stack`/`Row`).

- [ ] **Step 6: Извлечь блок диалога плантации в метод `_buildPlantationDialog`**

Текущий блок (строки ~256-374 в исходном файле, весь `Positioned(top: 24, left: 16, right: 16, child: Material(...))` с содержимым карточки фермера/чипами) — извлечь как есть в метод:
```dart
  Widget _buildPlantationDialog(BuildContext context, CreateMapPageVm vm) {
    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          design_colors.AppColors.primary,
                          design_colors.AppColors.primaryDark,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      vm.selectedPlantation!
                              .getDisplayFarmerName()
                              .trim()
                              .isNotEmpty
                          ? vm.selectedPlantation!.getDisplayFarmerName()
                          : 'Plantatsiya #${vm.selectedPlantation!.id}',
                      style: AppTypography.headlineMedium(context)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.closePlantationDialog,
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildChip(
                    context,
                    label: 'ID',
                    value: '${vm.selectedPlantation!.id}',
                    icon: Icons.numbers,
                  ),
                  _buildChip(
                    context,
                    label: 'Maydon',
                    value: vm.selectedPlantation!.getDisplayArea(),
                    icon: Icons.landscape_outlined,
                  ),
                  _buildChip(
                    context,
                    label: 'Status',
                    value: vm.selectedPlantation!.isChecked
                        ? 'Tekshirilgan'
                        : 'Tekshirilmagan',
                    icon: vm.selectedPlantation!.isChecked
                        ? Icons.verified_outlined
                        : Icons.hourglass_bottom_outlined,
                    color: vm.selectedPlantation!.isChecked
                        ? design_colors.AppColors.success
                        : design_colors.AppColors.warning,
                  ),
                  if (vm.selectedPlantation!
                      .getDisplayKonturNumbers()
                      .trim()
                      .isNotEmpty)
                    _buildChip(
                      context,
                      label: 'Kontur',
                      value: vm.selectedPlantation!.getDisplayKonturNumbers(),
                      icon: Icons.schema_outlined,
                    ),
                  _buildChip(
                    context,
                    label: 'Nuqtalar',
                    value: '${vm.selectedPlantation!.coordinates.length} ta',
                    icon: Icons.straighten_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
```
(Идентично существующему содержимому — просто перенесено из inline в именованный метод, чтобы использоваться в обеих ветках `Step 5` без дублирования большого блока.)

- [ ] **Step 7: flutter analyze**

Run: `cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile" && flutter analyze lib/src/feature/google_map/view/pages/create_map_page.dart`
Expected: `No issues found!`

- [ ] **Step 8: Проверить полный флоу рисования полигона на планшете в landscape**

На `Pixel_Tablet` эмуляторе в landscape: открыть создание плантации → карта занимает левую часть, боковая панель справа с легендой/площадью/кнопками (`+`/undo/локация). Добавить минимум 3 точки через кнопку `+` в панели, убедиться что:
- крестик (`CenterRulerWidget`) виден по центру именно карты (не всего экрана, включая панель),
- `addPointAtRulerPosition` ставит точку в ожидаемом месте (координаты считаются от `GoogleMapController.getVisibleRegion()`, не от размеров экрана — должно работать корректно и с уменьшенной картой),
- undo убирает последнюю точку,
- snap-to-edge к существующему полигону работает (если рядом с уже созданной плантацией),
- при тапе на существующую плантацию открывается диалог (`_buildPlantationDialog`) поверх карты (не панели),
- кнопка "Keyingi" в AppBar (не изменённая в этой задаче) по-прежнему переходит на detail_page с координатами.

Дополнительно проверить portrait на планшете (medium — `shouldShowSidebar == false`) и оба телефонных эмулятора — layout должен остаться прежним (`Stack` + `floatingActionButton`), без регрессии.

- [ ] **Step 9: Commit**

```bash
cd "c:\Users\aod1\Desktop\geo agro\mobilka\GeoAgro-Mobile"
git add lib/src/feature/google_map/view/pages/create_map_page.dart
git commit -m "$(cat <<'EOF'
feat: side panel layout for polygon-drawing map in tablet landscape

On expanded+ width (Responsive.shouldShowSidebar), the legend/area/
point-controls FAB stack — previously all Positioned over the map —
moves into a fixed-width side panel next to the map instead of
floating on top of it, which wasted a lot of otherwise-usable map area
on tablets in landscape. Legend, area indicator, and the plantation
detail dialog extracted into named methods (_buildLegendCard,
_buildAreaCard, _buildPlantationDialog) to share between the two
layout branches without duplicating large blocks. Phone and
tablet-portrait layouts are unchanged (compact Stack + FAB branch).
CenterRulerWidget stays centered on the map's own Stack in the sidebar
layout, not the full screen.
EOF
)"
```

---

## Self-Review Notes

- **Spec coverage**: все 6 пунктов из спеки (`docs/superpowers/specs/2026-07-17-tablet-adaptation-design.md`) покрыты задачами 1:1 (Task 1 = clamp, Task 2 = навигация, Task 3+4 = списки, Task 5 = формы, Task 6 = карта).
- **Порядок задач** соответствует "Порядок реализации" спеки (клэмп первым, карта последней — самая рискованная).
- Каждая задача независимо тестируема на существующих трёх эмуляторах (`emulator-5554`/Pixel 3a или 9 Pro, `Pixel_Tablet` portrait+landscape) без зависимости от более поздних задач.
- `Responsive` класс используется как есть, ни одного изменения в `lib/design_system/utils/responsive.dart` не требуется ни в одной задаче.
