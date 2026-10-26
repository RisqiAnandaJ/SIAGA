/// Menyamarkan nomor untuk tampilan: "+62 8••••••123". Nomor yang tidak
/// berformat digit dikembalikan apa adanya.
String maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (!phone.startsWith('+62') || digits.length < 11) return phone;
  final national = digits.substring(2);
  final tail = national.substring(national.length - 3);
  return '+62 ${national[0]}${'•' * (national.length - 4)}$tail';
}

/// Menormalkan nomor handphone Indonesia ke format `+62...`.
/// Mengembalikan `null` bila bukan nomor yang valid (9–12 digit setelah +62).
String? normalizeIndonesianPhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length < 9 || digits.length > 12) return null;
  if (!digits.startsWith('8')) return null;
  return '+62$digits';
}
