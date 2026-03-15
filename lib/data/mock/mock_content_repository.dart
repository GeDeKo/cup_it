import '../../core/segment/segment_models.dart';

class NamedMetric {
  const NamedMetric({required this.name, required this.value, this.delta = ''});

  final String name;
  final String value;
  final String delta;
}

class TimelineEntry {
  const TimelineEntry({required this.title, required this.subtitle, required this.status});

  final String title;
  final String subtitle;
  final String status;
}

class TransferTemplateItem {
  const TransferTemplateItem({required this.title, required this.target, required this.amount});

  final String title;
  final String target;
  final String amount;
}

class BusinessDocItem {
  const BusinessDocItem({required this.title, required this.number, required this.status});

  final String title;
  final String number;
  final String status;
}

class DemoAccountRepository {
  const DemoAccountRepository();

  List<String> personaIds() => const ['child', 'teen', 'adult', 'business', 'adult_travel', 'teen_gamer'];
}

class MockContentRepository {
  const MockContentRepository();

  List<NamedMetric> accountMetrics(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return const [
          NamedMetric(name: 'Карманные деньги', value: '12 800 ₽', delta: '+2 000 ₽ за неделю'),
          NamedMetric(name: 'Лимит недели', value: '1 400 ₽', delta: 'Осталось до понедельника'),
          NamedMetric(name: 'Целей в процессе', value: '2', delta: 'Одна близка к завершению'),
        ];
      case UserSegment.teen:
        return const [
          NamedMetric(name: 'Доступный баланс', value: '47 400 ₽', delta: '+8% к прошлому месяцу'),
          NamedMetric(name: 'Лимит карты', value: '30 000 ₽', delta: '73% использовано'),
          NamedMetric(name: 'Подписок', value: '2 активные', delta: 'Следующее списание через 3 дня'),
        ];
      case UserSegment.adult:
        return const [
          NamedMetric(name: 'Личный счет', value: '241 500 ₽', delta: '+11 200 ₽ за неделю'),
          NamedMetric(name: 'Накопления', value: '160 000 ₽', delta: 'Ставка 13.4%'),
          NamedMetric(name: 'Инвестпортфель', value: '2 позиции', delta: 'Оценка 53 400 ₽'),
        ];
      case UserSegment.business:
        return const [
          NamedMetric(name: 'Расчетный счет', value: '1 173 200 ₽', delta: 'Доступный остаток'),
          NamedMetric(name: 'Платежи на подписи', value: '2', delta: 'До 18:00 сегодня'),
          NamedMetric(name: 'Документы', value: '14 новых', delta: '4 требуют проверки'),
        ];
    }
  }

  List<TransferTemplateItem> transferTemplates(UserSegment segment) {
    if (segment == UserSegment.business) {
      return const [
        TransferTemplateItem(title: 'Поставщик: ТехСнаб', target: 'р/с 40702...', amount: '124 000 ₽'),
        TransferTemplateItem(title: 'Налоги УСН', target: 'КБК 182105...', amount: '84 200 ₽'),
        TransferTemplateItem(title: 'Зарплатный реестр', target: '24 сотрудника', amount: '312 000 ₽'),
      ];
    }
    return const [
      TransferTemplateItem(title: 'Мама', target: '+7 999 555-01-02', amount: '2 000 ₽'),
      TransferTemplateItem(title: 'Аренда', target: '+7 999 555-01-03', amount: '35 000 ₽'),
      TransferTemplateItem(title: 'Накопительный счет', target: 'Между своими счетами', amount: '10 000 ₽'),
    ];
  }

  List<String> frequentRecipients(UserSegment segment) {
    if (segment == UserSegment.business) {
      return const ['ООО Логистика', 'ИП Смирнов', 'ООО МаркетПро', 'Налоговая служба'];
    }
    return const ['Анна', 'Мама', 'Игорь', 'Карта супруга'];
  }

  List<TimelineEntry> supportFaq(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return const [
          TimelineEntry(title: 'Как попросить перевод у родителя?', subtitle: 'Откройте блок «Карманные деньги» и нажмите «Попросить перевод».', status: 'Популярно'),
          TimelineEntry(title: 'Почему нельзя оформить кредит?', subtitle: 'В детском режиме кредитные продукты не отображаются.', status: 'Важно'),
        ];
      case UserSegment.teen:
        return const [
          TimelineEntry(title: 'Как выпустить виртуальную карту?', subtitle: 'На экране «Карты» выберите выпуск виртуальной карты.', status: 'Популярно'),
          TimelineEntry(title: 'Как записаться в отделение с опекуном?', subtitle: 'В разделе «Путь ко взрослому банку» доступна запись.', status: 'С опекуном'),
        ];
      case UserSegment.adult:
        return const [
          TimelineEntry(title: 'Как изменить лимиты по карте?', subtitle: 'Перейдите в «Безопасность и лимиты».', status: 'Популярно'),
          TimelineEntry(title: 'Как подключить повышенный кэшбэк?', subtitle: 'Откройте «Выгодные предложения» и активируйте категорию.', status: 'Новый функционал'),
        ];
      case UserSegment.business:
        return const [
          TimelineEntry(title: 'Как выгрузить платежный реестр?', subtitle: 'Раздел «Бизнес-документы» -> «Выгрузить CSV».', status: 'Популярно'),
          TimelineEntry(title: 'Почему отмечена аномалия расходов?', subtitle: 'Сравниваем текущий месяц со средним значением за 3 периода.', status: 'Аналитика'),
        ];
    }
  }

  List<NamedMetric> securityWidgets(UserSegment segment) {
    if (segment == UserSegment.child) {
      return const [
        NamedMetric(name: 'Родительское подтверждение', value: 'Включено', delta: 'Для переводов выше 1 000 ₽'),
        NamedMetric(name: 'Онлайн-покупки', value: 'Ограничено', delta: 'Только доверенные магазины'),
      ];
    }
    if (segment == UserSegment.business) {
      return const [
        NamedMetric(name: '2FA сотрудников', value: '92%', delta: '22 из 24 сотрудников'),
        NamedMetric(name: 'Роли доступа', value: '4 конфликта', delta: 'Требуют обновления'),
      ];
    }
    return const [
      NamedMetric(name: 'Биометрия', value: 'Включено', delta: 'Face ID активен'),
      NamedMetric(name: 'Подозрительные входы', value: '0', delta: 'За последние 30 дней'),
    ];
  }

  List<BusinessDocItem> businessDocs() {
    return const [
      BusinessDocItem(title: 'Счет на оплату', number: 'СЧ-1192', status: 'Ожидает оплаты'),
      BusinessDocItem(title: 'Акт выполненных работ', number: 'АКТ-403', status: 'Подписан'),
      BusinessDocItem(title: 'Накладная', number: 'НКЛ-882', status: 'В обработке'),
      BusinessDocItem(title: 'Счет-фактура', number: 'СФ-220', status: 'Архив'),
    ];
  }

  List<NamedMetric> settingsSections(UserSegment segment) {
    if (segment == UserSegment.business) {
      return const [
        NamedMetric(name: 'Уведомления по платежам', value: 'Включено'),
        NamedMetric(name: 'Подписи и роли', value: '24 сотрудника'),
        NamedMetric(name: 'Язык интерфейса', value: 'Русский'),
      ];
    }
    return const [
      NamedMetric(name: 'Push-уведомления', value: 'Включено'),
      NamedMetric(name: 'Персональные офферы', value: 'Включено'),
      NamedMetric(name: 'Язык интерфейса', value: 'Русский'),
    ];
  }
}

class HomeContentFactory {
  const HomeContentFactory();
}

class AnalyticsRepository {
  const AnalyticsRepository();
}

class OffersRepository {
  const OffersRepository();
}

class LifestyleOfferRepository {
  const LifestyleOfferRepository();
}

class BusinessRepository {
  const BusinessRepository();
}

class FeatureAvailabilityRepository {
  const FeatureAvailabilityRepository();
}

class RecommendationRepository {
  const RecommendationRepository();
}

class NotificationsRepository {
  const NotificationsRepository();
}

class SupportRepository {
  const SupportRepository();
}

class SavingsRepository {
  const SavingsRepository();
}

class InvestmentsRepository {
  const InvestmentsRepository();
}

class ParentControlRepository {
  const ParentControlRepository();
}
