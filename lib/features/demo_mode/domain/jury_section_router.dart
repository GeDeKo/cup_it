enum JurySection { overview, research, metrics }

class JurySectionRouter {
  const JurySectionRouter();

  String title(JurySection section) {
    switch (section) {
      case JurySection.overview:
        return 'Обзор';
      case JurySection.research:
        return 'Исследования';
      case JurySection.metrics:
        return 'Метрики';
    }
  }
}
