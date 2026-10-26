import 'package:flutter/material.dart';

import '../../core/services/auth_repository.dart';
import '../../core/services/registration_repository.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/utils/id_date.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../../models/registration_request.dart';

/// Antrean pendaftaran anggota baru.
class RegistrationQueuePage extends StatefulWidget {
  const RegistrationQueuePage({super.key});

  @override
  State<RegistrationQueuePage> createState() => _RegistrationQueuePageState();
}

class _RegistrationQueuePageState extends State<RegistrationQueuePage> {
  static const _filters = RegistrationFilter.values;

  int _tab = 0;
  bool _loading = true;
  String? _error;
  List<RegistrationRequest> _items = const [];
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = SessionScope.read(context).registrations;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await repo.list(_filters[_tab]);
      final pending = _tab == 0
          ? items.length
          : (await repo.list(RegistrationFilter.pending)).length;
      if (!mounted) return;
      setState(() {
        _items = items;
        _pendingCount = pending;
      });
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(RegistrationRequest r) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReviewRegistrationPage(request: r)),
    );
    if (done == true) _load();
  }

  Future<void> _reject(RegistrationRequest r) async {
    final done = await showRejectDialog(context, r);
    if (done == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Antrean pendaftaran',
      subtitle: '$_pendingCount pengajuan menunggu peninjauan',
      showDock: true,
      dockIndex: 3,
      showBack: true,
      children: [
        PillTabs(
          labels: ['Menunggu ($_pendingCount)', 'Disetujui', 'Ditolak'],
          index: _tab,
          onChanged: (i) {
            setState(() => _tab = i);
            _load();
          },
        ),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: SiagaColors.padiGold),
            ),
          )
        else if (_error != null)
          GlassCard(
            tone: GlassTone.danger,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: SiagaText.body),
                const SizedBox(height: 12),
                SiagaButton.ghost(label: 'Coba lagi', onPressed: _load),
              ],
            ),
          )
        else if (_items.isEmpty)
          Text(switch (_tab) {
            0 => 'Tidak ada pengajuan yang menunggu.',
            1 => 'Belum ada pengajuan yang disetujui.',
            _ => 'Belum ada pengajuan yang ditolak.',
          }, style: SiagaText.bodyMuted)
        else if (_tab == 0)
          for (final r in _items)
            ApplicantCard(
              request: r,
              onReview: () => _review(r),
              onReject: () => _reject(r),
            )
        else
          GlassCard(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                for (var i = 0; i < _items.length; i++)
                  InfoRow(
                    title: _items[i].fullName,
                    subtitle:
                        '${formatShortDateTime(_items[i].submittedAt)} • ${_items[i].requestedRole.label}',
                    body: _items[i].rejectionReason,
                    trailing: StatusPill(
                      _tab == 1 ? 'Disetujui' : 'Ditolak',
                      tone: _tab == 1 ? PillTone.success : PillTone.danger,
                    ),
                    last: i == _items.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.request,
    required this.onReview,
    required this.onReject,
  });

  final RegistrationRequest request;
  final VoidCallback onReview;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final role = r.requestedRole;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            title: r.fullName,
            subtitle: formatLongDateTime(r.submittedAt),
            trailing: StatusPill(
              role.label,
              tone: role == UserRole.pamdal
                  ? PillTone.success
                  : PillTone.warning,
            ),
          ),
          const StatusPill('Email terverifikasi', tone: PillTone.success),
          const SizedBox(height: 12),
          Text(
            'Peran diajukan: ${role.label} • buka profil untuk memeriksa data lengkap.',
            style: SiagaText.body.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          SiagaButton.gold(label: 'Tinjau & setujui', onPressed: onReview),
          const SizedBox(height: 12),
          SiagaButton.ghost(label: 'Tolak pengajuan', onPressed: onReject),
        ],
      ),
    );
  }
}

/// Tinjau identitas pemohon lalu setujui (peran dapat dikoreksi).
class ReviewRegistrationPage extends StatefulWidget {
  const ReviewRegistrationPage({super.key, required this.request});

  final RegistrationRequest request;

  @override
  State<ReviewRegistrationPage> createState() => _ReviewRegistrationPageState();
}

class _ReviewRegistrationPageState extends State<ReviewRegistrationPage> {
  late int _role = widget.request.requestedRole == UserRole.pamdal ? 0 : 1;
  bool _busy = false;
  String? _error;

  Future<void> _approve() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = widget.request;
    final role = _role == 0 ? UserRole.pamdal : UserRole.pimpinan;
    final session = SessionScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.registrations.approve(r.id, role: role);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${r.fullName} disetujui sebagai ${role.label}.'),
        ),
      );
      navigator.pop(true);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return MainPage(
      title: 'Review pendaftaran',
      subtitle:
          'Pengajuan ${r.fullName} • ${formatLongDateTime(r.submittedAt).split(' • ').first}',
      showDock: true,
      dockIndex: 3,
      showBack: true,
      children: [
        SectionCard(
          title: 'Identitas pemohon',
          children: [
            const StatusPill('Email terverifikasi', tone: PillTone.success),
            const SizedBox(height: 6),
            InfoRow(
              title: r.fullName,
              subtitle: 'Username: ${r.username}',
              chevron: true,
            ),
            InfoRow(
              title: r.email,
              subtitle: 'Nomor handphone: +62 • disamarkan',
              trailing: const Icon(Icons.mail_outline, size: 22),
            ),
            InfoRow(
              title: 'Peran diajukan: ${r.requestedRole.label}',
              subtitle: 'Diajukan ${formatShortDateTime(r.submittedAt)} WIB',
              chevron: true,
              last: true,
            ),
          ],
        ),
        const InfoBanner(
          title: 'Periksa kesesuaian penugasan',
          body:
              'Cocokkan identitas pemohon dan peran dengan daftar personel sebelum menyetujui akses.',
        ),
        SectionCard(
          title: 'Setujui pendaftaran?',
          tone: GlassTone.raised,
          children: [
            Text(
              'Akun ${r.fullName} akan diaktifkan dengan peran berikut.',
              style: SiagaText.bodyLarge.copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 14),
            Text('Koreksi peran jika diperlukan', style: SiagaText.label),
            const SizedBox(height: 8),
            PillTabs(
              labels: const ['PAMDAL', 'Pimpinan'],
              index: _role,
              onChanged: (i) => setState(() => _role = i),
              height: 54,
            ),
            const SizedBox(height: 12),
            Text(
              'Pemohon akan menerima pemberitahuan hasil peninjauan.',
              style: SiagaText.body.copyWith(fontSize: 13),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: SiagaText.bodyMuted.copyWith(
                  color: SiagaColors.dangerText,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SiagaButton.gold(
              label: _busy ? 'Memproses...' : 'Setujui & aktifkan akun',
              onPressed: _busy ? null : _approve,
            ),
            const SizedBox(height: 12),
            SiagaButton.ghost(
              label: 'Kembali ke review',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        Text(
          'Opsi Tolak membuka dialog terpisah dengan alasan wajib. Tidak ada penolakan dalam proses persetujuan ini.',
          style: SiagaText.bodyMuted.copyWith(fontSize: 12.5),
        ),
      ],
    );
  }
}

/// Dialog penolakan dengan alasan wajib. Mengirim penolakan ke backend dan
/// mengembalikan `true` bila berhasil.
Future<bool?> showRejectDialog(BuildContext context, RegistrationRequest r) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _RejectDialog(request: r),
  );
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog({required this.request});

  final RegistrationRequest request;

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'Alasan penolakan wajib diisi');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = SessionScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.registrations.reject(widget.request.id, _reason.text);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Pengajuan ${widget.request.fullName} ditolak. Alasan dikirim.',
          ),
        ),
      );
      navigator.pop(true);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: GlassCard(
          tone: GlassTone.raised,
          blur: true,
          blurSigma: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const StatusPill(
                'Alternatif • Tolak pengajuan',
                tone: PillTone.danger,
              ),
              const SizedBox(height: 16),
              Text('Tolak pendaftaran?', style: SiagaText.heading1),
              const SizedBox(height: 14),
              Text(
                '${r.fullName} • ${r.requestedRole.label}\nAlasan akan dikirim kepada pemohon.',
                style: SiagaText.body.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 16),
              GlassField(
                label: 'Alasan penolakan wajib',
                hint: 'Jelaskan alasan penolakan',
                controller: _reason,
                maxLines: 3,
                errorText: _error,
              ),
              const SizedBox(height: 16),
              SiagaButton.danger(
                label: _busy ? 'Mengirim...' : 'Tolak & kirim alasan',
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 12),
              SiagaButton.ghost(
                label: 'Batal',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
