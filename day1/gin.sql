/***********************************
 * Gin index
 * Usage:
 * - Gin indexes are applicable to searches on values with multi-value data types, such as array, full-text search, and token.
 * - Gin indexes support multiple searches for different types of data, including intersection, contains, greater than, left, and right.)
 * Trace off: don't support index only scan
***********************************/

-- Example 1: Search over multi-value data

-- Create t_gin1 table
create table t_gin1 (id int, arr int[]);
-- Generate 10000 items which have an array of 10 numbers
do language plpgsql $$
declare
begin
  for i in 1..10000 loop
    insert into t_gin1 select i, array(select random()*1000 from generate_series(1,10));
  end loop;
end;
$$;
-- Show data to check
select * from t_gin1 limit 3;
select * from t_gin1 where arr && array[1,2];
-- Try to add btree index
create index idx_t_gin1_using_btree on t_gin1 (arr);
explain (analyze,verbose,timing,costs,buffers) select * from t_gin1 where arr && array[1,2];
-- Note that: Btree doesn't support an operation to check a collection contains an item or not
-- Not work => Using gin index
create index idx_t_gin1_1_using_gin on t_gin1 using gin (arr);
-- Find all array containing 1 or 2
explain (analyze,verbose,timing,costs,buffers) select * from t_gin1 where arr && array[1,2];
-- Find all array containing 1 and 2
explain (analyze,verbose,timing,costs,buffers) select * from t_gin1 where arr @> array[1,2];

/************************************************************************/

Example 2: Search over single-value sparse data

-- Create extension
create extension btree_gin;
-- Create t_gin2 table
create table t_gin2 (id int, c1 int);

-- Insert 100000 rows with only 10 random values
-- should use for narrow value range like status, enum, bool, ...
insert into t_gin2 select generate_series(1,100000), random()*10 ;
-- Try to use btree index
create index idx_t_gin2_using_btree on t_gin2 (c1);
explain (analyze,verbose,timing,costs,buffers) select * from t_gin2 where c1=1;
-- Not work => Using gin index
create index idx_t_gin2_using_gin on t_gin2 using gin (c1);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_gin2 where c1=1;
-- Check index size
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
  nspname not in ('pg_catalog','information_schema') AND
  relname like '%t_gin2%';
```
