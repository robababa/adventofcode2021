\copy day01 (value) from './input.txt';

with source as
(
  select
  id,
  value,
  count(*) over (order by id range between 2 preceding and current row) as measure_count,
  sum(value) over (order by id range between 2 preceding and current row) as depth_total
  from day01
  order by id
),
comparisons as
(
  select
  id,
  depth_total,
  lag(depth_total) over (order by id) as previous_depth_total,
  case when depth_total > lag(depth_total) over (order by id) then 1 else 0 end as increased_depth
  from source
  where measure_count = 3
)
select sum(increased_depth) from comparisons;

