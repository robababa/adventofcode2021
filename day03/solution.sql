drop table if exists day03, day03_split;

create table day03
(
  id serial,
  value text
);


create table day03_split (
  id integer,
  original_position integer,
  value integer,
  digit_place integer
);

\copy day03 (value) from 'input.txt';

insert into day03_split (id, original_position, value)
select
id,
value_and_original_position.original_position,
cast(value_and_original_position.value as integer) as value
from day03
cross join lateral (
  select *
  from regexp_split_to_table(value, '') with ordinality
  as t(value, original_position)
) as value_and_original_position
order by id, original_position;

update day03_split
set
digit_place =
(select max(original_position) from day03_split) - original_position;

with frequency_counts as
(
  select digit_place, value, count(*) as frequency
  from day03_split
  group by digit_place, value
  order by digit_place, value
),
gammas as
(
  select distinct
  digit_place,
  first_value(value) over (partition by digit_place order by frequency desc) as most_frequent_value
  from frequency_counts
  order by digit_place
),
epsilons as
(
  select distinct
  digit_place,
  first_value(value) over (partition by digit_place order by frequency asc) as most_frequent_value
  from frequency_counts
  order by digit_place
),
gamma_sum as
(
  select sum(cast(most_frequent_value as integer) * pow(2, digit_place)) as gamma_total from gammas
),
epsilon_sum as
(
  select sum(cast(most_frequent_value as integer) * pow(2, digit_place)) as epsilon_total from epsilons
)
select gamma_total, epsilon_total, gamma_total * epsilon_total as part1
from gamma_sum cross join epsilon_sum;


