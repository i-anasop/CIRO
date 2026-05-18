// CIRO — Formatters Utility
// Shared helper functions for formatting data across all screens.

/// Formats a large integer with k/M suffix. e.g. 3200 → "3.2k"
String formatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}

/// Formats a DateTime to "HH:mm PKT"
String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m PKT';
}

/// Formats a DateTime to "DD MMM YYYY"
String formatDate(DateTime dt) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

/// Truncates a string to [maxLength] with ellipsis.
String truncate(String s, int maxLength) {
  if (s.length <= maxLength) return s;
  return '${s.substring(0, maxLength)}...';
}
