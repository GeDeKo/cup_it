class SurveyResultModel {
  const SurveyResultModel({required this.question, required this.percent});

  final String question;
  final int percent;
}

class KpiModel {
  const KpiModel({
    required this.title,
    required this.value,
    required this.delta,
  });

  final String title;
  final String value;
  final String delta;
}

class ComparisonRowModel {
  const ComparisonRowModel({
    required this.metric,
    required this.classicBank,
    required this.adaptiveBank,
  });

  final String metric;
  final String classicBank;
  final String adaptiveBank;
}

class JuryLinePoint {
  const JuryLinePoint({
    required this.label,
    required this.classic,
    required this.adaptive,
  });

  final String label;
  final double classic;
  final double adaptive;
}
