select A.processId, A.processValue, A.description, A.dbName, A.objectIndication, A.status, A.message, A.createDate
, A.serverName
from alertSysteme A INNER JOIN 
(select processId,  MAX(createDate) AS maxDate
		from alertSysteme
		 
		GROUP BY processId
		)
		groupel ON A.processId = groupel.processId 
		AND A.createDate = groupel.maxDate
		where serverName = 'MARCELODJ'
		

--********************************************************************************************************************
select A.processId, A.processValue, A.description, A.dbName, A.objectIndication, A.status, A.message, A.createDate
, A.serverName
from alertSysteme A INNER JOIN 
(select processId,  MAX(createDate) AS maxDate
		from alertSysteme  
		GROUP BY processId
		)
		groupel ON A.processId = groupel.processId 
		AND A.createDate = groupel.maxDate
		where serverName = 'MARCELODJ\SERVER1'
		
		
		

	

 --**********************************************************************************************************************
select processId, description, serverName, dbName, objectIndication, status, message, createDate as createDate 
from dbo.alertSysteme
where objectIndication ='ApexSQL.MonitorAlertActionProfiles'
and serverName='MARCELODJ' 
and dbName ='ApexSQLMonitor' 
and description='db_and_table_data_compression_option'
 order by createDate desc


 --select value1, value3, value4, unitMeasure, serverName, processGroupsId 
 --FROM [dbo].metrics inner join enum.process  on  [dbo].metrics.processId = enum.process.processId
	--	WHERE processGroupsId = (select top (1) processGroupsId from enum.processGroups where processGroupName = 'disk_OS')

	--******************************************************************************************************************
select processId, processValue, warnningValue, emergencyValue ,createDate 
from dbo.alertSysteme 
where objectIndication ='C:\'
and serverName='MARCELODJ\SERVER1' 
and dbName is null 
and description='GetFreeSizeDiskPerCent_OS'
 order by createDate desc

--***************************historiques*******************************************************************************************
INSERT INTO [dbo].[metrics]
           ([processId] ,[value1] ,[value3] ,[value4] ,[unitMeasure] ,[serverName] ,[createDate])
     VALUES
           (38, 9, 'C:\', 'GetFreeSizeDiskPerCent_OS', '%', 'MARCELODJ\SERVER1', '2018-08-15 20:22:31')

--*******************************historique*******************************************************************************************

INSERT INTO [dbo].[metrics]
           ([processId] ,[value1]  ,[value3]  ,[value4]  ,[unitMeasure] ,[dbName]  ,[serverName]  ,[createDate])
     VALUES
           (25,100, 'dbo.TablePartition1', 'empty partition at the end', 'qty', 'simulation', 'MARCELODJ\SERVER1', '2018-07-19 15:57:31')
GO

--****************************rapport disk*********************************************************************************************
SELECT [processId] ,[value1] ,[value3] ,[value4]  ,[unitMeasure] ,[dbName] ,[serverName] ,[createDate] 
  FROM [dbo].[metrics]
	where processId in (35,36,37,38)

--***********************************rapport partition**************************************************************************************
	SELECT [processId] ,[value1]  ,[value3] ,[value4]  ,[unitMeasure] ,[dbName] ,[serverName] ,[createDate] 
  FROM [dbo].[metrics]
	where processId in (26, 25)










use simulation
go

drop table dbo.Hourly
 
/****** Object:  Table [dbo].[Hourly]    Script Date: 18/07/2018 18:14:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Hourly](
	[FullDate] [datetime2](0) NOT NULL,
	[PublisherID] [int] NOT NULL,
 CONSTRAINT [PK_Hourly_Temp] PRIMARY KEY CLUSTERED 
(
	[FullDate] ASC,
	[PublisherID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = off,  STATISTICS_INCREMENTAL=off ,IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO







