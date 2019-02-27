--- Sample queries


-----------------------------------------------------------------
-- bitmap scan
-----------------------------------------------------------------

-- seq scan
explain analyze
select population
from city
where population > 10000;

-- bitmap
explain analyze
select population
from city
where population > 10000000;

-- index scan
explain analyze
select population
from city
where population > 100000000;

-----------------------------------------------------------------
-- compound index
-----------------------------------------------------------------

explain analyze
select *
from countrylanguage
where language = 'English'
      and percentage > 90;

create index
countrylanguage_language_percentage_idx
on countrylanguage(language, percentage);

drop index countrylanguage_language_percentage_idx;

-----------------------------------------------------------------
-- expression index
-----------------------------------------------------------------
explain analyze
select population
from city
where lower(name) = 'kabul';

create index
city_lower_name_idx
on city(lower(name));

drop index city_lower_name_idx;

-----------------------------------------------------------------
-- partial index
-----------------------------------------------------------------
explain analyze
select *
from countrylanguage
where language = 'English';

create index
countrylanguage_language_idx
on city(lower(name));

drop index countrylanguage_language_idx;
