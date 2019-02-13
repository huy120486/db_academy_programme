/***********************************
 * Brin index
 * Summary: Index on page instead of tuple like other indexes => much smaller size thank others
 * Usage: BRIN indexes would perform very well on Equals and Range searches (especially, time or serial fields)
 * Tip: Should use for large tables
***********************************/

-- Example:

-- Create t_brin table
create table t_brin (id int, info text, crt_time timestamp);
-- Generate 1000000 items
insert into t_brin select generate_series(1,1000000), md5(random()::text), clock_timestamp();
-- Create brin index
create index idx_t_brin_2_using_brin on t_brin using brin (crt_time);
-- Need to check: create index idx_t_brin_2 on t_brin using brin (crt_time) with (pages_per_range=1);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_brin where crt_time between '2017-06-27 22:50:19.172224' and '2017-06-27 22:50:19.182224';
-- Add btree index to compare
create index idx_t_brin_2_using_btree on t_brin (crt_time);
-- Explain: btree is faster but larger
explain (analyze,verbose,timing,costs,buffers) select * from t_brin where crt_time between '2017-06-27 22:50:19.172224' and '2017-06-27 22:50:19.182224';
-- Check index size
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
  nspname not in ('pg_catalog','information_schema') AND
  relname like '%t_brin%';
