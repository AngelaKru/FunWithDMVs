USE [master]

--What is executing
SELECT  [er].[session_id], [er].[request_id], [er].[status], [er].[command], [er].[start_time], [er].[blocking_session_id], 
        [er].[wait_type], [er].[open_transaction_count], [er].[percent_complete], 
        CONVERT(varchar, DATEADD(MILLISECOND, [er].[total_elapsed_time], CONVERT(datetime2(7), '00:00:00', 108)), 108) AS ElapsedHHMMS, 
        [est].[text], [eqp].[query_plan], [eib].[event_info], [eib].[parameters]
FROM    [sys].[dm_exec_requests] [er]
OUTER APPLY [sys].[dm_exec_sql_text]([er].[plan_handle]) est
OUTER APPLY [sys].[dm_exec_query_plan]([er].[plan_handle]) eqp
OUTER APPLY [sys].[dm_exec_input_buffer]([er].[session_id], [er].[request_id]) eib
WHERE   [er].[status] <> 'BACKGROUND' AND [er].[command] <> 'TASK MANAGER' AND [er].[session_id] <> @@SPID
