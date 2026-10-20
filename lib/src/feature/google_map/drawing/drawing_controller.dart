import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Состояние прицела: обновляется на каждом кадре движения карты и живёт
/// в ValueNotifier отдельно от точек, чтобы не перестраивать GoogleMap.
@immutable
class Crosshair {
  final CameraPosition camera;

  /// Ближайшая точка соседней границы (≤ 3 м), если прицел прилип к ней.
  final LatLng? snapTarget;

  const Crosshair(this.camera, this.snapTarget);

  /// Куда встанет точка по нажатию «+».
  LatLng get point => snapTarget ?? camera.target;
}

/// Единственный источник правды о вершинах рисуемого контура. Каждое
/// действие — один снимок в стеке undo, поэтому откатывается всё одной
/// кнопкой: лишняя точка, перенос вершины, очистка.
class DrawingController extends ChangeNotifier {
  List<LatLng> _points = const [];
  final List<List<LatLng>> _undo = [];
  final List<List<LatLng>> _redo = [];

  List<LatLng> get points => _points;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void _commit(List<LatLng> next) {
    _undo.add(_points);
    _redo.clear();
    _points = List.unmodifiable(next);
    notifyListeners();
  }

  void add(LatLng p) => _commit([..._points, p]);

  void moveTo(int index, LatLng p) {
    if (index < 0 || index >= _points.length) return;
    _commit([..._points]..[index] = p);
  }

  void clear() {
    if (_points.isEmpty) return;
    _commit(const []);
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_points);
    _points = _undo.removeLast();
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_points);
    _points = _redo.removeLast();
    notifyListeners();
  }
}
