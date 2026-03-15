import 'jury_models.dart';

class JuryChartsFactory {
  const JuryChartsFactory();

  double normalized(int percent) => (percent / 100).clamp(0.0, 1.0);

  double maxLineValue(List<JuryLinePoint> points) {
    if (points.isEmpty) return 1;
    final values = <double>[
      ...points.map((p) => p.classic),
      ...points.map((p) => p.adaptive),
    ];
    return values.reduce((a, b) => a > b ? a : b);
  }
}
