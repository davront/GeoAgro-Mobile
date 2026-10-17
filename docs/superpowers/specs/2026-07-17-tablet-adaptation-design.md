# Дизайн: адаптация GeoAgro Mobile под планшеты

## Контекст

Приложение (Flutter, Android-only, package `agro_employee_public`) сейчас спроектировано
исключительно под телефон:

- **Скейлинг**: `flutter_screenutil` (`ScreenUtilInit`, `designSize: Size(375, 812)`,
  `custom_screen_util.dart`) масштабирует все `.sp`/`.w`/`.h`-значения линейно от ширины
  экрана. На 10" планшете (768–1280dp) это даёт шрифты/кнопки в 2–3 раза крупнее задуманного.
  `.sp`/`.w`/`.h` используются в сотнях мест по всему UI-коду.
- **Layout**: списки — одна колонка на всю ширину (`ListView.separated` на главной,
  `Column`+`List.generate` на странице фермеров). Формы растягиваются на всю ширину экрана.
  Карта рисования полигона — `Stack` с крестиком в центре экрана, FAB-кнопками (`+`/undo/
  локация) в правом нижнем углу, легендой статусов слева-снизу, площадью полигона
  сверху-слева — все поверх карты.
- **Навигация**: `HomePage` использует `NavigationBar` (bottom nav, 4 вкладки) — стандарт
  для телефона, съедает вертикальное пространство на широких экранах.
- Приложение **не зафиксировано на portrait** в `AndroidManifest.xml` — уже сейчас может
  открыться в landscape на планшете, просто без адаптации.
- Существует **`lib/design_system/utils/responsive.dart`** — полноценный класс с
  breakpoints (Material Design 3: compact/medium/expanded/large/extraLarge),
  `isTablet`/`isDesktop`, `getGridColumns`, `getMaxContentWidth`, `shouldShowSidebar`,
  `value<T>()` и т.д. **Нигде не используется** — мёртвый код, ни одного вызова в проекте.

## Цель

Приложение должно корректно работать на любых Android-планшетах, в portrait и landscape,
не только растягиваясь, но перестраивая layout там, где это осмысленно (списки, навигация,
карта рисования). landscape — основной проектируемый режим для планшетов (не только
"должен не ломаться").

## Approach

Активируем существующий `Responsive` класс как единственный источник правды о breakpoints
(не создаём второй похожий механизм). Клэмпим `ScreenUtil`, чтобы он не масштабировал
пропорции линейно за пределы разумного на широких экранах — вместо переписывания всех
`.sp`/`.w`/`.h`-мест по отдельности. Точечно перестраиваем 4 областей layout, где просто
растягивание объективно ломает UX: списки, навигация, формы, карта рисования.

## Компоненты

### 1. Клэмп ScreenUtil (`custom_screen_util.dart`)

`ScreenUtilInit.designSize` остаётся `375×812` (менять — значит пересчитывать все текущие
`.sp`/`.w`/`.h` значения по всему проекту, неоправданный риск регрессий на телефоне).
Вместо этого оборачиваем `MediaQuery` перед `ScreenUtilInit`, подменяя эффективный размер
экрана, который видит `ScreenUtil`, — клэмпим ширину/высоту сверху константой (например
`600×960` — примерно medium breakpoint), когда реальный экран шире. `ScreenUtil` продолжает
считать себя на "телефоне" даже на планшете, весь существующий `.sp`/`.w`/`.h` код
получает разумные абсолютные значения без изменений в вызывающих местах.

Технически: `MediaQuery(data: MediaQuery.of(context).copyWith(size: clampedSize), child:
ScreenUtilInit(...))` — обёртка одним слоем в `custom_screen_util.dart`, без сайд-эффектов
на остальной код.

### 2. `Responsive` — подключаем существующий класс

Не создаём новый API. Используем как есть: `Responsive.isTablet`, `Responsive.shouldShowSidebar`,
`Responsive.getGridColumns`, `Responsive.getMaxContentWidth`. Никаких изменений в самом
`responsive.dart` не требуется — он уже полный.

### 3. Навигация: `HomePage` — `NavigationBar` ↔ `NavigationRail`

`lib/src/feature/home/view/pages/home_page.dart` — `build()` уже возвращает `Scaffold` с
`bottomNavigationBar: NavigationBar(...)`. Оборачиваем корневой layout в проверку
`Responsive.shouldShowSidebar(context)`:
- **false** (телефон, compact/medium portrait) — текущее поведение, `NavigationBar` внизу.
- **true** (expanded+, обычно planшет landscape) — `Row(NavigationRail(...), Expanded(body))`,
  `bottomNavigationBar: null`. `NavigationRail` использует те же 4 destinations/иконки/labels,
  `selectedIndex`/`onDestinationSelected` — та же логика, что сейчас у `NavigationBar`
  (`_selectedIndex`, `_builtTabs`, `_loadTabData`).

### 4. Списки → grid на широких экранах

**Главная (`home_page.dart`, `vm.plantationsList`)**: `ListView.separated`
(`itemBuilder`/`separatorBuilder`) заменяется на `GridView.builder` при
`Responsive.getGridColumns(context) > 1`, иначе остаётся текущий `ListView.separated` —
условная ветка внутри `_buildContent`, не два параллельных виджета. `crossAxisCount:
Responsive.getGridColumns(context)`, `childAspectRatio` подбирается под текущую высоту
карточки (`HomePageCardWidget`) в конкретном breakpoint — не берётся из
`Responsive.getGridAspectRatio` слепо (та эвристика общая, карточка плантации может не
влезать/иметь лишний voids — подгоняется по месту при реализации).

**Фермеры (`fermers_page.dart`, `_FarmersList`)**: тот же паттерн — `List.generate` внутри
`Column` заменяется на `GridView.builder` (или `Wrap`, если проще сохранить текущий
non-scrollable-родитель `SingleChildScrollView`) при colCount > 1.

Load-more индикатор (текущий `CircularProgressIndicator` последним элементом списка) в grid-
режиме — на всю ширину под сеткой (`Column: [Grid, LoadMoreIndicator]`), не как элемент сетки.

**Column count**: 2 при `Responsive.isMedium` (600–1200dp — типичный planшет portrait и
многие landscape),
3 при `Responsive.isExpanded`+ (1200dp+ — крупный planшет landscape). Разные пороги для
grid (600dp, `!isCompact`) и для навигации/карты (1200dp, `shouldShowSidebar`) — намеренно:
плотность контента (списки) уместна раньше, чем перестройка структуры навигации.

### 5. Формы — ограничение ширины, не многоколоночность

`detail_page.dart` (create), `edit_page.dart` (edit), `fermer_create_page.dart`,
`fermer_edit_page.dart` — корневой скроллящийся контент формы оборачивается в
`Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth:
Responsive.getMaxContentWidth(context)), child: <текущее тело формы>))`. На телефоне
`getMaxContentWidth` возвращает `double.infinity` — поведение не меняется. На планшете
контент центрируется и не растягивается на всю ширину, поля/дропдауны/кнопки остаются
одноколоночными как сейчас — просто не занимают неоправданную ширину.

### 6. Карта рисования полигона — landscape-перестройка

`create_map_page.dart` — `Stack` с `GoogleMap` на всю область + `Positioned`-виджетами
поверх (`CenterRulerWidget`, легенда статусов, площадь, loading-индикатор,
`CreateMapPageButtonWidgets` как `floatingActionButton`).

На `Responsive.shouldShowSidebar(context)` (expanded+ — planшет landscape) перестраиваем в
`Row`:
- Слева/основная область: `GoogleMap` на всю доступную ширину (без FAB/легенды/площади
  поверх — эти элементы уезжают в панель).
- Справа: вертикальная панель фиксированной ширины (~280–320dp) с легендой статусов,
  индикатором площади (`${vm.getPolygonArea()} га`), кнопками `CreateMapPageButtonWidgets`
  (уже не `floatingActionButton`, а обычные виджеты внутри панели — тот же `vm`, тот же
  `onPressed`).

`CenterRulerWidget` остаётся привязан к центру **карты** (не всего экрана) — после
перестройки в `Row` карта занимает не всю ширину `Scaffold`, крестик должен позиционироваться
относительно своего `GoogleMap`-контейнера, не глобального `Positioned` внутри
корневого `Stack`. Реализуется через `Stack` внутри самого map-контейнера в `Row`, а не
через корневой `Stack` всей страницы.

Диалог с информацией о плантации (`showPlantationDialog`) — остаётся `Positioned` поверх
карты в обоих режимах (модальный, не часть постоянного layout).

На телефоне/portrait `shouldShowSidebar == false` — весь текущий код страницы не меняется
(тот же `Stack`, та же структура).

## Порядок реализации

1. Клэмп `ScreenUtil` (`custom_screen_util.dart`) — низкий риск, влияет на все экраны сразу,
   первым делом проверяется на телефонном эмуляторе на регрессию (ничего не должно
   визуально измениться на телефоне).
2. `HomePage` навигация (`NavigationBar`↔`NavigationRail`).
3. Grid для списков (главная, фермеры).
4. Формы — `ConstrainedBox` maxWidth.
5. Карта рисования — landscape `Row`-перестройка (самый сложный и рискованный пункт,
   последним).

## Верификация

- `flutter analyze` после каждого пункта.
- Ручная проверка на всех трёх эмуляторах (Pixel 3a/9 Pro — телефоны, регрессия; Pixel
  Tablet — planшет portrait И landscape) для каждого изменённого экрана.
- Явно сверить: телефонный layout не изменился визуально после клэмпа ScreenUtil (пункт 1)
  — это самый рискованный шаг, ошибка тут бьёт по всем экранам разом.
- Карта рисования: пройти полный флоу рисования полигона (добавление точек, undo, snap-to-
  edge, финальный сабмит) в landscape на planшете — панель сбоку не должна ломать
  существующую логику `addPointAtRulerPosition`/`_updateDrawingElements` (координаты
  крестика считаются от `GoogleMapController.getVisibleRegion()`, не от экрана — должно
  работать корректно и с уменьшенной картой, но проверить обязательно).
