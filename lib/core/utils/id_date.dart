const _long = [
  '',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// "23 Oktober 2026 • 07.35 WIB" (waktu perangkat; WIB bila zona +7).
String formatLongDateTime(DateTime t) =>
    '${t.day} ${_long[t.month]} ${t.year} • ${_two(t.hour)}.${_two(t.minute)} WIB';

/// "23 Okt 2026, 07.30"
String formatShortDateTime(DateTime t) =>
    '${t.day} ${_long[t.month].substring(0, 3)} ${t.year}, ${_two(t.hour)}.${_two(t.minute)}';
