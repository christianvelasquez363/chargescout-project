-- ChargeScout database schema for Supabase
-- Run this in your Supabase project: Dashboard -> SQL Editor -> New query -> paste -> Run

-- ============================================================
-- 1. STATIONS (the charging locations)
-- ============================================================
create table if not exists stations (
  id text primary key,
  name text not null,
  network text not null,
  address text not null,
  lat double precision,
  lng double precision,
  map_x real,              -- legacy stylized position, superseded by real lat/lng placement
  map_y real,
  price numeric(5,2),      -- nullable: Open Charge Map often has no price data — community reports fill the gap
  connectors text[] not null,          -- e.g. {CCS,NACS}
  amenities text[] not null default '{}',
  distance_mi real,
  created_at timestamptz default now()
);

-- ============================================================
-- 2. PROFILES (one row per user, tracks points + referral code)
-- ============================================================
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Scout',
  points integer not null default 0,
  referral_code text unique not null,
  referred_by text references profiles(referral_code),
  sweepstakes_entries integer not null default 0,
  referral_bonus_claimed boolean not null default false,
  created_at timestamptz default now()
);

-- ============================================================
-- 3. REPORTS (community reports on stations)
-- ============================================================
create table if not exists reports (
  id uuid primary key default gen_random_uuid(),
  station_id text not null references stations(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  type text not null check (type in ('traffic','price','cleanliness')),
  body text not null,
  upvotes integer not null default 0,
  created_at timestamptz default now()
);

-- ============================================================
-- 4. UPVOTES (so a user can't upvote the same report twice)
-- ============================================================
create table if not exists report_upvotes (
  report_id uuid references reports(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  primary key (report_id, user_id)
);

-- ============================================================
-- Row Level Security
-- ============================================================
alter table stations enable row level security;
alter table profiles enable row level security;
alter table reports enable row level security;
alter table report_upvotes enable row level security;

-- Anyone (including anonymous auth users) can read stations and reports
create policy "public read stations" on stations for select using (true);
create policy "signed-in users can add stations" on stations for insert with check (auth.uid() is not null);
create policy "signed-in users can update stations" on stations for update using (auth.uid() is not null);
create policy "public read reports" on reports for select using (true);
create policy "public read profiles" on profiles for select using (true);

-- Users can only insert/update their own profile
create policy "insert own profile" on profiles for insert with check (auth.uid() = id);
create policy "update own profile" on profiles for update using (auth.uid() = id);

-- Any signed-in (including anonymous) user can post a report as themselves
create policy "insert own report" on reports for insert with check (auth.uid() = user_id);

-- Upvotes: insert your own vote, prevented from duplicating by the primary key
create policy "insert own upvote" on report_upvotes for insert with check (auth.uid() = user_id);
create policy "read upvotes" on report_upvotes for select using (true);

-- ============================================================
-- Seed data: the 8 San Gabriel Valley stations from the demo
-- ============================================================
insert into stations (id, name, network, address, map_x, map_y, price, connectors, amenities, distance_mi) values
  ('s1','Azusa Ave EVgo Hub','EVgo','1180 N Azusa Ave, Covina, CA', 70, 200, 0.42, '{CCS,NACS}', '{"Restroom","Coffee shop","Fast food"}', 1.1),
  ('s2','Citrus Crossing ChargePoint','ChargePoint','620 N Citrus Ave, Covina, CA', 150, 120, 0.34, '{CCS,J1772}', '{"Grocery store","Restroom"}', 2.0),
  ('s3','Glendora Village Supercharger','Tesla Supercharger','150 W Rte 66, Glendora, CA', 240, 70, 0.31, '{NACS}', '{"Coffee shop","Shopping","Restroom"}', 3.4),
  ('s4','West Covina Fashion Plaza EA','Electrify America','112 Plaza Dr, West Covina, CA', 45, 300, 0.51, '{CCS,CHAdeMO}', '{"Shopping mall","Food court","Restroom"}', 4.8),
  ('s5','San Dimas Canyon Blink','Blink','845 W Arrow Hwy, San Dimas, CA', 260, 280, 0.39, '{CCS,J1772}', '{"Trailhead parking"}', 6.1),
  ('s6','Downtown Covina ChargePoint','ChargePoint','125 E College St, Covina, CA', 110, 250, 0.36, '{CCS,J1772,NACS}', '{"Coffee shop","Restaurants"}', 0.6),
  ('s7','Irwindale Speedway EVgo','EVgo','500 Speedway Dr, Irwindale, CA', 190, 355, 0.45, '{CCS}', '{"Restroom"}', 5.5),
  ('s8','Duarte Foothill Electrify America','Electrify America','1450 Huntington Dr, Duarte, CA', 215, 170, 0.53, '{CCS,CHAdeMO,NACS}', '{"Fast food","Restroom","Pharmacy"}', 4.0)
on conflict (id) do nothing;

-- ============================================================
-- Function: auto-create a profile with a referral code when a user signs up
-- (including anonymous sign-ins)
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, referral_code)
  values (new.id, upper(substr(replace(new.id::text, '-', ''), 1, 8)));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
