SELECT segment_name,
file_id,
block_id
FROM dba_extents
WHERE owner = 'OE'
AND segment_name LIKE 'ORDERS%';

SELECT header_file,header_block FROM dba_segments
WHERE segment_name = 'PERSONS';

ALTER SYSTEM DUMP DATAFILE 397 BLOCK 32811;

Take the obj# shown in second-to-last line

SELECT name
FROM sys.obj$
WHERE obj#='4916681';

