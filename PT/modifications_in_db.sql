SYS @ pdb1 > desc dba_tab_modifications
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 TABLE_OWNER                                        VARCHAR2(128)
 TABLE_NAME                                         VARCHAR2(128)
 PARTITION_NAME                                     VARCHAR2(128)
 SUBPARTITION_NAME                                  VARCHAR2(128)
 INSERTS                                            NUMBER
 UPDATES                                            NUMBER
 DELETES                                            NUMBER
 TIMESTAMP                                          DATE
 TRUNCATED                                          VARCHAR2(3)
 DROP_SEGMENTS                                      NUMBER

SYS @ pdb1 > desc cdb_tab_modifications
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 TABLE_OWNER                                        VARCHAR2(128)
 TABLE_NAME                                         VARCHAR2(128)
 PARTITION_NAME                                     VARCHAR2(128)
 SUBPARTITION_NAME                                  VARCHAR2(128)
 INSERTS                                            NUMBER
 UPDATES                                            NUMBER
 DELETES                                            NUMBER
 TIMESTAMP                                          DATE
 TRUNCATED                                          VARCHAR2(3)
 DROP_SEGMENTS                                      NUMBER
 CON_ID                                             NUMBER
