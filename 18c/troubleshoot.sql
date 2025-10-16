When the Database Suddenly Went High CPU

It was a quiet afternoon until OEM alerts started pouring in.
CPU usage: 95%+
Response time: terrible
No recent deployments. No new jobs. Just chaos.

🔍 Investigation Steps:

1️⃣ Checked top SQLs from AWR:

SELECT sql_id, executions, elapsed_time, cpu_time, sql_text
FROM v$sql
ORDER BY cpu_time DESC FETCH FIRST 5 ROWS ONLY;

→ Found one query dominating CPU.

2️⃣ Verified execution plan changes:

SELECT * FROM dba_hist_sql_plan
WHERE sql_id='7abcd123xyz'
ORDER BY timestamp;

→ Plan changed after stats collection the night before.

3️⃣ Checked histogram behavior on a key column:

SELECT endpoint_value, endpoint_number 
FROM dba_tab_histograms 
WHERE table_name='CUSTOMERS' AND column_name='REGION_ID';

→ Skewed data + AUTO sample size = Wrong plan!

✅ Fix:

• Regathered stats with manual sample size:

EXEC DBMS_STATS.GATHER_TABLE_STATS('SALES', 'CUSTOMERS', estimate_percent=>50, method_opt=>'FOR ALL COLUMNS SIZE AUTO');

• Baseline the good plan to prevent:
 surprises:

EXEC DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id=>'7abcd123xyz');

⚡ Result:
CPU dropped from 95% → 40%
Response times normalized.

💡 Lesson:
Sometimes “auto stats” isn’t smart enough.
Understand your data. Control your optimizer.
