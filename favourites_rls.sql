-- HomeU favourites RLS setup
-- Run this in the Supabase SQL editor for your project.

alter table public.favourites enable row level security;

-- Remove existing policies first so the script is safe to re-run.
drop policy if exists "tenant_can_select_own_favourites" on public.favourites;
drop policy if exists "tenant_can_insert_own_favourites" on public.favourites;
drop policy if exists "tenant_can_delete_own_favourites" on public.favourites;

create policy "tenant_can_select_own_favourites"
on public.favourites
for select
to authenticated
using (tenant_id = auth.uid());

create policy "tenant_can_insert_own_favourites"
on public.favourites
for insert
to authenticated
with check (tenant_id = auth.uid());

create policy "tenant_can_delete_own_favourites"
on public.favourites
for delete
to authenticated
using (tenant_id = auth.uid());

