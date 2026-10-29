-- Pick my Plate: FRIENDS. Run this once in Supabase (SQL Editor → New query → Run),
-- after supabase-setup.sql. Safe to run again.
--
-- What it adds:
--   pmp_profiles     each person's first name and friend code (like GRACIE-7K2Q)
--   pmp_friendships  friend requests, and accepted friendships
-- Rules:
--   * You can only see the names of people you've sent a request to, or who sent you one.
--   * Only ACCEPTED friends can read each other's passport (stars, notes, places).
--   * Emails are never shared.

-- ---------- profiles ----------
create table if not exists public.pmp_profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text not null default '',
  friend_code text not null unique,
  created_at  timestamptz not null default now()
);
alter table public.pmp_profiles enable row level security;

-- ---------- friendships ----------
create table if not exists public.pmp_friendships (
  id         bigint generated always as identity primary key,
  requester  uuid not null references auth.users (id) on delete cascade,
  addressee  uuid not null references auth.users (id) on delete cascade,
  status     text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  constraint pmp_no_self_friend check (requester <> addressee)
);
-- one friendship per pair of people, whichever direction it was sent
create unique index if not exists pmp_friend_pair
  on public.pmp_friendships (least(requester, addressee), greatest(requester, addressee));
alter table public.pmp_friendships enable row level security;

-- ---------- helpers ----------
create or replace function public.pmp_are_friends(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.pmp_friendships f
    where f.status = 'accepted'
      and ((f.requester = a and f.addressee = b) or (f.requester = b and f.addressee = a))
  );
$$;

-- look someone up by friend code (returns only their id and first name)
create or replace function public.pmp_find_by_code(code text)
returns table (id uuid, name text) language sql stable security definer set search_path = public as $$
  select p.id, p.name from public.pmp_profiles p
  where upper(p.friend_code) = upper(trim(code)) and p.id <> auth.uid()
  limit 1;
$$;
revoke all on function public.pmp_find_by_code(text) from public, anon;
grant execute on function public.pmp_find_by_code(text) to authenticated;
grant execute on function public.pmp_are_friends(uuid, uuid) to authenticated;

-- ---------- rules: profiles ----------
drop policy if exists "See my profile and people I'm connected to" on public.pmp_profiles;
drop policy if exists "Create my profile" on public.pmp_profiles;
drop policy if exists "Update my profile" on public.pmp_profiles;

create policy "See my profile and people I'm connected to" on public.pmp_profiles
  for select using (
    id = auth.uid() or exists (
      select 1 from public.pmp_friendships f
      where (f.requester = auth.uid() and f.addressee = pmp_profiles.id)
         or (f.addressee = auth.uid() and f.requester = pmp_profiles.id)
    )
  );
create policy "Create my profile" on public.pmp_profiles
  for insert with check (id = auth.uid());
create policy "Update my profile" on public.pmp_profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- ---------- rules: friendships ----------
drop policy if exists "See my friendships" on public.pmp_friendships;
drop policy if exists "Send a request" on public.pmp_friendships;
drop policy if exists "Accept a request sent to me" on public.pmp_friendships;
drop policy if exists "Remove a friendship or request" on public.pmp_friendships;

create policy "See my friendships" on public.pmp_friendships
  for select using (auth.uid() in (requester, addressee));
create policy "Send a request" on public.pmp_friendships
  for insert with check (requester = auth.uid() and status = 'pending');
create policy "Accept a request sent to me" on public.pmp_friendships
  for update using (addressee = auth.uid()) with check (addressee = auth.uid() and status = 'accepted');
create policy "Remove a friendship or request" on public.pmp_friendships
  for delete using (auth.uid() in (requester, addressee));

-- ---------- rules: friends can read your passport ----------
drop policy if exists "Friends can read my data" on public.pmp_user_data;
create policy "Friends can read my data" on public.pmp_user_data
  for select using (public.pmp_are_friends(auth.uid(), user_id));
