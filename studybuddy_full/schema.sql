-- Run this entire script in Supabase Dashboard > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default 'Student',
  education_type text not null default 'school' check (education_type in ('school','college')),
  education_level text not null default '6th Standard',
  board text not null default 'CBSE',
  institution text not null default '',
  university text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subject text not null default 'Other',
  note_type text not null default 'Handwritten Notes' check (note_type in ('Handwritten Notes','Teacher-Given Notes')),
  content_text text not null default '',
  file_name text,
  mime_type text,
  storage_path text,
  created_at timestamptz not null default now()
);
create index if not exists notes_user_created_idx on public.notes(user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.notes enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
drop policy if exists "Users can create own profile" on public.profiles;
create policy "Users can create own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can read own notes" on public.notes;
create policy "Users can read own notes" on public.notes for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can create own notes" on public.notes;
create policy "Users can create own notes" on public.notes for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can update own notes" on public.notes;
create policy "Users can update own notes" on public.notes for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users can delete own notes" on public.notes;
create policy "Users can delete own notes" on public.notes for delete to authenticated using (auth.uid() = user_id);

-- Private bucket for PDFs/images. Keep it PRIVATE; the app uses short-lived signed URLs.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('study-notes','study-notes',false,20971520,array['application/pdf','image/png','image/jpeg','image/webp'])
on conflict (id) do update set public=false, file_size_limit=20971520, allowed_mime_types=array['application/pdf','image/png','image/jpeg','image/webp'];

drop policy if exists "Users can view files in own folder" on storage.objects;
create policy "Users can view files in own folder" on storage.objects for select to authenticated using (bucket_id='study-notes' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can upload files to own folder" on storage.objects;
create policy "Users can upload files to own folder" on storage.objects for insert to authenticated with check (bucket_id='study-notes' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can update files in own folder" on storage.objects;
create policy "Users can update files in own folder" on storage.objects for update to authenticated using (bucket_id='study-notes' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='study-notes' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users can delete files in own folder" on storage.objects;
create policy "Users can delete files in own folder" on storage.objects for delete to authenticated using (bucket_id='study-notes' and (storage.foldername(name))[1]=auth.uid()::text);
