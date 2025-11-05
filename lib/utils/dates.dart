String formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    final parts = value.split('-');
    if (parts.length == 3) {
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    }
    return DateTime.tryParse(value);
  } catch (_) {
    return null;
  }
}


