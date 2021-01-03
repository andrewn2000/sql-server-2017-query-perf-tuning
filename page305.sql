--page305

WITH QSAggregate
AS (SELECT qsrs.plan_id,
           SUM(qsrs.count_executions) AS CountExecutions,
           AVG(qsrs.avg_duration) AS AvgDuration,
           AVG(qsrs.stdev_duration) AS StdDevDuration,
           qsws.wait_category_desc,
           AVG(qsws.avg_query_wait_time_ms) AS AvgWaitTime,
           AVG(qsws.stdev_query_wait_time_ms) AS StDevWaitTime
    FROM sys.query_store_runtime_stats AS qsrs
        JOIN sys.query_store_wait_stats AS qsws
            ON qsws.plan_id = qsrs.plan_id
               AND qsws.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
    GROUP BY qsrs.plan_id,
             qsws.wait_category_desc)
SELECT CAST(qsp.query_plan AS XML),
       qsa.*
FROM sys.query_store_plan AS qsp
    JOIN QSAggregate AS qsa
        ON qsa.plan_id = qsp.plan_id
--missing this JOIN for qsq
JOIN  sys.query_store_query qsq
on qsp.query_id = qsq.query_id
--end missing
WHERE qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');
