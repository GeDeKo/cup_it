const http = require('http');
const { randomUUID } = require('crypto');

const PORT = Number(process.env.PORT || 8080);
const CONFIRM_THRESHOLD = 50000;
const CONFIRM_CODE = '0000';

const usersByPhone = new Map();
const tokens = new Map();

function send(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  });
  res.end(JSON.stringify(body));
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1_000_000) reject(new Error('Body too large'));
    });
    req.on('end', () => {
      if (!data) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(data));
      } catch {
        reject(new Error('Invalid JSON'));
      }
    });
    req.on('error', reject);
  });
}

function iso(days = 0) {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();
}

function newState(name) {
  return {
    user: {
      id: randomUUID(),
      name,
      tier: 'Premium',
      cashbackLevel: '2.5%',
    },
    account: {
      id: 'acc-main',
      balance: 248000,
      available: 241500,
      currency: '₽',
    },
    security: {
      dailyTransferLimit: 300000,
      dailyPaymentLimit: 250000,
      transferSpentToday: 0,
      paymentSpentToday: 0,
    },
    cards: [
      {
        id: 'card-black',
        title: 'Премиум Металл',
        panMasked: '•••• 2217',
        balance: 121500,
        type: 'дебетовая',
        format: 'широкая',
        gradient: ['#142D8B', '#1D8AD8'],
        frozen: false,
      },
      {
        id: 'card-neo',
        title: 'Ежедневная',
        panMasked: '•••• 6432',
        balance: 72000,
        type: 'дебетовая',
        format: 'скругленная',
        gradient: ['#1A6FB8', '#5BC6FF'],
        frozen: false,
      },
      {
        id: 'card-credit',
        title: 'Гибкий кредит',
        panMasked: '•••• 0504',
        balance: -18500,
        type: 'кредитная',
        format: 'компактная',
        gradient: ['#0D3A6F', '#4D9BE6'],
        frozen: false,
      },
    ],
    beneficiaries: [
      { id: 'b-1', name: 'Анна', phone: '+79995550101' },
      { id: 'b-2', name: 'Мама', phone: '+79995550102' },
      { id: 'b-3', name: 'Аренда', phone: '+79995550103' },
    ],
    paymentTemplates: [
      {
        id: 'p-1',
        title: 'ЖКУ',
        amount: 5400,
        dueInDays: 2,
        account: 'LS1234',
      },
      {
        id: 'p-2',
        title: 'Интернет',
        amount: 890,
        dueInDays: 4,
        account: 'ACC9201',
      },
      {
        id: 'p-3',
        title: 'Мобильная связь',
        amount: 900,
        dueInDays: 5,
        account: 'TEL7900',
      },
    ],
    paymentServices: [
      { id: 'srv-1', title: 'ЖКХ', category: 'Коммунальные' },
      { id: 'srv-2', title: 'Мобильная связь', category: 'Связь' },
      { id: 'srv-3', title: 'Интернет', category: 'Связь' },
      { id: 'srv-4', title: 'Штрафы ГИБДД', category: 'Госуслуги' },
      { id: 'srv-5', title: 'Налоги', category: 'Госуслуги' },
    ],
    subscriptions: [
      { id: 'sub-1', title: 'Музыка', amount: 299, enabled: true },
      { id: 'sub-2', title: 'Кино', amount: 699, enabled: true },
      { id: 'sub-3', title: 'Облако', amount: 189, enabled: false },
    ],
    loans: [
      {
        id: 'loan-1',
        title: 'Потребительский кредит',
        nextPayment: 12800,
        dueInDays: 6,
        remainingDebt: 486000,
      },
    ],
    deposits: [
      {
        id: 'dep-1',
        title: 'Накопительный +',
        amount: 160000,
        rate: 13.4,
        until: iso(180),
      },
    ],
    goals: [{ id: 'goal-1', title: 'Отпуск', target: 200000, current: 76000 }],
    offers: {
      cashback: [
        { id: 'cb-1', partner: 'Супермаркеты', percent: 7, active: true },
        { id: 'cb-2', partner: 'Такси', percent: 10, active: false },
      ],
      stocks: [
        { id: 'st-1', ticker: 'ГАЗП', name: 'Газпром', price: 181.3 },
        { id: 'st-2', ticker: 'СБЕР', name: 'Сбер', price: 319.2 },
      ],
    },
    portfolio: [
      { ticker: 'СБЕР', lots: 8, avgPrice: 302.2 },
      { ticker: 'ГАЗП', lots: 12, avgPrice: 175.0 },
    ],
    applications: [
      {
        id: 'app-1',
        type: 'Кредитная карта',
        status: 'В обработке',
        createdAt: iso(-2),
      },
    ],
    supportThread: [
      {
        id: 'm-1',
        author: 'support',
        text: 'Здравствуйте! Чем помочь?',
        time: iso(-1),
      },
    ],
    notifications: [
      {
        id: 'n-1',
        title: 'Платеж по кредиту через 6 дней',
        text: 'Рекомендуем оплатить заранее',
        read: false,
        time: iso(-1),
      },
    ],
    tx: [
      { id: 't-1', title: 'Покупки', amount: -9400, date: iso(-1) },
      { id: 't-2', title: 'Зарплата', amount: 140000, date: iso(-3) },
      { id: 't-3', title: 'ЖКУ', amount: -5400, date: iso(-5) },
    ],
    aiInsights: [
      {
        id: 'ai-1',
        title: 'Кофе по будням',
        description: 'Вы часто покупаете кофе по утрам. У партнера доступен повышенный кэшбэк.',
        category: 'Еда и напитки',
        expectedBenefit: 'До 780 ₽/мес',
      },
      {
        id: 'ai-2',
        title: 'Оптимизация подписок',
        description: 'У вас несколько регулярных списаний. Часть можно объединить в семейный тариф.',
        category: 'Подписки',
        expectedBenefit: 'Экономия до 520 ₽/мес',
      },
    ],
    merchantOffers: [
      {
        id: 'offer-1',
        merchant: 'Кофейня Бодро',
        category: 'Еда и напитки',
        cashbackPercent: 7,
        discountPercent: 0,
        until: iso(20),
      },
      {
        id: 'offer-2',
        merchant: 'Маркет Плюс',
        category: 'Супермаркеты',
        cashbackPercent: 5,
        discountPercent: 10,
        until: iso(14),
      },
    ],
    purchasePattern: {
      topCategory: 'Еда и напитки',
      monthlySpend: 18400,
      repeatingSubscriptions: 3,
    },
  };
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

const personaCatalog = {
  child: {
    name: 'Миша',
    tier: 'Юниор',
    cashbackLevel: 'до 5%',
    state: (() => {
      const s = newState('Миша');
      s.account.balance = 12800;
      s.account.available = 12800;
      s.cards = [
        {
          id: 'card-kid',
          title: 'Детская карта',
          panMasked: '•••• 3491',
          balance: 12800,
          type: 'дебетовая',
          format: 'детская',
          gradient: ['#0B75C9', '#7ACDFF'],
          frozen: false,
        },
      ];
      s.loans = [];
      s.deposits = [];
      s.paymentTemplates = [{ id: 'p-k-1', title: 'Кружок робототехники', amount: 1800, dueInDays: 3, account: 'KID-101' }];
      s.subscriptions = [{ id: 'sub-k-1', title: 'Музыка для детей', amount: 149, enabled: true }];
      s.goals = [
        { id: 'goal-k-1', title: 'Новый велосипед', target: 30000, current: 14200 },
        { id: 'goal-k-2', title: 'Конструктор', target: 9500, current: 4100 },
      ];
      s.offers.stocks = [];
      s.portfolio = [];
      s.applications = [];
      s.notifications = [
        { id: 'n-k-1', title: 'Лимит трат на неделю', text: 'Осталось 1 400 ₽ до конца недели', read: false, time: iso(-1) },
      ];
      s.tx = [
        { id: 't-k-1', title: 'Карманные деньги от родителя', amount: 3000, date: iso(-2) },
        { id: 't-k-2', title: 'Книжный магазин', amount: -890, date: iso(-3) },
        { id: 't-k-3', title: 'Школьная столовая', amount: -430, date: iso(-1) },
      ];
      s.aiInsights = [
        {
          id: 'ai-k-1',
          title: 'Выгодная покупка канцелярии',
          description: 'В магазине "Школьник" повышенный кэшбэк 6% по детской карте.',
          category: 'Учеба',
          expectedBenefit: 'До 300 ₽/мес',
        },
      ];
      s.merchantOffers = [
        { id: 'mo-k-1', merchant: 'Школьник', category: 'Учеба', cashbackPercent: 6, discountPercent: 8, until: iso(15) },
      ];
      s.purchasePattern = { topCategory: 'Учеба', monthlySpend: 3200, repeatingSubscriptions: 1 };
      return s;
    })(),
  },
  teen: {
    name: 'Лена',
    tier: 'Молодежный',
    cashbackLevel: 'до 8%',
    state: (() => {
      const s = newState('Лена');
      s.account.balance = 48600;
      s.account.available = 47400;
      s.cards = [
        {
          id: 'card-teen-main',
          title: 'Молодежная дебетовая',
          panMasked: '•••• 6621',
          balance: 47400,
          type: 'дебетовая',
          format: 'неоновая',
          gradient: ['#1B2A8A', '#00AEEF'],
          frozen: false,
        },
        {
          id: 'card-teen-virtual',
          title: 'Виртуальная карта',
          panMasked: '•••• 9904',
          balance: 6200,
          type: 'виртуальная',
          format: 'минимальная',
          gradient: ['#103E7B', '#42C7FF'],
          frozen: false,
        },
      ];
      s.loans = [];
      s.deposits = [];
      s.goals = [{ id: 'goal-t-1', title: 'Ноутбук для учебы', target: 90000, current: 32800 }];
      s.subscriptions = [
        { id: 'sub-t-1', title: 'Музыкальный сервис', amount: 299, enabled: true },
        { id: 'sub-t-2', title: 'Видеосервис', amount: 399, enabled: true },
      ];
      s.tx = [
        { id: 't-t-1', title: 'Пополнение от родителей', amount: 8000, date: iso(-4) },
        { id: 't-t-2', title: 'Маркетплейс', amount: -2900, date: iso(-2) },
        { id: 't-t-3', title: 'Кофейня', amount: -570, date: iso(-1) },
      ];
      s.aiInsights = [
        {
          id: 'ai-t-1',
          title: 'Вечерняя доставка',
          description: 'Вы часто заказываете еду после 19:00. У партнера действует скидка 15%.',
          category: 'Еда',
          expectedBenefit: 'До 950 ₽/мес',
        },
        {
          id: 'ai-t-2',
          title: 'Кэшбэк на транспорт',
          description: 'Подключите категорию "Транспорт" для возврата 7% на поездки.',
          category: 'Транспорт',
          expectedBenefit: 'До 420 ₽/мес',
        },
      ];
      s.merchantOffers = [
        { id: 'mo-t-1', merchant: 'ФудСити', category: 'Еда', cashbackPercent: 4, discountPercent: 15, until: iso(9) },
        { id: 'mo-t-2', merchant: 'ГородТранспорт', category: 'Транспорт', cashbackPercent: 7, discountPercent: 0, until: iso(30) },
      ];
      s.purchasePattern = { topCategory: 'Подписки и еда', monthlySpend: 12400, repeatingSubscriptions: 2 };
      return s;
    })(),
  },
  adult: {
    name: 'Илья',
    tier: 'Premium',
    cashbackLevel: '2.5%',
    state: newState('Илья'),
  },
  business: {
    name: 'Ольга ИП',
    tier: 'Бизнес',
    cashbackLevel: 'Партнерский',
    state: (() => {
      const s = newState('Ольга ИП');
      s.account.id = 'acc-business';
      s.account.balance = 1248000;
      s.account.available = 1173200;
      s.cards = [
        {
          id: 'card-b-1',
          title: 'Бизнес-карта',
          panMasked: '•••• 9012',
          balance: 386000,
          type: 'дебетовая',
          format: 'бизнес',
          gradient: ['#10223D', '#2B5F8F'],
          frozen: false,
        },
      ];
      s.beneficiaries = [
        { id: 'b-b-1', name: 'ООО Логистика', phone: '+79990001010' },
        { id: 'b-b-2', name: 'ИП Смирнов', phone: '+79990002020' },
      ];
      s.paymentTemplates = [
        { id: 'p-b-1', title: 'Налоги', amount: 84200, dueInDays: 5, account: 'TAX-2026' },
        { id: 'p-b-2', title: 'Зарплатный реестр', amount: 312000, dueInDays: 1, account: 'SAL-01' },
      ];
      s.subscriptions = [{ id: 'sub-b-1', title: 'CRM-сервис', amount: 4990, enabled: true }];
      s.loans = [];
      s.deposits = [{ id: 'dep-b-1', title: 'Овернайт', amount: 420000, rate: 11.4, until: iso(30) }];
      s.goals = [{ id: 'goal-b-1', title: 'Резерв на 3 месяца', target: 900000, current: 480000 }];
      s.offers.stocks = [];
      s.portfolio = [];
      s.applications = [{ id: 'app-b-1', type: 'Эквайринг', status: 'Одобрено', createdAt: iso(-10) }];
      s.tx = [
        { id: 't-b-1', title: 'Поступление от клиента', amount: 290000, date: iso(-1) },
        { id: 't-b-2', title: 'Оплата поставщику', amount: -124000, date: iso(-1) },
        { id: 't-b-3', title: 'Налоговый платеж', amount: -84200, date: iso(-3) },
      ];
      s.aiInsights = [
        {
          id: 'ai-b-1',
          title: 'Оптимизация закупок',
          description: 'По категории "Логистика" доступен партнерский кэшбэк 3% при оплате бизнес-картой.',
          category: 'Операционные расходы',
          expectedBenefit: 'До 18 000 ₽/мес',
        },
      ];
      s.merchantOffers = [
        { id: 'mo-b-1', merchant: 'ТопЛогистика', category: 'Логистика', cashbackPercent: 3, discountPercent: 5, until: iso(20) },
      ];
      s.purchasePattern = { topCategory: 'Операционные расходы', monthlySpend: 684000, repeatingSubscriptions: 4 };
      return s;
    })(),
  },
};

function applyPersona(user, personaId) {
  const persona = personaCatalog[personaId];
  if (!persona) return false;
  user.personaId = personaId;
  user.name = persona.name;
  user.state = clone(persona.state);
  user.state.user.name = persona.name;
  user.state.user.tier = persona.tier;
  user.state.user.cashbackLevel = persona.cashbackLevel;
  user.state.insights = buildInsightsForPersona(personaId, user.state);
  return true;
}

function buildInsightsForPersona(personaId, state) {
  if (personaId === 'child') {
    return [
      {
        id: 'i-k-1',
        title: 'Лимит недели почти исчерпан',
        reason: 'Осталось 1 400 ₽ на текущую неделю',
      },
      {
        id: 'i-k-2',
        title: 'Копилка растет по плану',
        reason: 'До цели «Новый велосипед» осталось 15 800 ₽',
      },
    ];
  }
  if (personaId === 'teen') {
    return [
      {
        id: 'i-t-1',
        title: 'Подписки выросли на 12%',
        reason: 'Проверьте повторяющиеся списания в этом месяце',
      },
      {
        id: 'i-t-2',
        title: 'Доступно с опекуном в отделении',
        reason: 'Кредитная карта для подростка оформляется только очно',
      },
    ];
  }
  if (personaId === 'business') {
    return [
      {
        id: 'i-b-1',
        title: 'Пик расходов в середине месяца',
        reason: 'Запланируйте платежный календарь и резерв ликвидности',
      },
      {
        id: 'i-b-2',
        title: 'Партнерский кэшбэк на логистику',
        reason: 'Можно вернуть до 18 000 ₽ в месяц',
      },
    ];
  }
  return [
    {
      id: 'i-a-1',
      title: 'Платеж по кредиту через 6 дней',
      reason: 'До следующего платежа осталось мало времени',
    },
    {
      id: 'i-a-2',
      title: 'Кэшбэк 10% на такси не активирован',
      reason: 'Категория часто встречается в ваших расходах',
    },
    {
      id: 'i-a-3',
      title: 'Цель «Отпуск» выполнена на 38%',
      reason: 'До цели осталось 124 000 ₽',
    },
  ];
}

function createUser({ name, phone, password, personaId = 'adult' }) {
  const user = { id: randomUUID(), name, phone, password, personaId, state: newState(name) };
  applyPersona(user, personaId);
  usersByPhone.set(phone, user);
  return user;
}

createUser({ name: 'Илья Демо', phone: '+79990000000', password: '123456', personaId: 'adult' });

function authUser(req) {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Bearer ')) return null;
  const token = header.slice(7);
  const userId = tokens.get(token);
  if (!userId) return null;
  return [...usersByPhone.values()].find((u) => u.id === userId) || null;
}

function pushTx(state, title, amount) {
  state.tx.unshift({
    id: `tx-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    title,
    amount,
    date: iso(),
  });
}

function pushNotification(state, title, text) {
  state.notifications.unshift({
    id: `n-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    title,
    text,
    read: false,
    time: iso(),
  });
}

function stockPriceByTicker(state, ticker) {
  const stock = state.offers.stocks.find((s) => s.ticker === ticker);
  return stock ? Number(stock.price) : null;
}

function overview(user) {
  const s = user.state;
  return {
    user: {
      id: user.id,
      name: user.name,
      phone: user.phone,
      tier: s.user.tier,
      cashbackLevel: s.user.cashbackLevel,
    },
    account: s.account,
    security: s.security,
    cards: s.cards,
    beneficiaries: s.beneficiaries,
    paymentTemplates: s.paymentTemplates,
    paymentServices: s.paymentServices,
    subscriptions: s.subscriptions,
    loans: s.loans,
    deposits: s.deposits,
    goals: s.goals,
    offers: s.offers,
    portfolio: s.portfolio,
    applications: s.applications,
    notifications: s.notifications,
    supportThread: s.supportThread,
    transactions: s.tx.slice(0, 80),
    insights: s.insights || [
      {
        id: 'i-1',
        title: 'Платеж по кредиту через 6 дней',
        reason: 'До следующего платежа осталось мало времени',
      },
      {
        id: 'i-2',
        title: 'Кэшбэк 10% на такси не активирован',
        reason: 'Категория часто встречается в ваших расходах',
      },
      {
        id: 'i-3',
        title: 'Цель «Отпуск» выполнена на 38%',
        reason: 'До цели осталось 124 000 ₽',
      },
    ],
    aiInsights: s.aiInsights || [],
    merchantOffers: s.merchantOffers || [],
    purchasePattern: s.purchasePattern || {
      topCategory: 'Повседневные расходы',
      monthlySpend: 0,
      repeatingSubscriptions: 0,
    },
  };
}

function updateAccount(state, delta) {
  state.account.balance += delta;
  state.account.available += delta;
}

function requireConfirmOrLimit({
  state,
  amount,
  kind,
  confirmCode,
  res,
}) {
  if (amount >= CONFIRM_THRESHOLD && confirmCode !== CONFIRM_CODE) {
    send(res, 428, {
      error: 'confirmation_required',
      message: `Для суммы от ${CONFIRM_THRESHOLD} требуется код подтверждения`,
      hintCode: CONFIRM_CODE,
    });
    return false;
  }

  if (kind === 'transfer') {
    if (state.security.transferSpentToday + amount > state.security.dailyTransferLimit) {
      send(res, 400, { error: 'transfer_limit_exceeded' });
      return false;
    }
  }

  if (kind === 'payment') {
    if (state.security.paymentSpentToday + amount > state.security.dailyPaymentLimit) {
      send(res, 400, { error: 'payment_limit_exceeded' });
      return false;
    }
  }

  return true;
}

function registerSpent(state, amount, kind) {
  if (kind === 'transfer') state.security.transferSpentToday += amount;
  if (kind === 'payment') state.security.paymentSpentToday += amount;
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    send(res, 200, { ok: true });
    return;
  }

  if (req.method === 'GET' && req.url === '/health') {
    send(res, 200, { ok: true, service: 'bank-mock-backend' });
    return;
  }

  if (req.method === 'POST' && req.url === '/auth/register') {
    try {
      const body = await parseBody(req);
      const name = String(body.name || '').trim();
      const phone = String(body.phone || '').trim();
      const password = String(body.password || '').trim();
      if (!name || !phone || !password) {
        send(res, 400, { error: 'Укажите имя, телефон и пароль' });
        return;
      }
      if (usersByPhone.has(phone)) {
        send(res, 409, { error: 'Пользователь уже существует' });
        return;
      }
      const personaId = String(body.personaId || 'adult');
      const user = createUser({ name, phone, password, personaId });
      const token = randomUUID();
      tokens.set(token, user.id);
      send(res, 201, { token, user: overview(user).user });
    } catch (e) {
      send(res, 400, { error: e.message });
    }
    return;
  }

  if (req.method === 'POST' && req.url === '/auth/login') {
    try {
      const body = await parseBody(req);
      const phone = String(body.phone || '').trim();
      const password = String(body.password || '').trim();
      const user = usersByPhone.get(phone);
      if (!user || user.password !== password) {
        send(res, 401, { error: 'Неверный логин или пароль' });
        return;
      }
      const token = randomUUID();
      tokens.set(token, user.id);
      send(res, 200, { token, user: overview(user).user });
    } catch (e) {
      send(res, 400, { error: e.message });
    }
    return;
  }

  if (req.method === 'POST' && req.url === '/auth/logout') {
    const user = authUser(req);
    if (!user) {
      send(res, 401, { error: 'Unauthorized' });
      return;
    }
    const token = (req.headers.authorization || '').slice(7);
    tokens.delete(token);
    send(res, 200, { ok: true });
    return;
  }

  if (req.method === 'POST' && req.url === '/auth/demo/switch') {
    try {
      const user = authUser(req);
      if (!user) {
        send(res, 401, { error: 'Не авторизован' });
        return;
      }
      const body = await parseBody(req);
      const personaId = String(body.personaId || '').trim();
      if (!applyPersona(user, personaId)) {
        send(res, 400, { error: 'Неизвестный демо-профиль' });
        return;
      }
      pushNotification(
        user.state,
        'Профиль переключен',
        `Активирован демо-профиль: ${user.name}`,
      );
      send(res, 200, { ok: true, user: overview(user).user });
    } catch (e) {
      send(res, 400, { error: e.message });
    }
    return;
  }

  const user = authUser(req);
  if (!user) {
    send(res, 401, { error: 'Не авторизован' });
    return;
  }

  if (req.method === 'GET' && req.url === '/bank/overview') {
    send(res, 200, overview(user));
    return;
  }

  if (req.method === 'GET' && req.url === '/bank/notifications') {
    send(res, 200, { notifications: user.state.notifications });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/notifications/read-all') {
    user.state.notifications.forEach((n) => {
      n.read = true;
    });
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'GET' && req.url === '/bank/support/thread') {
    send(res, 200, { thread: user.state.supportThread });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/support/message') {
    const body = await parseBody(req);
    const text = String(body.text || '').trim();
    if (!text) {
      send(res, 400, { error: 'text required' });
      return;
    }
    user.state.supportThread.push({
      id: `m-${Date.now()}`,
      author: 'client',
      text,
      time: iso(),
    });
    user.state.supportThread.push({
      id: `m-${Date.now() + 1}`,
      author: 'support',
      text: 'Принято, специалист подключится в течение 5 минут.',
      time: iso(),
    });
    pushNotification(user.state, 'Ответ поддержки', 'Вам ответили в чате поддержки');
    send(res, 200, { ok: true, thread: user.state.supportThread });
    return;
  }

  if (req.method === 'GET' && req.url === '/bank/security') {
    send(res, 200, { security: user.state.security });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/security/update') {
    const body = await parseBody(req);
    const transfer = Number(body.dailyTransferLimit || 0);
    const payment = Number(body.dailyPaymentLimit || 0);
    if (transfer <= 0 || payment <= 0) {
      send(res, 400, { error: 'invalid limits' });
      return;
    }
    user.state.security.dailyTransferLimit = transfer;
    user.state.security.dailyPaymentLimit = payment;
    pushNotification(user.state, 'Лимиты обновлены', 'Новые лимиты операций сохранены');
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'GET' && req.url === '/bank/applications') {
    send(res, 200, { applications: user.state.applications });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/applications/create') {
    const body = await parseBody(req);
    const type = String(body.type || '').trim();
    if (!type) {
      send(res, 400, { error: 'type required' });
      return;
    }
    user.state.applications.unshift({
      id: `app-${Date.now()}`,
      type,
      status: 'В обработке',
      createdAt: iso(),
    });
    pushNotification(user.state, 'Заявка создана', `Приняли заявку: ${type}`);
    send(res, 201, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/transfer') {
    const body = await parseBody(req);
    const amount = Number(body.amount || 0);
    const to = String(body.to || 'Получатель');
    const comment = String(body.comment || '').trim();
    if (amount <= 0) {
      send(res, 400, { error: 'amount must be > 0' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount,
        kind: 'transfer',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, amount, 'transfer');
    updateAccount(user.state, -amount);
    pushTx(user.state, `Перевод: ${to}${comment ? ' • ' + comment : ''}`, -amount);
    pushNotification(user.state, 'Перевод выполнен', `${money(amount)} → ${to}`);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/topup') {
    const body = await parseBody(req);
    const amount = Number(body.amount || 0);
    const source = String(body.source || 'Наличные');
    if (amount <= 0) {
      send(res, 400, { error: 'amount must be > 0' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, amount, 'payment');
    updateAccount(user.state, amount);
    pushTx(user.state, `Пополнение: ${source}`, amount);
    pushNotification(user.state, 'Пополнение счета', `${money(amount)} из ${source}`);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/payments/pay') {
    const body = await parseBody(req);
    const paymentId = String(body.paymentId || '');
    const item = user.state.paymentTemplates.find((p) => p.id === paymentId);
    if (!item) {
      send(res, 404, { error: 'payment not found' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount: item.amount,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, item.amount, 'payment');
    updateAccount(user.state, -item.amount);
    pushTx(user.state, `Оплата: ${item.title}`, -item.amount);
    pushNotification(user.state, 'Оплата проведена', `${item.title} • ${money(item.amount)}`);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/payments/custom') {
    const body = await parseBody(req);
    const title = String(body.title || 'Платеж');
    const amount = Number(body.amount || 0);
    const account = String(body.account || '');
    if (amount <= 0 || !account) {
      send(res, 400, { error: 'title/account/amount required' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, amount, 'payment');
    updateAccount(user.state, -amount);
    pushTx(user.state, `Оплата: ${title} (${account})`, -amount);
    pushNotification(user.state, 'Оплата проведена', `${title} • ${money(amount)}`);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/templates/create') {
    const body = await parseBody(req);
    const title = String(body.title || '').trim();
    const amount = Number(body.amount || 0);
    const account = String(body.account || '').trim();
    if (!title || amount <= 0 || !account) {
      send(res, 400, { error: 'title/account/amount required' });
      return;
    }
    user.state.paymentTemplates.unshift({
      id: `p-${Date.now()}`,
      title,
      amount,
      dueInDays: 7,
      account,
    });
    send(res, 201, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/subscriptions/toggle') {
    const body = await parseBody(req);
    const id = String(body.id || '');
    const target = user.state.subscriptions.find((s) => s.id === id);
    if (!target) {
      send(res, 404, { error: 'subscription not found' });
      return;
    }
    target.enabled = !target.enabled;
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/loans/pay') {
    const body = await parseBody(req);
    const loanId = String(body.loanId || '');
    const amount = Number(body.amount || 0);
    const loan = user.state.loans.find((l) => l.id === loanId);
    if (!loan || amount <= 0) {
      send(res, 400, { error: 'invalid loan/amount' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, amount, 'payment');
    updateAccount(user.state, -amount);
    loan.remainingDebt = Math.max(0, loan.remainingDebt - amount);
    loan.nextPayment = Math.max(0, loan.nextPayment - amount);
    pushTx(user.state, 'Платеж по кредиту', -amount);
    pushNotification(user.state, 'Кредит оплачен', money(amount));
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/deposits/open') {
    const body = await parseBody(req);
    const amount = Number(body.amount || 0);
    const termDays = Number(body.termDays || 365);
    if (amount <= 0) {
      send(res, 400, { error: 'amount must be > 0' });
      return;
    }
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, amount, 'payment');
    updateAccount(user.state, -amount);
    user.state.deposits.push({
      id: `dep-${Date.now()}`,
      title: 'Новый вклад',
      amount,
      rate: termDays >= 365 ? 14.2 : 13.6,
      until: iso(termDays),
    });
    pushTx(user.state, 'Открытие вклада', -amount);
    pushNotification(user.state, 'Вклад открыт', `${money(amount)} на ${termDays} дн.`);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/goals/create') {
    const body = await parseBody(req);
    const title = String(body.title || '').trim();
    const target = Number(body.target || 0);
    if (!title || target <= 0) {
      send(res, 400, { error: 'title/target required' });
      return;
    }
    user.state.goals.push({ id: `goal-${Date.now()}`, title, target, current: 0 });
    send(res, 201, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/goals/topup') {
    const body = await parseBody(req);
    const goalId = String(body.goalId || '');
    const amount = Number(body.amount || 0);
    const goal = user.state.goals.find((g) => g.id === goalId);
    if (!goal || amount <= 0) {
      send(res, 400, { error: 'invalid goal/amount' });
      return;
    }
    updateAccount(user.state, -amount);
    goal.current += amount;
    pushTx(user.state, `Пополнение цели: ${goal.title}`, -amount);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/cards/freeze') {
    const body = await parseBody(req);
    const cardId = String(body.cardId || '');
    const frozen = Boolean(body.frozen);
    const card = user.state.cards.find((c) => c.id === cardId);
    if (!card) {
      send(res, 404, { error: 'card not found' });
      return;
    }
    card.frozen = frozen;
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/cards/reissue') {
    const body = await parseBody(req);
    const cardId = String(body.cardId || '');
    const card = user.state.cards.find((c) => c.id === cardId);
    if (!card) {
      send(res, 404, { error: 'card not found' });
      return;
    }
    card.panMasked = `•••• ${Math.floor(1000 + Math.random() * 8999)}`;
    pushTx(user.state, `Перевыпуск карты: ${card.title}`, 0);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/offers/cashback/activate') {
    const body = await parseBody(req);
    const offerId = String(body.offerId || '');
    const offer = user.state.offers.cashback.find((o) => o.id === offerId);
    if (!offer) {
      send(res, 404, { error: 'offer not found' });
      return;
    }
    offer.active = true;
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/stocks/buy') {
    const body = await parseBody(req);
    const ticker = String(body.ticker || '');
    const lots = Number(body.lots || 1);
    const price = stockPriceByTicker(user.state, ticker);
    if (!price || lots <= 0) {
      send(res, 400, { error: 'invalid ticker/lots' });
      return;
    }
    const total = price * lots;
    if (
      !requireConfirmOrLimit({
        state: user.state,
        amount: total,
        kind: 'payment',
        confirmCode: body.confirmCode,
        res,
      })
    ) {
      return;
    }
    registerSpent(user.state, total, 'payment');
    updateAccount(user.state, -total);
    const pos = user.state.portfolio.find((p) => p.ticker === ticker);
    if (pos) {
      const totalLots = pos.lots + lots;
      pos.avgPrice = (pos.avgPrice * pos.lots + price * lots) / totalLots;
      pos.lots = totalLots;
    } else {
      user.state.portfolio.push({ ticker, lots, avgPrice: price });
    }
    pushTx(user.state, `Покупка акций ${ticker}`, -total);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  if (req.method === 'POST' && req.url === '/bank/stocks/sell') {
    const body = await parseBody(req);
    const ticker = String(body.ticker || '');
    const lots = Number(body.lots || 1);
    const price = stockPriceByTicker(user.state, ticker);
    const pos = user.state.portfolio.find((p) => p.ticker === ticker);
    if (!price || !pos || lots <= 0 || pos.lots < lots) {
      send(res, 400, { error: 'invalid sell request' });
      return;
    }
    const total = price * lots;
    pos.lots -= lots;
    if (pos.lots === 0) {
      user.state.portfolio = user.state.portfolio.filter((p) => p.ticker !== ticker);
    }
    updateAccount(user.state, total);
    pushTx(user.state, `Продажа акций ${ticker}`, total);
    send(res, 200, { ok: true, overview: overview(user) });
    return;
  }

  send(res, 404, { error: 'Not found' });
});

function money(amount) {
  return `${Math.round(amount)} ₽`;
}

server.listen(PORT, () => {
  console.log(`Bank mock backend running at http://localhost:${PORT}`);
});
