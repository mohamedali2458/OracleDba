CONTROLFILE AUTOBACKUPs are OBSOLETE[d]

There was a recent forums discussion about manual controlfile backups being obsolete.  Here I show 
that even autobackups are obsoleted by Oracle.

First I show that CONTROLFILE AUTOBACKUP is ON an RETENTION is set to REDUNDANCY 1

RMAN> show all;
RMAN> list backup of controlfile;

So, I have controlfile autobackups going as far back as 01-Jan.  Quite obvious : I haven't been deleting 
"obsolete" files.  (This is a "play" environment with adequate disk space for multiple backups of a small database).

I now list the OBSOLETE Backups.

RMAN> report obsolete;

My CONTROLFILE AUTOBACKUP Pieces are shown as OBSOLETE.
