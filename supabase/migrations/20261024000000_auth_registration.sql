-- SIAGA: autentikasi, registrasi, RBAC dasar, notifikasi, dan jejak audit.
-- Jalankan di Supabase (SQL editor atau `supabase db push`).
-- Modul lain (jadwal, absensi, patroli, kejadian, dokumentasi) menyusul pada
-- migrasi terpisah dan memakai fungsi has_permission() di bawah.

-- ---------------------------------------------------------------------------
-- 1. Tabel
-- ---------------------------------------------------------------------------

create table public.roles (
  id          smallint generated always as identity primary key,
  name        text not null unique check (name in ('pamdal', 'pic_pamdal', 'pimpinan')),
  description text
);

create table public.role_permissions (
  id              bigint generated always as identity primary key,
  role_id         smallint not null references public.roles (id) on delete cascade,
  permission_code text not null,
  unique (role_id, permission_code)
);

create table public.personnel (
  id                uuid primary key references auth.users (id) on delete cascade,
  nip_id            text,
  username          text not null,
  full_name         text not null,
  email             text not null,
  phone             text not null,
  requested_role_id smallint references public.roles (id),
  role_id           smallint references public.roles (id),
  status            text not null default 'pending'
                    check (status in ('pending', 'active', 'rejected', 'inactive')),
  rejection_reason  text,
  approved_by       uuid references auth.users (id),
  approved_at       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  -- akun aktif wajib punya role
  constraint personnel_active_has_role check (status <> 'active' or role_id is not null)
);

create unique index personnel_username_key on public.personnel (lower(username));
create unique index personnel_email_key    on public.personnel (lower(email));
create unique index personnel_phone_key    on public.personnel (phone);

create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  recipient_id uuid references auth.users (id) on delete cascade,
  target_role  text check (target_role in ('pamdal', 'pic_pamdal', 'pimpinan')),
  title        text not null,
  body         text not null,
  type         text not null default 'info',
  is_read      boolean not null default false,
  created_at   timestamptz not null default now(),
  check (recipient_id is not null or target_role is not null)
);
create index notifications_recipient_idx on public.notifications (recipient_id, created_at desc);

create table public.audit_logs (
  id           bigint generated always as identity primary key,
  actor_id     uuid references auth.users (id),
  action       text not null,
  entity_name  text not null,
  entity_id    text,
  payload_diff jsonb,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 2. Data awal: role dan matriks permission (selaras dengan PRD bagian 3.2)
-- ---------------------------------------------------------------------------

insert into public.roles (name, description) values
  ('pamdal',     'Petugas lapangan Pengamanan Dalam'),
  ('pic_pamdal', 'Koordinator / administrator operasional'),
  ('pimpinan',   'Pimpinan (pemantauan dan laporan)');

insert into public.role_permissions (role_id, permission_code)
select r.id, p.code
from (values
  ('pamdal', 'attendance.create'), ('pamdal', 'attendance.read.own'),
  ('pamdal', 'schedule.read'),
  ('pamdal', 'patrol.create'), ('pamdal', 'patrol.read.own'),
  ('pamdal', 'incident.create'), ('pamdal', 'incident.read.own'),
  ('pamdal', 'documentation.create'),
  ('pamdal', 'notification.read'), ('pamdal', 'panicbutton.use'),

  ('pic_pamdal', 'attendance.read'), ('pic_pamdal', 'attendance.manage'),
  ('pic_pamdal', 'schedule.create'), ('pic_pamdal', 'schedule.read'),
  ('pic_pamdal', 'schedule.update'), ('pic_pamdal', 'schedule.delete'),
  ('pic_pamdal', 'patrol.read'), ('pic_pamdal', 'patrol.manage'),
  ('pic_pamdal', 'incident.read'), ('pic_pamdal', 'incident.update'),
  ('pic_pamdal', 'incident.manage'),
  ('pic_pamdal', 'documentation.read'), ('pic_pamdal', 'documentation.manage'),
  ('pic_pamdal', 'personnel.create'), ('pic_pamdal', 'personnel.read'),
  ('pic_pamdal', 'personnel.update'), ('pic_pamdal', 'personnel.delete'),
  ('pic_pamdal', 'registration.read'), ('pic_pamdal', 'registration.approve'),
  ('pic_pamdal', 'report.generate'), ('pic_pamdal', 'report.export'),
  ('pic_pamdal', 'notification.read'), ('pic_pamdal', 'notification.manage'),
  ('pic_pamdal', 'panicbutton.use'),

  ('pimpinan', 'attendance.read'), ('pimpinan', 'schedule.read'),
  ('pimpinan', 'patrol.read'), ('pimpinan', 'incident.read'),
  ('pimpinan', 'documentation.read'), ('pimpinan', 'personnel.read'),
  ('pimpinan', 'report.generate'), ('pimpinan', 'report.export'),
  ('pimpinan', 'notification.read'), ('pimpinan', 'panicbutton.use')
) as p (role_name, code)
join public.roles r on r.name = p.role_name;

-- ---------------------------------------------------------------------------
-- 3. Fungsi bantu RBAC (SECURITY DEFINER agar tidak terblokir RLS sendiri)
-- ---------------------------------------------------------------------------

create or replace function public.current_role_name()
returns text
language sql stable security definer set search_path = public
as $$
  select r.name
  from public.personnel p
  join public.roles r on r.id = p.role_id
  where p.id = auth.uid() and p.status = 'active'
$$;

create or replace function public.has_permission(code text)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.personnel p
    join public.role_permissions rp on rp.role_id = p.role_id
    where p.id = auth.uid()
      and p.status = 'active'
      and rp.permission_code = code
  )
$$;

-- ---------------------------------------------------------------------------
-- 4. Pembuatan profil setelah email terverifikasi (OTP signup berhasil)
--    Role hanya disimpan sebagai permintaan (requested_role_id); klien tidak
--    dapat mengisi role_id maupun status.
-- ---------------------------------------------------------------------------

create or replace function public.handle_email_confirmed()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  meta        jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  requested   text  := meta ->> 'requested_role';
  requested_id smallint;
begin
  -- Akun PIC dibuat manual (seed); hanya pamdal/pimpinan yang boleh mendaftar.
  if requested is null or requested not in ('pamdal', 'pimpinan') then
    raise exception 'Peran yang diajukan tidak valid';
  end if;

  select id into requested_id from public.roles where name = requested;

  insert into public.personnel
    (id, username, full_name, email, phone, requested_role_id, status)
  values (
    new.id,
    btrim(meta ->> 'username'),
    btrim(meta ->> 'full_name'),
    new.email,
    meta ->> 'phone',
    requested_id,
    'pending'
  )
  on conflict (id) do nothing;

  -- Beri tahu PIC PAMDAL ada pengajuan baru.
  insert into public.notifications (target_role, title, body, type)
  values (
    'pic_pamdal',
    'Pengajuan akun baru',
    'Email terverifikasi. Peran ' || upper(requested) || ' menunggu persetujuan Anda.',
    'registration'
  );

  return new;
end;
$$;

create trigger on_auth_user_email_confirmed
after update of email_confirmed_at on auth.users
for each row
when (old.email_confirmed_at is null and new.email_confirmed_at is not null)
execute function public.handle_email_confirmed();

-- ---------------------------------------------------------------------------
-- 5. RPC untuk klien
-- ---------------------------------------------------------------------------

-- Menerjemahkan username ke email untuk signInWithPassword. Dipanggil anon.
-- Hanya email yang dikembalikan; status akun diperiksa aplikasi setelah masuk
-- agar akun pending/ditolak/nonaktif mendapat pesan yang sesuai (PRD 4.1).
-- Catatan keamanan: fungsi ini memungkinkan menebak username yang ada.
-- Aktifkan rate limit Supabase Auth dan batasi lewat WAF bila perlu.
create or replace function public.get_login_email(p_username text)
returns text
language sql stable security definer set search_path = public
as $$
  select email from public.personnel where lower(username) = lower(btrim(p_username))
$$;

-- Memeriksa keunikan sebelum signUp (FR-AUTH-03).
create or replace function public.check_registration_available(
  p_username text, p_email text, p_phone text
)
returns jsonb
language sql stable security definer set search_path = public
as $$
  select jsonb_build_object(
    'username_taken', exists (select 1 from public.personnel where lower(username) = lower(btrim(p_username))),
    'email_taken',    exists (select 1 from public.personnel where lower(email) = lower(btrim(p_email))),
    'phone_taken',    exists (select 1 from public.personnel where phone = p_phone)
  )
$$;

revoke all on function public.get_login_email(text) from public;
revoke all on function public.check_registration_available(text, text, text) from public;
grant execute on function public.get_login_email(text) to anon, authenticated;
grant execute on function public.check_registration_available(text, text, text) to anon, authenticated;

-- Menyetujui pendaftaran (opsional koreksi role). Butuh registration.approve.
create or replace function public.approve_registration(p_id uuid, p_role text default null)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  target public.personnel;
  final_role_id smallint;
begin
  if not public.has_permission('registration.approve') then
    raise exception 'Tidak berwenang' using errcode = '42501';
  end if;

  select * into target from public.personnel where id = p_id for update;
  if not found or target.status <> 'pending' then
    raise exception 'Pengajuan tidak ditemukan atau sudah diproses';
  end if;

  if p_role is not null and p_role not in ('pamdal', 'pimpinan') then
    raise exception 'Peran tidak valid';
  end if;

  select id into final_role_id from public.roles
  where name = coalesce(p_role, (select name from public.roles where id = target.requested_role_id));

  update public.personnel
     set role_id = final_role_id, status = 'active', rejection_reason = null,
         approved_by = auth.uid(), approved_at = now(), updated_at = now()
   where id = p_id;

  insert into public.audit_logs (actor_id, action, entity_name, entity_id, payload_diff)
  values (auth.uid(), 'registration.approve', 'personnel', p_id::text,
          jsonb_build_object('role_id', final_role_id));

  insert into public.notifications (recipient_id, title, body, type)
  values (p_id, 'Pendaftaran disetujui', 'Akun Anda aktif. Silakan masuk ke SIAGA.', 'registration');
end;
$$;

-- Menolak pendaftaran dengan alasan wajib.
create or replace function public.reject_registration(p_id uuid, p_reason text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  target public.personnel;
begin
  if not public.has_permission('registration.approve') then
    raise exception 'Tidak berwenang' using errcode = '42501';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'Alasan penolakan wajib diisi';
  end if;

  select * into target from public.personnel where id = p_id for update;
  if not found or target.status <> 'pending' then
    raise exception 'Pengajuan tidak ditemukan atau sudah diproses';
  end if;

  update public.personnel
     set status = 'rejected', rejection_reason = btrim(p_reason),
         approved_by = auth.uid(), approved_at = now(), updated_at = now()
   where id = p_id;

  insert into public.audit_logs (actor_id, action, entity_name, entity_id, payload_diff)
  values (auth.uid(), 'registration.reject', 'personnel', p_id::text,
          jsonb_build_object('reason', btrim(p_reason)));

  insert into public.notifications (recipient_id, title, body, type)
  values (p_id, 'Pendaftaran ditolak', btrim(p_reason), 'registration');
end;
$$;

revoke all on function public.approve_registration(uuid, text) from public;
revoke all on function public.reject_registration(uuid, text) from public;
grant execute on function public.approve_registration(uuid, text) to authenticated;
grant execute on function public.reject_registration(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Row Level Security
-- ---------------------------------------------------------------------------

alter table public.roles            enable row level security;
alter table public.role_permissions enable row level security;
alter table public.personnel        enable row level security;
alter table public.notifications    enable row level security;
alter table public.audit_logs       enable row level security;

-- Master data dibaca pengguna terautentikasi; tidak ada tulis dari klien.
create policy roles_read on public.roles
  for select to authenticated using (true);
create policy role_permissions_read on public.role_permissions
  for select to authenticated using (true);

-- personnel: baca baris sendiri (termasuk saat pending/ditolak agar layar
-- status dapat tampil), atau semua bila berwenang. Kolom role_id/status hanya
-- berubah lewat RPC di atas atau oleh pemegang personnel.update.
create policy personnel_read on public.personnel
  for select to authenticated
  using (
    id = auth.uid()
    or public.has_permission('personnel.read')
    or public.has_permission('registration.read')
  );
create policy personnel_update on public.personnel
  for update to authenticated
  using (public.has_permission('personnel.update'))
  with check (public.has_permission('personnel.update'));
create policy personnel_delete on public.personnel
  for delete to authenticated
  using (public.has_permission('personnel.delete'));

-- notifications
create policy notifications_read on public.notifications
  for select to authenticated
  using (
    recipient_id = auth.uid()
    or (target_role is not null
        and target_role = public.current_role_name()
        and public.has_permission('notification.read'))
  );
create policy notifications_mark_read on public.notifications
  for update to authenticated
  using (recipient_id = auth.uid())
  with check (recipient_id = auth.uid());
create policy notifications_manage on public.notifications
  for insert to authenticated
  with check (public.has_permission('notification.manage'));

-- audit_logs: hanya dibaca administrator; penulisan hanya lewat fungsi.
create policy audit_logs_read on public.audit_logs
  for select to authenticated
  using (public.has_permission('personnel.update'));

-- ---------------------------------------------------------------------------
-- 7. Akun PIC PAMDAL pertama (manual, bukan lewat pendaftaran)
-- ---------------------------------------------------------------------------
-- 1) Buat pengguna di Authentication > Users (centang "Auto Confirm User").
-- 2) Jalankan, ganti nilai sesuai akun:
--
--   insert into public.personnel
--     (id, username, full_name, email, phone, role_id, status, approved_at)
--   values (
--     '<UUID pengguna dari langkah 1>', 'rina.wulandari', 'Rina Wulandari',
--     'rina@instansi.go.id', '+6281200000000',
--     (select id from public.roles where name = 'pic_pamdal'), 'active', now()
--   );
