create table if not exists day02
(
  id bigserial,
  direction text,
  distance integer
);

truncate day02;

\copy day02 (direction, distance) from './input.txt' with (delimiter ' ');

with total_moves as (
  select
  sum(case when direction = 'forward' then distance else 0 end) as total_forward,
  sum(
    case
    when direction = 'down' then distance
    when direction = 'up' then -1 * distance
    else 0
    end
  ) as total_down
  from day02
)
select total_forward * total_down as part1 from total_moves;

with part2_moves as (
  select
  id,
  direction,
  distance,
  case
    when direction = 'down' then distance
    when direction = 'up' then -1 * distance
    else 0
  end
    as aim_change
  from day02
),
aimed_moves as (
  select
  id,
  direction,
  distance,
  sum(aim_change) over (order by id range between unbounded preceding and current row) as current_aim
  from part2_moves
),
filtered_moves as (
  select * from aimed_moves where direction = 'forward'
)
select sum(distance) * sum(distance * current_aim) as part2 from filtered_moves;

