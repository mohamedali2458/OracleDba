Transparent Data Encryption (TDE) in Oracle Database

TDE encrypts data at rest — meaning data stored in datafiles, redo logs, and backups is encrypted automatically, without any changes to your application code.

🔑 Core Concepts
Term	                        Description
Master Encryption Key (MEK)	    Top-level key stored in a Wallet or HSM
Tablespace Encryption Key	    Derived from MEK, used to encrypt tablespace data
Oracle Wallet	                Software keystore (file) that stores the MEK
Auto-login Wallet	            Wallet that opens automatically on DB startup

📌 Architecture Overview
Application → Oracle DB (plaintext) → TDE Layer → Encrypted Datafiles (.dbf)
                                           ↑
                                      Oracle Wallet
                                   (Master Encryption Key)

🛠️ Step-by-Step Implementation
Step 1 — Set the Keystore Location (in sqlnet.ora)
Edit $ORACLE_HOME/network/admin/sqlnet.ora:

ENCRYPTION_WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /u01/app/oracle/wallet)
    )
  )

Step 2 — Create the Keystore (Wallet)
sql
-- Connect as SYSDBA
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '/u01/app/oracle/wallet'
  IDENTIFIED BY "WalletPassword123";

This creates ewallet.p12 in the specified directory.

Step 3 — Open the Keystore
sql
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN
  IDENTIFIED BY "WalletPassword123"
  CONTAINER = ALL;   -- Use ALL for CDB; omit for non-CDB

Step 4 — Create and Set the Master Encryption Key
sql
ADMINISTER KEY MANAGEMENT SET KEY
  IDENTIFIED BY "WalletPassword123"
  WITH BACKUP
  CONTAINER = ALL;

Verify:
sql
SELECT KEY_ID, KEYSTORE_TYPE, STATUS, BACKED_UP
FROM V$ENCRYPTION_KEYS;

Step 5 — Enable Auto-Login (Optional but Recommended)
Avoids manual wallet open after restarts:

sql
ADMINISTER KEY MANAGEMENT CREATE AUTO_LOGIN KEYSTORE
  FROM KEYSTORE '/u01/app/oracle/wallet'
  IDENTIFIED BY "WalletPassword123";

This creates cwallet.sso — an auto-login wallet file.

Step 6 — Encrypt a Tablespace

Option A: New Tablespace (recommended)

sql
CREATE TABLESPACE encrypted_ts
  DATAFILE '/u01/oradata/orcl/encrypted_ts01.dbf' SIZE 100M
  ENCRYPTION USING AES256
  DEFAULT STORAGE (ENCRYPT);

Option B: Encrypt Existing Tablespace (offline conversion)

sql
ALTER TABLESPACE users ENCRYPTION ONLINE
  USING AES256 ENCRYPT;

Step 7 — Encrypt Individual Columns (Column-Level TDE)
sql
CREATE TABLE hr.employees (
  employee_id   NUMBER,
  first_name    VARCHAR2(50),
  salary        NUMBER ENCRYPT USING AES256,  -- encrypted column
  ssn           VARCHAR2(11) ENCRYPT           -- default algorithm
);

-- Or alter existing table:
ALTER TABLE hr.employees
  MODIFY (salary ENCRYPT USING AES256);


🔍 Verification Queries
sql
-- Check keystore status
SELECT STATUS, WALLET_TYPE FROM V$ENCRYPTION_WALLET;
-- Check encrypted tablespaces
SELECT TABLESPACE_NAME, ENCRYPTED FROM DBA_TABLESPACES;
-- Check encrypted columns
SELECT OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG
FROM DBA_ENCRYPTED_COLUMNS;

🔄 Key Rotation (Rekeying)
Rotate the master key periodically for security compliance:

sql
ADMINISTER KEY MANAGEMENT SET KEY
  IDENTIFIED BY "WalletPassword123"
  WITH BACKUP USING 'key_backup_tag'
  CONTAINER = ALL;


⚠️ Important Considerations
        Performance: AES256 has minimal (~3-5%) overhead due to hardware acceleration (AES-NI).
        Backup the Wallet: Loss of wallet = loss of all encrypted data. Always backup ewallet.p12.
        Redo Logs & Temp files: TDE does NOT automatically encrypt redo logs unless you configure it separately.
        Export/Import: Use ENCRYPTION_PASSWORD with expdp/impdp for encrypted exports.
        Oracle Version: Full tablespace-level TDE is available from Oracle 11gR2+. Column-level TDE from 10gR2+.

