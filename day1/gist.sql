/***********************************
 * Gist index
 * Usage:
 * - Supports location searches (Contain, Intersection, Top, Bottom, Left, Right, etc.)
 * - Sorting by distance.
***********************************/

-- Example 1: Searching with a geometry index

-- Create t_gist table
create table t_gist (id int, pos point);
-- Generate 100000 items of point
insert into t_gist select generate_series(1,100000), point(round((random()*1000)::numeric, 2), round((random()*1000)::numeric, 2));
-- Show data to check
select * from t_gist  limit 3;
-- Try to add btree index
create index idx_t_gist_1_using_btree on t_gist (pos);
-- Not work => Using gist index
create index idx_t_gist_1_using_gist on t_gist using gist (pos);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_gist where circle '((100,100) 10)'  @> pos;

/************************************************************************/

-- Example 2: Sorting with a scale index

select * from t_gist order by id <-> 100 limit 10;
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_gist order by id <-> 100 limit 10;
-- Create extension
create extension btree_gist;
-- Add gist index on basic field
create index idx_t_gist_using_gist_2 on t_gist using gist(id);
-- Explain
explain (analyze,verbose,timing,costs,buffers) select * from t_gist order by id <-> 100 limit 10;
