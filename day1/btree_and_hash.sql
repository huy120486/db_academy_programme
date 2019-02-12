/***********************************
 * Breee
 * Usage: Basic ops like greater than, less than, equals, greater than or equal to, less than or equal to searches.
 ***********************************/

-- Example:

-- Create test table
create table test(id int, info text);
-- Insert data
insert into test select generate_series(1,10000), md5(random()::text) ;
-- Create btree index
create index idx_t_btree_1 on test using btree (info);
-- Check index by using explain
explain (analyze,verbose,buffers) select * from test where id=1;

/***********************************
 * Hash index
 * Usage: Searches on extremely long strings
 * Trace off: Only support equality queries.
***********************************/

-- Example:

-- Drop btree index
drop index idx_t_btree_1;
-- Insert a big data
insert into test select generate_series(1,10), repeat(md5(random()::text),10000);
-- Reindex btree
create index idx_t_btree_1 on test using btree (info);
-- => failed and explain
-- Add hash index
create index idx_t_hash_1 on test using hash (info);
-- Show data to check
select * from test limit 1;
-- Check new index by using explain
explain (analyze,verbose,timing,costs,buffers) select * from test where info = 'text from above result';
