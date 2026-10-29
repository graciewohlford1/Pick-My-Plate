-- Pick my Plate: run this once in Supabase (SQL Editor → New query → Run).
-- It makes one table that stores each person's passport, and locks it down
-- so every account can only read and write its own row.

create table if not exists public.pmp_user_data (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.pmp_user_data enable row level security;

drop policy if exists "Read my own data"   on public.pmp_user_data;
drop policy if exists "Add my own data"    on public.pmp_user_data;
drop policy if exists "Update my own data" on public.pmp_user_data;

create policy "Read my own data" on public.pmp_user_data
  for select using (auth.uid() = user_id);

create policy "Add my own data" on public.pmp_user_data
  for insert with check (auth.uid() = user_id);

create policy "Update my own data" on public.pmp_user_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
