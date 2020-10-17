USE [master];

--Query Plans and Text
SELECT  [qs].[sql_handle], [qs].[statement_start_offset], [qs].[statement_end_offset], 
        [qs].[plan_generation_num], [qs].[plan_handle], [qs].[creation_time], 
        [qs].[last_execution_time], [qs].[execution_count], 
        [pt].[text], pp.[query_plan], [tqpp].[query_plan]
--SELECT *
FROM    [sys].[dm_exec_query_stats] [qs]
OUTER APPLY [sys].[dm_exec_sql_text]([qs].[plan_handle]) [pt]
OUTER APPLY [sys].[dm_exec_query_plan]([qs].[plan_handle]) pp
OUTER APPLY [sys].[dm_exec_text_query_plan]([qs].[plan_handle], [qs].[statement_start_offset], [qs].[statement_end_offset]) tqpp
