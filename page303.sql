--page 303

--Should be a note that DATETIME should change to reflect your system
--DECLARE @CompareTime DATETIME = '2021-01-03 02:24:04';
DECLARE @CompareTime DATETIME = '2017-11-28 21:37';
SELECT CAST(qsp.query_plan AS XML),
qsrs.*,
qsrs.count_executions,
qsrs.avg_duration,
qsrs.stdev_duration,
qsws.wait_category_desc,
qsws.avg_query_wait_time_ms,
qsws.stdev_query_wait_time_ms
FROM sys.query_store_plan AS qsp
JOIN sys.query_store_runtime_stats AS qsrs
ON qsrs.plan_id = qsp.plan_id
JOIN sys.query_store_runtime_stats_interval AS qsrsi
ON qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
JOIN sys.query_store_wait_stats AS qsws
ON qsws.plan_id = qsrs.plan_id
AND qsws.execution_type = qsrs.execution_type
AND qsws.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
--missing this JOIN for qsq
JOIN  sys.query_store_query qsq
on qsp.query_id = qsq.query_id
--end missing
WHERE qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference')
AND @CompareTime BETWEEN qsrsi.start_time
AND qsrsi.end_time;