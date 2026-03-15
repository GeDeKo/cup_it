import 'jury_models.dart';

class ChartDataFactory {
  const ChartDataFactory();

  List<double> normalize(List<double> values) {
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return values.map((_) => 0.0).toList();
    return values.map((v) => v / max).toList();
  }

  List<double> adaptiveLine(List<JuryLinePoint> points) =>
      points.map((e) => e.adaptive).toList();

  List<double> classicLine(List<JuryLinePoint> points) =>
      points.map((e) => e.classic).toList();
}
