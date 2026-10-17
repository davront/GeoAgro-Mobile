import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

/// Базовый дизайн-размер — во сколько раз screenWidth/designSize.width
/// масштабирует все .sp/.w/.h в проекте.
const Size _kBaseDesignSize = Size(375, 812);

/// Выше этой физической ширины/высоты экрана designSize.width/height
/// растягивается вместе с реальным экраном (см. _effectiveDesignSize) —
/// так scaleWidth (screenWidth / designSize.width) и аналогично
/// scaleHeight перестают расти после порога вместо продолжения
/// линейного роста, и весь существующий .sp/.w/.h-код в проекте
/// (сотни мест, задуман под designSize 375x812) не раздувается на
/// планшете.
///
/// ВАЖНО: ширина и высота клэмпятся НЕЗАВИСИМО друг от друга, каждая
/// от своего физического размера — не общим ratio от ширины. Первая
/// версия этого фикса считала designSize.height через тот же ratio,
/// что и designSize.width (ratio = screenWidth/threshold); на
/// landscape-планшете (широкий, но физически невысокий экран, напр.
/// 1280x800) это раздувало designSize.height сильнее, чем реальная
/// высота экрана, давая scaleHeight < 1 — все .h-размеры (кнопки,
/// NavigationBar height, паддинги) визуально СЖИМАЛИСЬ в landscape
/// вместо роста вместе с текстом (.sp), что и проявлялось как "низкая
/// кнопка"/"иконки прижаты к верху".
///
/// ВАЖНО #2: flutter_screenutil (эта версия, 5.9.3) берёт физический
/// размер экрана напрямую через View.maybeOf(context) внутри самого
/// ScreenUtilInit — НЕ через BuildContext.dependOnInheritedWidgetOfExactType
/// (MediaQuery.of). Обёртка MediaQuery вокруг/внутри ScreenUtilInit
/// поэтому не оказывает на scale-расчёт никакого эффекта — единственный
/// рычаг влияния на масштаб есть designSize, отсюда его динамический
/// пересчёт вместо клэмпа MediaQuery.
const double _kWideScreenThreshold = 600;
const double _kTallScreenThreshold = 812;

class CustomScreenUtil extends StatelessWidget {
  final Widget child;
  final bool enabledPreview;

  const CustomScreenUtil({
    required this.child,
    required this.enabledPreview,
    super.key,
  });

  Size _effectiveDesignSize(BuildContext context) {
    // Тот же физический размер, что использует ScreenUtilInit внутри
    // себя (View.maybeOf) — MediaQuery здесь читается только чтобы
    // получить актуальные ширину/высоту экрана ДО того, как
    // ScreenUtilInit построится, не для влияния на его внутренний
    // расчёт.
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final designWidth = width <= _kWideScreenThreshold
        ? _kBaseDesignSize.width
        : _kBaseDesignSize.width * (width / _kWideScreenThreshold);
    final designHeight = height <= _kTallScreenThreshold
        ? _kBaseDesignSize.height
        : _kBaseDesignSize.height * (height / _kTallScreenThreshold);

    return Size(designWidth, designHeight);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _effectiveDesignSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      child: child,
    );
  }
}
