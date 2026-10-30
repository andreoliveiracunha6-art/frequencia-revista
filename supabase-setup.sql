-- Frequência: execute este arquivo no SQL Editor do seu projeto Supabase.
create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()); $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated, anon;

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'ARTIGO',
  excerpt text not null default '',
  body text not null default '',
  image_url text,
  status text not null default 'draft' check (status in ('draft','published')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.chords (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  full_name text not null default '',
  instrument text not null default 'Violão' check (instrument in ('Violão','Guitarra')),
  category text not null default 'Maior',
  level text not null default 'Iniciante',
  notes text not null default '',
  description text not null default '',
  image_url text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.site_settings (
  key text primary key,
  value text not null default ''
);
insert into public.site_settings(key,value) values
 ('site_title','FREQUÊNCIA'),
 ('hero_title','O som começa quando você descobre.'),
 ('hero_text','Um espaço para aprender, explorar sons e desenvolver sua musicalidade.'),
 ('about_text','Uma revista independente para quem ama aprender e compartilhar música.')
on conflict (key) do nothing;

alter table public.admins enable row level security;
alter table public.articles enable row level security;
alter table public.chords enable row level security;
alter table public.site_settings enable row level security;

drop policy if exists "admins read own admin row" on public.admins;
create policy "admins read own admin row" on public.admins for select to authenticated using (user_id = auth.uid());
-- Public can read published articles only. Admins can manage all articles.
drop policy if exists "public read published articles" on public.articles;
create policy "public read published articles" on public.articles for select to anon, authenticated using (status = 'published' or public.is_admin());
drop policy if exists "admins manage articles" on public.articles;
create policy "admins manage articles" on public.articles for all to authenticated using (public.is_admin()) with check (public.is_admin());
-- Public can read published chords only. Admins can manage all chords.
drop policy if exists "public read published chords" on public.chords;
create policy "public read published chords" on public.chords for select to anon, authenticated using (published = true or public.is_admin());
drop policy if exists "admins manage chords" on public.chords;
create policy "admins manage chords" on public.chords for all to authenticated using (public.is_admin()) with check (public.is_admin());
-- Settings are public to read, admin-only to change.
drop policy if exists "public read site settings" on public.site_settings;
create policy "public read site settings" on public.site_settings for select to anon, authenticated using (true);
drop policy if exists "admins manage site settings" on public.site_settings;
create policy "admins manage site settings" on public.site_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());

grant select on public.articles, public.chords, public.site_settings to anon, authenticated;
grant insert, update, delete on public.articles, public.chords, public.site_settings to authenticated;
grant select on public.admins to authenticated;

-- Create public media bucket. Upload/delete/list are admin-only; public can view images.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media','media',true,5242880,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];
drop policy if exists "public view media" on storage.objects;
create policy "public view media" on storage.objects for select to anon, authenticated using (bucket_id = 'media');
drop policy if exists "admins upload media" on storage.objects;
create policy "admins upload media" on storage.objects for insert to authenticated with check (bucket_id = 'media' and public.is_admin());
drop policy if exists "admins update media" on storage.objects;
create policy "admins update media" on storage.objects for update to authenticated using (bucket_id = 'media' and public.is_admin()) with check (bucket_id = 'media' and public.is_admin());
drop policy if exists "admins delete media" on storage.objects;
create policy "admins delete media" on storage.objects for delete to authenticated using (bucket_id = 'media' and public.is_admin());
