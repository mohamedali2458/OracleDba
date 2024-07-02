--Chapter 2: Choosing and Optimizing Indexes  43

select user, sysdate from dual;

/*
An index is a database object used primarily to improve the performance of SQL queries.

If there were no index, you would have to inspect every page of the book to find information. This
results in a great deal of page turning, especially with large books. This is similar to an Oracle query that
does not use an index and therefore has to scan every used block within a table. For large tables, this
results in a great deal of I/O.

Keep in mind that the index isn’t free. It consumes space in the back of the book, and if the material
in the book is ever updated (like a second edition), every modification (insert, update, delete) potentially
requires a corresponding change to the index. It’s important to keep in mind that indexes consume
space and require resources when updates occur.

aspects to consider before you create an index:
    • Type of index
    • Table column(s) to include
    • Whether to use a single column or a combination of columns
    • Special features such as parallelism, turning off logging, compression, invisible indexes, and so on
    • Uniqueness
    • Naming conventions
    • Tablespace placement
    • Initial sizing requirements and growth
    • Impact on performance of SELECT statements (improvement)
    • Impact on performance of INSERT, UPDATE, and DELETE statements
    • Global or local index, if the underlying table is partitioned

