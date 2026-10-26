import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siaga/main.dart';

Future<void> _pastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const SiagaApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Font uji (Ahem) membuat setiap huruf selebar tingginya, sehingga teks tampak
/// meluap di layar yang sebenarnya muat. Abaikan hanya overflow; galat lain
/// tetap menggagalkan pengujian.
void _ignoreOverflow() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

void main() {
  testWidgets('splash leads to login with generic error on empty submit', (
    tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pastSplash(tester);
    expect(find.text('Selamat datang kembali'), findsOneWidget);

    await tester.tap(find.text('Masuk').last);
    await tester.pump();
    expect(find.text('Username atau password salah'), findsOneWidget);
  });

  testWidgets('PAMDAL login shows home and dock navigates tabs', (
    tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pastSplash(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'budi.santoso');
    await tester.enterText(fields.at(1), 'rahasia123');
    await tester.tap(find.text('Masuk').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Selamat pagi, Budi'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);

    await tester.tap(find.text('Insiden'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Laporan kejadian saya'), findsOneWidget);

    await tester.tap(find.text('SOS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Darurat SOS'), findsOneWidget);
    expect(find.text('RS JMC'), findsOneWidget);
    expect(find.text('Polsek Pancoran'), findsOneWidget);
    expect(find.text('Damkar Kalibata'), findsOneWidget);
  });

  testWidgets('PIC login reaches dashboard with five dock tabs', (
    tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pastSplash(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'rina.pic');
    await tester.enterText(fields.at(1), 'rahasia123');
    await tester.tap(find.text('Masuk').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Kendali operasional'), findsOneWidget);
    for (final tab in [
      'Dashboard',
      'Operasional',
      'Insiden',
      'Personel',
      'Laporan',
    ]) {
      expect(find.text(tab), findsWidgets);
    }
  });

  testWidgets('patrol: grant permission starts patrol, stop returns to gate', (
    tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(430 * 2, 1400 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pastSplash(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'budi.santoso');
    await tester.enterText(fields.at(1), 'rahasia123');
    await tester.tap(find.text('Masuk').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Patroli GPS'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mulai patroli'), findsOneWidget);

    await tester.tap(find.text('Lanjutkan & izinkan lokasi'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Patroli berlangsung'), findsOneWidget);
    expect(find.text('PATROLI AKTIF'), findsOneWidget);

    await tester.tap(find.text('Hentikan patroli'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mulai patroli'), findsOneWidget);
  });

  testWidgets(
    'PIC registration queue: reject needs a reason, approve removes',
    (tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(430 * 2, 1800 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await _pastSplash(tester);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'rina.pic');
      await tester.enterText(fields.at(1), 'rahasia123');
      await tester.tap(find.text('Masuk').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Personel'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Antrean pendaftaran'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Dimas Pratama'), findsOneWidget);
      expect(find.text('Menunggu (3)'), findsOneWidget);

      // Tolak tanpa alasan -> galat inline.
      await tester.tap(find.text('Tolak pengajuan').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Tolak & kirim alasan'));
      await tester.pump();
      expect(find.text('Alasan penolakan wajib diisi'), findsOneWidget);

      // Dengan alasan -> pengajuan hilang dari antrean.
      await tester.enterText(find.byType(TextField).last, 'Data tidak sesuai');
      await tester.tap(find.text('Tolak & kirim alasan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Dimas Pratama'), findsNothing);
      expect(find.text('Menunggu (2)'), findsOneWidget);

      // Setujui -> pengajuan berikutnya hilang.
      await tester.tap(find.text('Tinjau & setujui').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Setujui & aktifkan akun'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Menunggu (1)'), findsOneWidget);
    },
  );
}
