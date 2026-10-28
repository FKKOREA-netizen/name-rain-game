-- Supabase SQL Editor에서 새 프로젝트에 한 번 실행하세요.
create table public.scores (
  run_id uuid primary key,
  display_name text not null check (char_length(btrim(display_name)) between 1 and 16),
  score numeric not null check (score between -1e100::numeric and 1e100::numeric),
  survival_ms bigint not null check (survival_ms >= 0 and survival_ms <= 604800000),
  created_at timestamptz not null default now()
);
create index scores_ranking_idx on public.scores(score desc, survival_ms desc, created_at asc);
alter table public.scores enable row level security;
revoke all on public.scores from anon, authenticated;
grant select (display_name, score, survival_ms, created_at) on public.scores to anon;
grant insert (run_id, display_name, score, survival_ms) on public.scores to anon;
create policy "Public leaderboard read" on public.scores for select to anon using (true);
create policy "Public score submission" on public.scores for insert to anon with check (true);
-- 공개 조회/등록만 허용합니다. 클라이언트의 수정/삭제는 허용하지 않습니다.
-- 점수는 클라이언트 신고 방식입니다. 경쟁용 부정행위 방지 기능은 포함하지 않습니다.
