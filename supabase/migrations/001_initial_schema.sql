-- Run this migration in the Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.people (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  notes text,
  updated_at bigint not null,
  deleted_at bigint
);
create table if not exists public.debts (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  person_id uuid not null,
  amount bigint not null check (amount > 0),
  date date not null,
  due_date date,
  notes text,
  updated_at bigint not null,
  deleted_at bigint
);
create table if not exists public.receivables (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  person_id uuid not null,
  amount bigint not null check (amount > 0),
  date date not null,
  due_date date,
  notes text,
  updated_at bigint not null,
  deleted_at bigint
);
create table if not exists public.payments (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  ledger_id uuid not null,
  person_id uuid not null,
  kind text not null check (kind in ('debt','receivable')),
  amount bigint not null check (amount > 0),
  date date not null,
  method text,
  notes text,
  updated_at bigint not null,
  deleted_at bigint
);
create index if not exists people_user_id_idx on public.people(user_id);
create index if not exists debts_user_id_idx on public.debts(user_id);
create index if not exists receivables_user_id_idx on public.receivables(user_id);
create index if not exists payments_user_id_idx on public.payments(user_id);
alter table public.people enable row level security;
alter table public.debts enable row level security;
alter table public.receivables enable row level security;
alter table public.payments enable row level security;
create policy "private people select" on public.people for select using (auth.uid() = user_id);
create policy "private people insert" on public.people for insert with check (auth.uid() = user_id);
create policy "private people update" on public.people for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "private people delete" on public.people for delete using (auth.uid() = user_id);
create policy "private debts select" on public.debts for select using (auth.uid() = user_id);
create policy "private debts insert" on public.debts for insert with check (auth.uid() = user_id);
create policy "private debts update" on public.debts for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "private debts delete" on public.debts for delete using (auth.uid() = user_id);
create policy "private receivables select" on public.receivables for select using (auth.uid() = user_id);
create policy "private receivables insert" on public.receivables for insert with check (auth.uid() = user_id);
create policy "private receivables update" on public.receivables for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "private receivables delete" on public.receivables for delete using (auth.uid() = user_id);
create policy "private payments select" on public.payments for select using (auth.uid() = user_id);
create policy "private payments insert" on public.payments for insert with check (auth.uid() = user_id);
create policy "private payments update" on public.payments for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "private payments delete" on public.payments for delete using (auth.uid() = user_id);
