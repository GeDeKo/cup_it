String money(double amount) {
  final String sign = amount < 0 ? '-' : '';
  final String normalized = amount.abs().toStringAsFixed(0);
  final String grouped = normalized.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );
  return '$sign$grouped ₽';
}

String daysLabel(int days) {
  if (days == 0) {
    return 'сегодня';
  }
  if (days == 1) {
    return 'через 1 день';
  }
  return 'через $days дн.';
}
