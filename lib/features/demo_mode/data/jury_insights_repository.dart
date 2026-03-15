import '../domain/jury_models.dart';

class JuryInsightsRepository {
  const JuryInsightsRepository();

  List<KpiModel> kpis() => const [
    KpiModel(
      title: 'Скорость поиска действия',
      value: '-29%',
      delta: '+11 п.п.',
    ),
    KpiModel(title: 'Оценка удобства витрины', value: '+24%', delta: '+8 п.п.'),
    KpiModel(title: 'Вовлеченность (WAU/MAU)', value: '+17%', delta: '+5 п.п.'),
    KpiModel(
      title: 'Просмотр релевантных продуктов',
      value: '+21%',
      delta: '+7 п.п.',
    ),
  ];

  List<SurveyResultModel> surveys() => const [
    SurveyResultModel(
      question: 'Сложно быстро найти нужную функцию в банке',
      percent: 63,
    ),
    SurveyResultModel(
      question: 'Главный экран банковского приложения перегружен',
      percent: 58,
    ),
    SurveyResultModel(
      question: 'Подросткам важен современный персональный интерфейс',
      percent: 72,
    ),
    SurveyResultModel(
      question: 'Родителям важно скрывать взрослые продукты детям',
      percent: 69,
    ),
    SurveyResultModel(
      question: 'Идея адаптивной витрины воспринимается положительно',
      percent: 76,
    ),
  ];

  List<ComparisonRowModel> comparisonRows() => const [
    ComparisonRowModel(
      metric: 'Время до целевого действия',
      classicBank: '2 мин 50 сек',
      adaptiveBank: '1 мин 58 сек',
    ),
    ComparisonRowModel(
      metric: 'Среднее число переходов',
      classicBank: '6.1 шага',
      adaptiveBank: '3.9 шага',
    ),
    ComparisonRowModel(
      metric: 'Релевантность предложений',
      classicBank: 'Низкая',
      adaptiveBank: 'Высокая',
    ),
    ComparisonRowModel(
      metric: 'Понятность для детей и подростков',
      classicBank: 'Нестабильная',
      adaptiveBank: 'Высокая',
    ),
  ];

  List<JuryLinePoint> engagementLine() => const [
    JuryLinePoint(label: 'М1', classic: 42, adaptive: 42),
    JuryLinePoint(label: 'М2', classic: 43, adaptive: 47),
    JuryLinePoint(label: 'М3', classic: 41, adaptive: 49),
    JuryLinePoint(label: 'М4', classic: 40, adaptive: 51),
    JuryLinePoint(label: 'М5', classic: 42, adaptive: 54),
  ];

  List<double> prioritiesPie() => const [28, 24, 30, 18];
  List<String> prioritiesLabels() => const [
    'Безопасность детей',
    'Самостоятельность подростков',
    'Контроль взрослых',
    'Бизнес-эффективность',
  ];

  List<double> funnelClassic() => const [100, 74, 52, 39];
  List<double> funnelAdaptive() => const [100, 81, 66, 55];
}
