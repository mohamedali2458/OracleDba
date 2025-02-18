starting a standby database
startup nomount
alter database mount standby database;
alter database open read only;
alter database recover managed standby database disconnect;
