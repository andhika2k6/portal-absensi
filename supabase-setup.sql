-- Jalankan SEKALI di Supabase > SQL Editor > New query > Run

create table if not exists public.panitia (
  id_panitia text primary key,
  nrp text unique not null,
  nama text not null,
  role text default 'panitia',
  asal_sma text,
  zona_domisili text,
  bersedia_jauh text default 'Bersedia',
  tanggal_halangan text default '-',
  info_tambahan text
);

create table if not exists public.plotting_absensi (
  id_plotting text primary key,
  id_sekolah text not null,
  nama_sma text not null,
  zona_sekolah text,
  kategori_lokasi text,
  tanggal_visit text,
  tim int,
  kursi int,
  id_panitia text,
  nrp text,
  nama_panitia text,
  is_alumni boolean default false,
  status_hadir text default 'Belum Hadir',
  foto_url text,
  latitude numeric,
  longitude numeric,
  akurasi_meter numeric,
  waktu_absen timestamptz
);

-- Aktifkan Row Level Security (WAJIB; tanpa ini tabel terbuka tanpa aturan)
alter table public.panitia enable row level security;
alter table public.plotting_absensi enable row level security;

-- Boleh baca, tambah, ubah. TIDAK ada izin hapus lewat aplikasi.
drop policy if exists "panitia_select" on public.panitia;
drop policy if exists "panitia_insert" on public.panitia;
drop policy if exists "panitia_update" on public.panitia;
create policy "panitia_select" on public.panitia for select to anon using (true);
create policy "panitia_insert" on public.panitia for insert to anon with check (true);
create policy "panitia_update" on public.panitia for update to anon using (true) with check (true);

drop policy if exists "plot_select" on public.plotting_absensi;
drop policy if exists "plot_insert" on public.plotting_absensi;
drop policy if exists "plot_update" on public.plotting_absensi;
create policy "plot_select" on public.plotting_absensi for select to anon using (true);
create policy "plot_insert" on public.plotting_absensi for insert to anon with check (true);
create policy "plot_update" on public.plotting_absensi for update to anon using (true) with check (true);

-- Bucket foto (publik, maks 1 MB per file, hanya gambar)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('foto-absensi', 'foto-absensi', true, 1048576, array['image/jpeg','image/png'])
on conflict (id) do update set public = true, file_size_limit = 1048576;

drop policy if exists "foto_select" on storage.objects;
drop policy if exists "foto_insert" on storage.objects;
drop policy if exists "foto_update" on storage.objects;
create policy "foto_select" on storage.objects for select to anon using (bucket_id = 'foto-absensi');
create policy "foto_insert" on storage.objects for insert to anon with check (bucket_id = 'foto-absensi');
create policy "foto_update" on storage.objects for update to anon using (bucket_id = 'foto-absensi');
