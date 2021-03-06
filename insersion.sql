USE [monitoring]

---insertion des données dans la table  [lastAgregateDate]
GO
SET IDENTITY_INSERT [enum].[lastAgregateDate] ON 
GO
INSERT [enum].[lastAgregateDate] ([lastAgregateId], [lastDate]) VALUES (1, CAST(N'2018-05-08T12:05:00.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [enum].[lastAgregateDate] OFF
GO


---insertion des données dans la table  processGroups

SET IDENTITY_INSERT [enum].[processGroups] ON 
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (1, N'disk_use_by_the_file_sql_server')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (2, N'cpu')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (3, N'memory')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (4, N'db')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (5, N'allwayson')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (6, N'waits')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (7, N'data')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (8, N'partition')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (9, N'replication')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (10, N'deadlock')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (11, N'disk_OS')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (12, N'express')
GO
INSERT [enum].[processGroups] ([processGroupsId], [processGroupName]) VALUES (13, N'divers')
GO
SET IDENTITY_INSERT [enum].[processGroups] OFF
GO

---insertion des données dans la table  processTypeName
SET IDENTITY_INSERT [enum].[processType] ON 
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (1, N'procedure')
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (2, N'job')
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (3, N'Xevents')
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (4, N'ssis')
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (5, N'powershell')
GO
INSERT [enum].[processType] ([processTypeId], [processTypeName]) VALUES (6, N'diverts')
GO
SET IDENTITY_INSERT [enum].[processType] OFF
GO

--cette procedure fait une insertion automatique des données dans la table enum.process
exec proc_to_generate_process


go
--cette procedure fait une insertion automatique des données dans la table de process d'agregation

exec proc_to_generate_agregation

go


go

--*****************************************************************************************************************
--cette rubrique insert les données fans la table de planification
--********************************************************************************************************************

declare 

@id int
,@physical_name varchar(10)  --recoit le drive name
,@instance varchar(50) = (SELECT @@SERVERNAME as instanceName)  -- nom de l'instence

 --table de reception des différents drive name
declare @drive_name table(id int identity(1,1), physical_name varchar(10))

--recherche des différents drive name
insert @drive_name
-- voir tous les disque utilisé par la bases de données 

SELECT DISTINCT LEFT([filename], 1)  AS 'Drive'
FROM sysaltfiles
ORDER BY [Drive];



--boucle pour inserer dans plinification en ce qui conserne le groupe "disk_use_by_the_file_sql_server" les différentes planifications 
--pour chaque processus 
SELECT TOP 1 @id = id
		,@physical_name = physical_name
	FROM @drive_name

while @id is not null
begin

--SET IDENTITY_INSERT [enum].[planification] ON 

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 1, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 2, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 3, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 4, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 5, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 6, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 7, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 8, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 9, @physical_name, @instance, 1, 120000, 130000, 20180312, 20180312)

--SET IDENTITY_INSERT [enum].[planification] Off

--supressionde id deja iseré
DELETE TOP (1)
		FROM @drive_name
		WHERE id = @id
--nouvelle selection de la table 
		SELECT TOP 1 @id = id
		,@physical_name = physical_name
	FROM @drive_name
--si les lignes de la tables sont vides 
IF @@ROWCOUNT <= 0
			SET @id = NULL
end;

--suite des insertions des autres  planifications 

--SET IDENTITY_INSERT [enum].[planification] On

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 10, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 11, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 12, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 13, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 14, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 15, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 16, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 17, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 18, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 19, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 20, N'RAM', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 21, N'RAM', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 22, N'RAM', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 23, N'RAM', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 24, N'RAM', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 25, N'partition', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 26, N'partition', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 27, N'wait', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 28, N'wait', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 29, N'compression', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 30, N'compression', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 31, N'compression', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 32, N'pk', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 33, N'is_increment', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 34, N'deadlock', @instance, 1, 120000, 130000, 20180312, 20180312)

--
INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 35, N'All_disk', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 36, N'All_disk', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 37, N'All_disk', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 38, N'All_disk', @instance, 1, 120000, 130000, 20180312, 20180312)

-----------
INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 39, N'DATA', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 40, N'LOG', @instance, 1, 120000, 130000, 20180312, 20180312)

------------------
INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 41, N'is_incrémental', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 42, N'no_recompute', @instance, 1, 120000, 130000, 20180312, 20180312)

INSERT [enum].[planification] ( [processId], [parameter], [serverName], [wait], [startTime], [endTime], [startDate], [endDate]) VALUES ( 43, N'data_compression', @instance, 1, 120000, 130000, 20180312, 20180312)

--------------------

--SET IDENTITY_INSERT [enum].[planification] OFF
GO


--creation d'un job à des fins de collectes données 

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'monitoring-process')
EXEC msdb.dbo.sp_delete_job @job_name=N'monitoring-process', @delete_unused_schedule=1
GO

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'monitoring-process', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
DECLARE @instance varchar(50) = (SELECT CONVERT(sysname, SERVERPROPERTY('servername')));
EXEC msdb.dbo.sp_add_jobserver @job_name=N'monitoring-process', @server_name = @instance
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'monitoring-process', @step_name=N'test', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[proc_ToCallprocedureName]', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'monitoring-process', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'monitoring-process', @name=N'test', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10,
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180509, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

--creation d'un job à des fins  d'agregations de  données 
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'monitoring-agregation')
EXEC msdb.dbo.sp_delete_job @job_name=N'monitoring-agregation', @delete_unused_schedule=1
GO

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'monitoring-agregation', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
declare @instanceName varchar(100) = (SELECT CONVERT(sysname, SERVERPROPERTY('servername')));
EXEC msdb.dbo.sp_add_jobserver @job_name=N'monitoring-agregation', @server_name = @instanceName
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'monitoring-agregation', @step_name=N'monitoring-agregation', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[proc_ToCallAgregationName]', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'monitoring-agregation', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'monitoring-agregation', @name=N'monitoring-agregation', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=20, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180510, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO



--**********************************************************************************************************
--creation d'un opérateur qui sera notifier sur l'execution des job

USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'monitoring', 
		@enabled=1, 
		@weekday_pager_start_time=80000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=80000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=80000, 
		@sunday_pager_end_time=180000, 
		@pager_days=127, 
		@email_address=N'marceltsameza@gmail.com', 
		@pager_address=N'marceltsameza@gmail.com'
GO
--********************************************************************************************************

--********************************************************************************************************
--droit d'accès à la base de données 

--USE [master]
--GO
--CREATE LOGIN [ATS] WITH PASSWORD=N'' MUST_CHANGE
--, DEFAULT_DATABASE=[monitoring]
--,DEFAULT_LANGUAGE=[us_english]
--, CHECK_EXPIRATION=ON
--,CHECK_POLICY=ON
--GO


--USE [monitoring]
--GO
--CREATE USER [ATS] FOR LOGIN [ATS]
--GO
--USE [monitoring]
--GO
--ALTER ROLE [db_owner] ADD MEMBER [ATS]
--GO

--USE [monitoring]
--GO
--CREATE USER [monitoring] FOR LOGIN [ATS]
--GO
--USE [msdb]
--GO
--ALTER ROLE [db_datareader] ADD MEMBER [monitoring]
--GO
--*************************************************************************************************************

--**************************************************************************************************
--droit d'accès aux données 

USE master;
GO
 
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'CABR2lle';

CREATE CERTIFICATE monitoring_certificate
WITH SUBJECT = 'monitoring certificate';


USE monitoring;
GO
 
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE monitoring_certificate;

ALTER DATABASE monitoring
SET ENCRYPTION ON;



----commande de test  pour voir l'état de chifrement de la base de données 
--SELECT DB_NAME(database_id) DbName,
--  encryption_state EncryptState,
--  key_algorithm KeyAlgorithm,
--  key_length KeyLength,
--  encryptor_type EncryptType
--FROM sys.dm_database_encryption_keys;

--**********************************************************************************************************
USE [monitoring]
ALTER TABLE [alert].[alertProcess] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [alert].[alertType] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [alert].[logProcessAlert] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)


USE [monitoring]
ALTER TABLE [enum].[agregationLogByDay] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[lastAgregateDate] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[planification] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[process] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[processAgregation] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[processGroups] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[processLog] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

USE [monitoring]
ALTER TABLE [enum].[processType] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)
