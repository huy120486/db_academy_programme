# Prepare local development environment

On this section, we will use `audit_trails` table from mainapp's database.
Drop all other indexes except GIN index on `auditable_type`. If it is not
created yet, please create it first using:

``` sql
postgres=# \c employmenthero_development
employmenthero_development=# create index index_audit_trails_on_auditable_type on audit_trails using gin (auditable_type);
```
