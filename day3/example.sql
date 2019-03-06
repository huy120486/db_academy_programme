-- Question: Audit 10 recently deleted Timeshee Entries

-- Disable parallel
set max_parallel_workers_per_gather = 0;

-- Day 1: Index types

-- First result - Using GIN index on auditable_type
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Create index btree on event
create index audit_trail_on_event_using_btree on audit_trails(event);

-- BitmapAnd scan
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Don't use btree for sparse data
select distinct event from audit_trails;

-- Should create index gin on event
create index audit_trail_on_event_using_gin on audit_trails using gin (event);
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Check index size
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
  nspname not in ('pg_catalog','information_schema') AND
  relname like 'audit_trail_on%';

-- Day 2: Compound index
create index audit_trail_on_event_and_type_using_btree on audit_trails using btree (event, auditable_type);
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Day 3: Sort
-- Optimize sort using index
create index audit_trail_on_created_at on audit_trails (created_at);
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Using partial index to enhance sort
create index audit_trail_on_partial_created_at on audit_trails (created_at) where event='destroy' and auditable_type='TimesheetEntry';
explain analyze select * from audit_trails where event='destroy' and auditable_type='TimesheetEntry' order by created_at desc limit 10;

-- Index size
SELECT nspname,relname,pg_size_pretty(pg_relation_size(c.oid)) as "size"
FROM pg_class c left join pg_namespace n on ( n.oid=c.relnamespace)
WHERE
nspname not in ('pg_catalog','information_schema') AND
relname like 'audit_trail_on%';
