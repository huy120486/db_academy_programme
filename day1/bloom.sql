/***********************************
* Bloom index
* Usage: Bloom indexes are for queries on arbitrary combinations of multiple columns
* Trace off: ineffective for single field index.
***********************************/

-- Disable parallel process
set max_parallel_workers_per_gather = 0;
-- Create t_gin1 table
create table t_bloom (id int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int, c9 int);
-- Generate 1000000 items which have an array of 10 numbers
insert into t_bloom select generate_series(1,1000000), random()*10, random()*20, random()*30, random()*40, random()*50, random()*60, random()*70, random()*80, random()*90;
-- Try to add btree index
create index idx_t_bloom_1_using_btree on t_bloom (c1,c2,c3,c4,c5,c6,c7,c8,c9);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_bloom where c6=1 and c7=1 and c8=1;
-- Force using btree
set enable_seqscan = false;
-- Explain again
explain (analyze,verbose,timing,costs,buffers) select * from t_bloom where c6=1 and c7=1 and c8=1;
-- Create extension to use bloom
create extension bloom;
-- Add Bloom index
create index idx_t_bloom_1_using_bloom on t_bloom using bloom (c1,c2,c3,c4,c5,c6,c7,c8,c9);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_bloom where c6=1 and c7=1 and c8=1;
-- Check index size
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
  nspname not in ('pg_catalog','information_schema') AND
  relname like '%t_bloom%';
-- Test with Gin index
-- Create extension
create extension btree_gin;
-- Add gin index
create index idx_t_bloom_1_using_gin on t_bloom using gin (c1,c2,c3,c4,c5,c6,c7,c8,c9);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_bloom where c6=1 and c7=1 and c8=1;
-- Check index size again
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
  nspname not in ('pg_catalog','information_schema') AND
  relname like '%t_bloom%';
