information_schema.tables
information_schema.routines(Procedure & Function)
information_schema.views
information_schema.check_constraints
information_schema.columns
information_schema.constraint_column_usage
information_schema.column_options
information_schema.user_mappings
pg_tables

SELECT * FROM information_schema.tables;

SELECT * FROM information_schema.tables WHERE table_schema = 'information_schema';

SELECT * FROM informaton_schema.routines WHERE specific_schema = 'dvdrental'
AND routine_definition LIKE '%update%';

