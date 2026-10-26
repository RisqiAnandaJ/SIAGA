import 'package:flutter/material.dart';

import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

/// Detail dan edit data personel. [name] kosong berarti personel baru.
class PersonnelDetailPage extends StatefulWidget {
  const PersonnelDetailPage({super.key, this.name});

  final String? name;

  @override
  State<PersonnelDetailPage> createState() => _PersonnelDetailPageState();
}

class _PersonnelDetailPageState extends State<PersonnelDetailPage> {
  late final bool _isNew = widget.name == null;
  late final _name = TextEditingController(text: widget.name ?? '');
  late final _username = TextEditingController(
    text: widget.name == null
        ? ''
        : widget.name!.toLowerCase().replaceAll(' ', '.'),
  );
  late final _email = TextEditingController(
    text: widget.name == null
        ? ''
        : '${widget.name!.split(' ').first.toLowerCase()}@example.com',
  );
  late final _phone = TextEditingController(
    text: _isNew ? '' : 'data kontak disamarkan',
  );
  String _role = 'PAMDAL';
  int _status = 0;

  @override
  void dispose() {
    for (final c in [_name, _username, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty || _username.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan username wajib diisi.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data personel tersimpan dan dicatat dalam audit.'),
      ),
    );
  }

  Future<void> _deactivate() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GlassCard(
          tone: GlassTone.raised,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InfoBanner(
                danger: true,
                title: 'Nonaktifkan akun?',
                body:
                    'Modul operasional akan terkunci. Riwayat tugas tetap tersimpan.',
              ),
              const SizedBox(height: 16),
              SiagaButton.danger(
                label: 'Nonaktifkan',
                onPressed: () => Navigator.of(context).pop(true),
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
    if (ok != true || !mounted) return;
    setState(() => _status = 1);
  }

  @override
  Widget build(BuildContext context) {
    final label = _status == 0 ? 'Aktif' : 'Tidak aktif';
    return MainPage(
      title: _isNew ? 'Tambah personel' : 'Detail personel',
      subtitle: _isNew
          ? 'Akun dibuat oleh PIC PAMDAL'
          : '${widget.name} • akun terverifikasi',
      showDock: true,
      dockIndex: 3,
      showBack: true,
      children: [
        if (!_isNew)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionCardTitle(widget.name!),
                const SizedBox(height: 12),
                StatusPill(
                  '$_role • $label',
                  tone: _status == 0 ? PillTone.success : PillTone.neutral,
                ),
                const SizedBox(height: 8),
                const InfoRow(
                  title: 'Penugasan saat ini',
                  subtitle: 'Shift pagi • Pos utama • 07.00–15.00',
                  chevron: true,
                ),
                const Text(
                  '20 hari hadir • 38 sesi patroli bulan ini',
                  style: TextStyle(fontSize: 12.5, color: Color(0xB3E2E8F0)),
                ),
              ],
            ),
          ),
        SectionCard(
          title: _isNew ? 'Data personel baru' : 'Edit data personel',
          children: [
            GlassField(label: 'Nama lengkap', controller: _name),
            const SizedBox(height: 14),
            GlassField(label: 'Username', controller: _username),
            const SizedBox(height: 14),
            GlassField(
              label: 'Email',
              controller: _email,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            GlassField(
              label: 'Nomor handphone',
              controller: _phone,
              prefix: '+62',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 14),
            GlassSelect(
              label: 'Peran',
              value: _role,
              options: const ['PAMDAL', 'Pimpinan'],
              onChanged: (v) => setState(() => _role = v),
            ),
            const SizedBox(height: 14),
            PillTabs(
              labels: const ['Aktif', 'Tidak aktif'],
              index: _status,
              onChanged: (i) => setState(() => _status = i),
              height: 54,
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(
              label: _isNew ? 'Simpan personel' : 'Simpan perubahan',
              onPressed: _save,
            ),
          ],
        ),
        const InfoBanner(
          title: 'Perubahan akses tercatat',
          body:
              'Penonaktifan mengunci modul operasional tanpa menghapus riwayat tugas.',
        ),
        if (!_isNew)
          SiagaButton.danger(
            label: 'Nonaktifkan akun',
            height: 56,
            onPressed: _status == 1 ? null : _deactivate,
          ),
      ],
    );
  }
}

/// Judul besar di dalam kartu.
class SectionCardTitle extends StatelessWidget {
  const SectionCardTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFFE2E8F0),
    ),
  );
}
