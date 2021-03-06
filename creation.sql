---- To allow advanced options to be changed.  
--EXEC sp_configure 'show advanced options', 1;  
--GO  
---- To update the currently configured value for advanced options.  
--RECONFIGURE;  
--GO  
---- To enable the feature.  
--EXEC sp_configure 'xp_cmdshell', 1;  
--GO  
---- To update the currently configured value for this feature.  
--RECONFIGURE;  
--GO 

USE master
GO
--*********************************************************************************************************
-- delete data base if exite
IF EXISTS(SELECT name FROM sys.databases
    WHERE name = 'monitoring')

     ALTER DATABASE monitoring SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE monitoring
GO

--création de la base données
CREATE DATABASE monitoring
GO

USE [monitoring]
GO
--***************************************************************************************************************************

--****************************************************************************************
--creation des différents shémas pour l'utilisation de la base de données
--****************************************************************************************
/****** pour les procedures d'agregation ******/
CREATE SCHEMA [agregation]
GO

/******pour les tables non tranferable vers le server centrale ******/
CREATE SCHEMA [enum]
GO

/****** pour les procedures de processus ******/
CREATE SCHEMA [process]
GO
--************************************************************************************************************************************************************

--****************************************************************************************************************************************************
---------------------------  creation des différentes tables ----------------------------------------------------------
--****************************************************************************************************************************************************
/****** Object:  Table [dbo].[agregation_by_day]    Script Date: 14/05/2018 09:41:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--table d'agregation de donnée par jour

CREATE TABLE [dbo].[agregation_by_day] (
	agregationId INT NOT NULL IDENTITY(1, 1) 
	,processId int
	,currentValue decimal(18,2)
	,minimum decimal(18,2)
	,maximum decimal(18,2)
	,croissance decimal(18,2)
	,volumePoint varchar (50)
	,tableRecort int
	,unit varchar (50)
	,description varchar (1000)
	,dbName varchar(100)
	,serverName varchar(100)
	,createDate datetime2(0)
	,isSync int
	,PRIMARY KEY (agregationId, serverName)
	);
GO
/****** Object:  Table [dbo].[express]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--table de reception des differentes metrics ou données collecté
CREATE TABLE [dbo].[metrics](
	[metricsId] [int] IDENTITY(1,1) NOT NULL,
	[processId] [int] NOT NULL,
	[value1] [int] NULL,
	[value2] [int] NULL,
	[value3] [varchar](1000) NULL,
	[value4] [varchar](1000) NULL,
	[unitMeasure] [varchar](50) NULL,
	[dbName] [varchar](50) NULL,
	[serverName] [varchar](100) NOT NULL,
	[createDate] [datetime2](0) NOT NULL,
	[isSync] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[metricsId] ASC,
	[serverName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[agregationLogByDay]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--indiquera si si une agregation a fonctionnée ou pas 

CREATE TABLE [enum].[agregationLogByDay](
	[agregationLogId] [int] IDENTITY(1,1) NOT NULL,
	[processAgregationId] [int] NULL,
	[agregationLogLogName] [varchar](100) NOT NULL,
	[lastExecuteLogOfAgregate] [datetime2](7) NULL,
	[isProcessError] [bit] NULL,
	[ErrorMessage] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[agregationLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [enum].[lastAgregateDate]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- table de reference qui recoit la dernière date d'agretion 
--
CREATE TABLE [enum].[lastAgregateDate](
	[lastAgregateId] [int] IDENTITY(1,1) NOT NULL,
	[lastDate] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[lastAgregateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[planification]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--table de planification des différents processus 

CREATE TABLE [enum].[planification](
	[planificationId] [int] IDENTITY(1,1) NOT NULL,
	[processId] [int] NOT NULL,
	[parameter] [varchar](100) NULL,
	[serverName] [varchar](50) NULL,
	[wait] [int] NULL,
	[startTime] [int] NULL,
	[endTime] [int] NULL,
	[startDate] [int] NULL,
	[endDate] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[planificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[process]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--table recevant les différents processus qui se font par une insertion automatique 

CREATE TABLE [enum].[process](
	[processId] [int] NOT NULL,
	[processGroupsId] [int] NOT NULL,
	[processTypeId] [int] NOT NULL,
	[processName] [varchar](100) NULL,
	[procedureName] [varchar](100) NOT NULL,
	[processDescription] [varchar](1000) NULL,
	[proccessType] [varchar](100) NULL,
	[defaultWait] [int] NULL,
	[monitoringLength] [int] NULL,
	[lastDuration] [int] NULL,
	[jobLevel] [int] NULL,
	[retention] [datetime2](0) NULL,
	[processRetention] [datetime2](0) NULL,
	[auteur] [varchar](100) NULL,
	[createDate] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[processId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[processAgregation]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--table recevant les différents processus d'agregation qui se font par une insertion automatique 

CREATE TABLE [enum].[processAgregation](
	[processAgregationId] [int] IDENTITY(1,1) NOT NULL,
	[processTypeId] [int] NOT NULL,
	[processGroupsId] [int] NOT NULL,
	[processAgregationName] [varchar](200) NULL,
	[frequency] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[processAgregationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[processGroups]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--table permettant de regrouper les process par groupe 
CREATE TABLE [enum].[processGroups](
	[processGroupsId] [int] IDENTITY(1,1) NOT NULL,
	[processGroupName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[processGroupsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [enum].[processLog]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--indiquera si  un processus a fonctionnée ou pas 
CREATE TABLE [enum].[processLog](
	[processLogId] [int] IDENTITY(1,1) NOT NULL,
	[processId] [int] NOT NULL,
	[processLogName] [varchar](100) NOT NULL,
	[lastExecuteLog] [datetime2](7) NULL,
	[isProcessError] [bit] NULL,
	[ErrorMessage] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[processLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = On, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [enum].[processType]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--table regroupant les process par type
CREATE TABLE [enum].[processType](
	[processTypeId] [int] IDENTITY(1,1) NOT NULL,
	[processTypeName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[processTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


--****************************************************************************************************************************************************
---------------------------  creation des différentes contraintes de tables ----------------------------------------------------------
--****************************************************************************************************************************************************
ALTER TABLE [dbo].[agregation_by_day]  WITH CHECK ADD  CONSTRAINT [process_processId_agregation_by_day_processId] FOREIGN KEY([processId])
REFERENCES [enum].[process] ([processId])
GO
ALTER TABLE [enum].[processAgregation]  WITH CHECK ADD  CONSTRAINT [prcessAgregation_processId_processType_processId] FOREIGN KEY([processTypeId])
REFERENCES [enum].[processType] ([processTypeId])
GO
ALTER TABLE [dbo].[agregation_by_day] CHECK CONSTRAINT [process_processId_agregation_by_day_processId]
GO
ALTER TABLE [dbo].[metrics]  WITH CHECK ADD  CONSTRAINT [metrics_processId_processTable_processId] FOREIGN KEY([processId])
REFERENCES [enum].[process] ([processId])
GO
ALTER TABLE [dbo].[metrics] CHECK CONSTRAINT [metrics_processId_processTable_processId]
GO
ALTER TABLE [enum].[agregationLogByDay]  WITH CHECK ADD  CONSTRAINT [agregationLog] FOREIGN KEY([processAgregationId])
REFERENCES [enum].[processAgregation] ([processAgregationId])
GO
ALTER TABLE [enum].[agregationLogByDay] CHECK CONSTRAINT [agregationLog]
GO
ALTER TABLE [enum].[planification]  WITH CHECK ADD  CONSTRAINT [planification_processId_processTable_processId] FOREIGN KEY([processId])
REFERENCES [enum].[process] ([processId])
GO
ALTER TABLE [enum].[planification] CHECK CONSTRAINT [planification_processId_processTable_processId]
GO
ALTER TABLE [enum].[process]  WITH CHECK ADD  CONSTRAINT [groups_groupsId_processTable_groupsId] FOREIGN KEY([processGroupsId])
REFERENCES [enum].[processGroups] ([processGroupsId])
GO
ALTER TABLE [enum].[processAgregation]  WITH CHECK ADD  CONSTRAINT [groups_groupsId_processAgregation_groupsId] FOREIGN KEY([processGroupsId])
REFERENCES [enum].[processGroups] ([processGroupsId])
GO
ALTER TABLE [enum].[process] CHECK CONSTRAINT [groups_groupsId_processTable_groupsId]
GO
ALTER TABLE [enum].[process]  WITH CHECK ADD  CONSTRAINT [processType_processTypeId_processTable_processTypeId] FOREIGN KEY([processTypeId])
REFERENCES [enum].[processType] ([processTypeId])
GO
ALTER TABLE [enum].[process] CHECK CONSTRAINT [processType_processTypeId_processTable_processTypeId]
GO
ALTER TABLE [enum].[processLog]  WITH CHECK ADD  CONSTRAINT [process_processId_processLog_processId] FOREIGN KEY([processId])
REFERENCES [enum].[process] ([processId])
GO
ALTER TABLE [enum].[processLog] CHECK CONSTRAINT [process_processId_processLog_processId]
GO
/****** Object:  StoredProcedure [agregation].[get_db_and_Table_with_partition_for_express_analyse]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--****************************************************************************************************************************************************
---------------------------  creation des différents procedure ----------------------------------------------------------
--****************************************************************************************************************************************************


/****** Object:  StoredProcedure [agregation].[proc_agreggation_data_by_day]    Script Date: 14/05/2018 09:41:49 ******/
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_All_disk_OS_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [agregation].[proc_agreggation_All_disk_OS_by_day] 

@lastDate DATETIME2(0) 
,@currentDate DATETIME2(0)

----********************************************************************************
----cette procedure aghrège les données du groupe   [disk_OS]

----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
---- 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 11
-- ### frequency: day

AS
BEGIN

--insertion des données dans la table d'agregation

 INSERT INTO [dbo].[agregation_by_day] 
 (
   processId
   ,currentValue
	,minimum
	,maximum
	,croissance 
    ,volumePoint
    ,unit
	,description
	,serverName
	,createDate
 )

select 
	 a.processId
	,a.currentValue  
	,a.minimum
	, a.maximum
	, a.croissance 
    ,a.value3
    ,a.unitMeasure
	,a.value4
	,a.serverName
	, a.createDate
from 
(
--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************
    SELECT 
	  m.processId
	,value1  as currentValue 
	, min(value1) OVER (PARTITION BY  value3, value4 order by m.createDate ) as minimum
	, max(value1) OVER (PARTITION BY  value3, value4 order by m.createDate ) as maximum
	, value1 - LAG (value1, 1,0) OVER (PARTITION BY  value3, value4 order by m.createDate) AS  croissance 
    ,value3
    ,unitMeasure
	,value4
	,serverName
	,ROW_NUMBER () OVER (PARTITION BY  value3, value4 order by m.createDate desc ) as rn
	,GETDATE()  as createDate
		FROM [dbo].metrics m inner join enum.process  on m.processId = enum.process.processId
		WHERE processGroupsId = (select top (1) processGroupsId from enum.processGroups where processGroupName = 'disk_OS')
			AND  m.createDate > @lastDate  
			AND m.createDate < @currentDate      
			AND value1 IS NOT NULL
	) a

	where a.rn = 1

		
end 


GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_data_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [agregation].[proc_agreggation_data_by_day] 

@lastDate DATETIME2(0)
,@currentDate DATETIME2(0)

----********************************************************************************
----cette procedure aghrège les données du groupe   [data]

----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
---- 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 7
-- ### frequency: day

AS
BEGIN
	--insertion dans la table d'agrégation des données 
	INSERT INTO [dbo].[agregation_by_day] (
		processId
		,currentValue
		,minimum
		,maximum
		,croissance
		,volumePoint
		,tableRecort
		,unit
		,description
		,dbName
		,serverName
		,createDate
		)
	SELECT 
		a.processId
		,a.currentValue
		,a.minimum
		,a.maximum
		,a.croissance
		,a.value3
		,a.tableRecort
		,a.unitMeasure
		,a.value4
		,a.dbName
		,a.serverName
		,a.createDate
	FROM (

--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************
		SELECT m.processId
			,value1 AS currentValue
			,min(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS minimum
			,max(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS maximum
			,value1 - LAG(value1, 1, 0) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS croissance
			,value3
			,value2 AS tableRecort
			,unitMeasure
			,value4
			,dbName AS dbName
			,serverName
			,ROW_NUMBER() OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate DESC
				) AS rn
			,GETDATE() AS createDate
		FROM [dbo].metrics m
		INNER JOIN enum.process  ON m.processId = enum.process.processId
		WHERE processGroupsId = (
				SELECT processGroupsId
				FROM enum.processGroups
				WHERE processGroupName = 'data'
				)
			AND m.createDate > @lastDate
			AND m.createDate < @currentDate
			AND value1 IS NOT NULL
		) a
	WHERE a.rn = 1
END

GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_dataBase_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [agregation].[proc_agreggation_dataBase_by_day] 

@lastDate DATETIME2(0)
,@currentDate DATETIME2(0)

	----********************************************************************************
	----cette procedure agrège les données du groupe database se trouvant dans la tables de métriques
	----
	----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 4
-- ### frequency: day

AS
BEGIN

	INSERT INTO [dbo].[agregation_by_day] (	
		processId
		,currentValue
		,minimum
		,maximum
		,croissance
		,volumePoint
		,unit
		,description
		,dbName
		,serverName
		,createDate
		)
	SELECT
		a.processId 
		,a.currentValue
		,a.minimum
		,a.maximum
		,a.croissance
		,a.value3
		,a.unitMeasure
		,a.value4
		,a.dbName
		,a.serverName
		,a.createDate
	FROM (

	--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************
		SELECT m.processId
			,value1 AS currentValue
			,min(value1) OVER (
				PARTITION BY dbName
				,value4 ORDER BY m.createDate
				) AS minimum
			,max(value1) OVER (
				PARTITION BY dbname
				,value4 ORDER BY m.createDate
				) AS maximum
			,value1 - LAG(value1, 1, 0) OVER (
				PARTITION BY dbName
				,value4 ORDER BY m.createDate
				) AS croissance
			,value3
			,unitMeasure
			,value4
			,dbName
			,serverName
			,ROW_NUMBER() OVER (
				PARTITION BY dbName
				,value4 ORDER BY m.createDate DESC
				) AS rn
			,GETDATE() AS createDate
		FROM [dbo].metrics m
		INNER JOIN enum.process ON m.processId = enum.process.processId
		WHERE processGroupsId = (
				SELECT TOP (1) processGroupsId
				FROM enum.processGroups
				WHERE processGroupName = 'db'
				)
			AND m.createDate > @lastDate
			AND m.createDate < @currentDate
			AND value1 IS NOT NULL
		) a
	WHERE a.rn = 1
END


GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_disk_used_sql_server_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [agregation].[proc_agreggation_disk_used_sql_server_by_day] 

@lastDate DATETIME2(0) 
,@currentDate DATETIME2(0)

	----********************************************************************************
	----cette procedure agrège les données du groupe disk_use_by_the_file_sql_server se trouvant dans la tables de métriques
	----
	----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 1
-- ### frequency: day

AS
BEGIN


 INSERT INTO [dbo].[agregation_by_day] 
 (
   processId 
  ,currentValue
	,minimum
	,maximum
	,croissance 
    ,volumePoint
    ,unit
	,description
	,serverName
	,createDate
 )

select 
	a.processId 
	,a.currentValue  
	,a.minimum
	, a.maximum
	, a.croissance 
    ,a.value3
    ,a.unitMeasure
	,a.value4
	,a.serverName
	, a.createDate
from 
(

	--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************

    SELECT 
	  m.processId
	,value1  as currentValue 
	, min(value1) OVER (PARTITION BY  value3, value4 order by m.createDate ) as minimum
	, max(value1) OVER (PARTITION BY  value3, value4 order by m.createDate ) as maximum
	, value1 - LAG (value1, 1,0) OVER (PARTITION BY  value3, value4 order by m.createDate) AS  croissance 
    ,value3
    ,unitMeasure
	,value4
	,serverName
	,ROW_NUMBER () OVER (PARTITION BY  value3, value4 order by m.createDate desc ) as rn
	,GETDATE()  as createDate
		FROM [dbo].metrics m inner join enum.process  on m.processId = enum.process.processId
		WHERE processGroupsId = (select top (1) processGroupsId from enum.processGroups where processGroupName = 'disk_use_by_the_file_sql_server')
			AND  m.createDate > @lastDate  
			AND m.createDate < @currentDate      
			AND value1 IS NOT NULL
	) a

	where a.rn = 1

		
end 

GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_memory_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [agregation].[proc_agreggation_memory_by_day] 

   @lastDate DATETIME2(0)
	,@currentDate DATETIME2(0)
	----********************************************************************************
	----cette procedure agrège les données du groupe memoire se trouvant dans la tables de métriques
	----
	----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 3
-- ### frequency: day
AS
BEGIN

	INSERT INTO [dbo].[agregation_by_day] (
		processId
		,currentValue
		,minimum
		,maximum
		,croissance
		,volumePoint
		,unit
		,description
		,serverName
		,createDate
		)
	SELECT
	 a.processId
		,a.currentValue
		,a.minimum
		,a.maximum
		,a.croissance
		,a.value3
		,a.unitMeasure
		,a.value4
		,a.serverName
		,a.createDate
	FROM (
	
	--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************
		SELECT m.processId
			,value1 AS currentValue
			,min(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS minimum
			,max(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS maximum
			,value1 - LAG(value1, 1, 0) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS croissance
			,value3
			,unitMeasure
			,value4
			,serverName
			,ROW_NUMBER() OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate DESC
				) AS rn
			,GETDATE() AS createDate
		FROM [dbo].metrics m
		INNER JOIN enum.process ON m.processId = enum.process.processId
		WHERE processGroupsId = (
				SELECT TOP (1) processGroupsId
				FROM enum.processGroups
				WHERE processGroupName = 'memory'
				)
			AND m.createDate > @lastDate
			AND m.createDate < @currentDate
			AND value1 IS NOT NULL
		) a
	WHERE a.rn = 1
END

GO
/****** Object:  StoredProcedure [agregation].[proc_agreggation_partition_by_day]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [agregation].[proc_agreggation_partition_by_day] 

@lastDate DATETIME2(0)
,@currentDate DATETIME2(0)

	----********************************************************************************
	----cette procedure agrège les données du groupe partition se trouvant dans la tables de métriques
	----
	----en cas d'ajout d'une procedures  fesant la meme chose, elle devra avoir la syntaxe ci-dessous 
----**************************************************************************************

-- ### processTypeId: 1 
-- ### processGroupsId: 8
-- ### frequency: day

AS
BEGIN

	INSERT INTO [dbo].[agregation_by_day] (
		processId
		,currentValue
		,minimum
		,maximum
		,croissance
		,volumePoint
		,unit
		,description
		,dbName
		,serverName
		,createDate
		)
	SELECT
	  a.processId
		,a.currentValue
		,a.minimum
		,a.maximum
		,a.croissance
		,a.value3
		,a.unitMeasure
		,a.value4
		,a.dbName
		,a.serverName
		,a.createDate
	FROM (

	--**********************************************************************************************************************
--selectionne la valeur corante d'une processus 
--calcule le max, min, et fait un calcul de croissance 
--et donc la date de creation doit etre superieure a la derniere date d'agregation et superieure à la date courante 
-- ROW_NUMBER permet d'avoir le set données selectionné 
--*******************************************************************************************************************
		SELECT m.processId
			,value1 AS currentValue
			,min(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS minimum
			,max(value1) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS maximum
			,value1 - LAG(value1, 1, 0) OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate
				) AS croissance
			,value3
			,unitMeasure
			,value4
			,dbName
			,serverName
			,ROW_NUMBER() OVER (
				PARTITION BY value3
				,value4 ORDER BY m.createDate DESC
				) AS rn
			,GETDATE() AS createDate
		FROM [dbo].metrics m
		INNER JOIN enum.process ON m.processId = enum.process.processId
		WHERE processGroupsId = (
				SELECT processGroupsId
				FROM enum.processGroups
				WHERE processGroupName = 'partition'
				)
			AND  m.createDate > @lastDate  
			AND m.createDate < @currentDate      
			AND value1 IS NOT NULL
		) a
	WHERE a.rn = 1
END

GO
/****** Object:  StoredProcedure [dbo].[get_table_without_compresses]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  proc [dbo].[get_table_without_compresses]

----********************************************************************************
	----cette procedure recupere les bases de données et tables non compressées
	-- elle sera utilisée pour calculer la taille de ces tables
	----**************************************************************************************

as 
begin

	--déclaration de variable

declare  @id int
,@dbName varchar(50)
,@db_whith_without_compresses Nvarchar(max)
, @dbname2 sysname 

	--table temporaire de reception de bases données et table
declare  @db table (id int identity(1,1), dbName varchar(50))


INSERT @db (dbName)
	SELECT name
	FROM sys.databases
	WHERE database_id > 4

SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @db
	ORDER BY id

--boucle sur les différentes lignes de la tables 
while @id is not null                          
begin 
--recupère en fonction de la database recupère les tables non compressées et la table 

select @dbname2 = dbName from @db where id = @id;
select @db_whith_without_compresses = N'SELECT ''' + @dbname2 +''' as dbName,   sc.name + ''.'' +t.name  as tableName, SUM(p.rows)  as records
								FROM '+ @dbName2 +'.sys.tables t
								INNER JOIN '+ @dbName2 +'.sys.partitions p   ON t.object_id = p.object_id
								inner join '+ @dbName2 +'.sys.schemas sc on sc.schema_id = t.schema_id 
								WHERE data_compression = 0 
								and partition_number <> 1
                GROUP BY sc.name, t.name, p.data_compression'						
		
	EXECUTE sp_executesql @db_whith_without_compresses

--supression de la ligne déja taitées 	
DELETE
		FROM @db
		WHERE id = @id
--select ion d'une nouvelle  pour un nouveau traitement 

		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @db
		ORDER BY id
--si les lignes sont à 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL

	END



end


GO
/****** Object:  StoredProcedure [dbo].[get_table_without_PrimaryKey]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[get_table_without_PrimaryKey]
	----********************************************************************************
	----cette procedure recupere les base de données et tables sans clé primaire
	--elle sera utilisé pour calculler la taille de ces tables
	----**************************************************************************************
AS
BEGIN
	DECLARE @id INT
		,@dbName VARCHAR(50)
		,@db_and_table_without_PrimaryKey NVARCHAR(max)
		,@dbname2 SYSNAME

--table de reception des db
	DECLARE @db TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(50)
		)
--sinsertion dans la table des db non système
	INSERT @db (dbName)
	SELECT name
	FROM sys.databases
	WHERE database_id > 4


	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @db
	ORDER BY id

--boucle sur chaque db
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @dbname2 = dbName
		FROM @db
		WHERE id = @id;
--en fonction de la db recupère toutes les tables sans PK
		SELECT @db_and_table_without_PrimaryKey = N'SELECT TABLE_CATALOG,   TABLE_SCHEMA +''.''+TABLE_NAME  as tableName
								FROM ' + @dbName + '.information_schema.tables 
								WHERE TABLE_NAME 
                                 NOT IN(
                                   SELECT TABLE_NAME 
								   from ' + @dbName + '.information_schema.table_constraints
                                   WHERE constraint_type = ''Primary Key'' )
                                   AND TABLE_TYPE = ''BASE TABLE'''

		
		EXECUTE sp_executesql @db_and_table_without_PrimaryKey
--supression de la ligne deja traitée
		DELETE
		FROM @db
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @db
		ORDER BY id
--si la ligne vaut 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END
END
GO
/****** Object:  StoredProcedure [dbo].[getTable_with_partition]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getTable_with_partition]

	--cette procedure recupère les  bases de données avec les tables partitionnées
	--elle sera par la suite utilisées dans le groupe partition pour calculer les différents processus de partitions
AS
BEGIN

	DECLARE @id INT
		,@dbName VARCHAR(50)
		,@db_whith_Table_partition NVARCHAR(max)
		,@dbname2 SYSNAME
	DECLARE @db TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(50)
		)
--table temporaire de reception des bases de données no système
	DECLARE @receptPartitions TABLE (
		dbName VARCHAR(100)
		,tableName VARCHAR(100)
		)
--insertion des données dans cette table 
	INSERT @db (dbName)
	SELECT name
	FROM sys.databases
	WHERE database_id > 4

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @db
	ORDER BY id

	--boucle sur chaque id de la table 
	WHILE @id IS NOT NULL 
	BEGIN
		SELECT @dbname2 = dbName
		FROM @db
		WHERE id = @id;

--en fonction de la db recherche toute les tables partitionnées 
		SELECT @db_whith_Table_partition = N'SELECT ''' + @dbname2 + ''' as dbName,   sc.name +''.''+t.name  as tableName
								FROM ' + @dbName2 + '.sys.tables t
								INNER JOIN ' + @dbName2 + '.sys.partitions p  ON p.object_id = t.object_id
								INNER JOIN ' + @dbName2 + '.sys.schemas AS [sc] ON Sc.schema_id = t.schema_id
								where partition_number <> 1
								 group by t.name , sc.name'

		
		EXECUTE sp_executesql @db_whith_Table_partition
--supression de la ligne deja traitée
		DELETE
		FROM @db
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @db
		ORDER BY id
--si la ligne vaut 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetDbName]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_GetDbName]

--cette proc recuprere toute les database non système d'une instence


AS
BEGIN
	--noms des bases de données non système  d'une instance sql server
	SELECT name
	FROM sys.databases
	WHERE database_id > 4
END
	
GO
/****** Object:  StoredProcedure [dbo].[proc_GetwaitType]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_GetwaitType]

--cette ^procedure recupere les types de wait urgent 
--elle sera utilisé pour les processus du groupe wait

AS
BEGIN

	SELECT s.wait_type
	FROM sys.dm_os_wait_stats s
	CROSS APPLY sys.dm_os_waiting_tasks
	WHERE s.wait_type IN (
			'ASYNC_NETWORK_IO'
			,'CXPACKET'
			,'NETWORK_IO'
			,'LCK_M_IS'
			,'PAGEIOLATCH_SH'
			,'SOS_SCHEDULER_YIELD'
			)
		AND session_id > 50
END
GO
/****** Object:  StoredProcedure [dbo].[proc_to_generate_agregation]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_to_generate_agregation]

	-- cette procedure permet une insersion automatique des données dans la table de process d'agregation
AS
BEGIN
	DECLARE @Count INT = 1;
	DECLARE @CountSP INT = 1;
	DECLARE @nbSP INT;
	DECLARE @NameSP SYSNAME;
	DECLARE @StrSQL NVARCHAR(MAX);

	-- table de reception des proceduresNames
	DECLARE @temptable0 TABLE (
		rowid INT IDENTITY(1, 1)
		,SPName SYSNAME
		);
	-- Table qui recevra les informations finales 
	DECLARE @temptable3 TABLE (
		processAgreggationId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
		,processAgreggationName VARCHAR(200)
		,frequency VARCHAR(100)
		);

	--DMV qui affiche les infos sur les noms des sp et noms de shémas d'une db spécifique
	--------------------select * from   information_schema.routines
	-- Liste des procedures de la base de donnée en ce qui concerne la collecte de donnés
	INSERT @temptable0 (SPName)
	SELECT SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME
	FROM [monitoring].information_schema.routines
	WHERE routine_type = 'PROCEDURE'
		AND SPECIFIC_SCHEMA = 'agregation'

	SELECT @nbSP = COUNT(1)
	FROM @temptable0

	WHILE @CountSP <= @nbSP
	BEGIN
		SELECT @NameSP = SPName
		FROM @temptable0
		WHERE rowid = @CountSP;

		--sera inserer ici les règles définies dans nos sp
		CREATE TABLE tempdb.dbo.temptable1 (TEXT VARCHAR(MAX));

		--les infos seront traitée de la tempdb.dbo.temptable1  et renvoyées dans cette table
		CREATE TABLE tempdb.dbo.temptable2 (
			rowid INT IDENTITY(1, 1)
			,TEXT VARCHAR(255)
			);

		--sp_helptext procédure système qui affiche la définition d'une règle définie par l'utilisateur
		SET @StrSQL = 'INSERT INTO tempdb.dbo.temptable1 EXEC (''sp_helptext ''''' + @NameSP + ''''''')';

		EXEC sp_executesql @StrSQL;

		INSERT INTO tempdb.dbo.temptable2
		SELECT CASE 
				when text like '%### processTypeId%' then REPLACE(text,'-- ### processTypeId: ', '')
			  when text like '%### processGroupsId%' then REPLACE(text,'-- ### processGroupsId: ', '')
				WHEN TEXT LIKE '%### frequency%' THEN REPLACE(TEXT, '-- ### frequency: ', '')
				ELSE ''
				END AS DESCRIPTION
		FROM tempdb.dbo.temptable1
		WHERE TEXT LIKE '%###%';

		--select distinct ascii(substring(text,2,1)) FROM tempdb.dbo.temptable2 WHERE rowid = 1
		INSERT INTO enum.processAgregation (processTypeId, processGroupsId, processAgregationName ,frequency
			)
			select
			(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 1) AS processTypeId
		    ,(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 2) AS processGroupsId
				,@NameSP
			,(SELECT TEXT FROM tempdb.dbo.temptable2 WHERE rowid = 3) AS frequency

		DROP TABLE tempdb.dbo.temptable1;

		DROP TABLE tempdb.dbo.temptable2;

		SET @CountSP += 1;
	END;

	--SELECT * from enum.processAgreggation
	DELETE
	FROM @temptable0
END
GO
/****** Object:  StoredProcedure [dbo].[proc_to_generate_process]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_to_generate_process]

	--cette procedure permet une insertion automatique des données dans la table de processus de collecte de données 
AS
BEGIN
	DECLARE @Count INT = 1;
DECLARE @CountSP INT = 1;
DECLARE @nbSP INT;
DECLARE @NameSP SYSNAME;
DECLARE @StrSQL NVARCHAR(MAX);

-- table de reception des proceduresNames
declare @temptable0 table (
     rowid int IDENTITY(1,1),
     SPName SYSNAME
);



--DMV qui affiche les infos sur les noms des sp et noms de shémas d'une db spécifique
--------------------select * from   information_schema.routines

-- Liste des procedures de la base de donnée en ce qui concerne la coll[enum].[processGroups]ecte de donnés
INSERT @temptable0 (SPName)
select SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME
 from [monitoring].information_schema.routines
where routine_type = 'PROCEDURE'  and SPECIFIC_SCHEMA = 'process'

SELECT @nbSP = COUNT(1) FROM @temptable0



WHILE @CountSP <= @nbSP 
BEGIN        
    
        SELECT @NameSP = SPName FROM @temptable0 WHERE rowid = @CountSP;


		--sera inserer ici les règles définies dans nos sp
        CREATE TABLE tempdb.dbo.temptable1  (
             text varchar(MAX) 
        );

	--les infos seront traitée de la tempdb.dbo.temptable1  et renvoyées dans cette table
          CREATE TABLE tempdb.dbo.temptable2  (
             rowid int IDENTITY(1,1),
             text varchar(255) 
        );

		
		--sp_helptext procédure système qui affiche la définition d'une règle définie par l'utilisateur
        SET @StrSQL = 'INSERT INTO tempdb.dbo.temptable1 EXEC (''sp_helptext ''''' + @NameSP + ''''''')';
        EXEC sp_executesql @StrSQL;

--fait un parsing pour inserer dans la table  tempdb.dbo.temptable2 les données necesaires
        INSERT INTO tempdb.dbo.temptable2
        SELECT
        CASE 
		  when text like '%### processId%' then replace(replace(REPLACE(text,'-- ### processId: ', ''), char(9), '') , char(10), '')
			when text like '%### processGroupId%' then replace(replace(REPLACE(text,'-- ### processGroupId: ', '') , char(9), '') , char(10), '')
			when text like '%### processTypeId%' then replace(REPLACE(replace(text,'-- ### processTypeId: ', ''),  char(9), '') , char(10), '')
			when text like '%### processName%' then replace(replace(REPLACE(text,'-- ### processName: ', '') , char(9), '') , char(10), '')
			when text like '%### processDescription%' then replace(replace(REPLACE(text,'-- ### processDescription: ', '') , char(9), '') , char(10), '')
			when text like '%### processType%' then replace(replace(REPLACE(text,'-- ### processType: ', '') , char(9), '') , char(10), '')
			when text like '%### defaultWait%' then replace(REPLACE(replace(text,'-- ### defaultWait: ', '') , char(9), '') , char(10), '')
			when text like '%### monitoringLength%' then replace(replace(REPLACE(text,'-- ### monitoringLength: ', '') , char(9), '') , char(10), '')
			when text like '%### lastDuration%' then replace(replace(REPLACE(text,'-- ### lastDuration: ', '') , char(9), '') , char(10), '')
			when text like '%### jobLevel%' then replace(replace(REPLACE(text,'-- ### jobLevel: ', '') , char(9), '') , char(10), '')
			when text like '%### retention%' then replace(replace(REPLACE(text,'-- ### retention: ', '') , char(9), '') , char(10), '')
			when text like '%### processRetention%' then replace(replace(REPLACE(text,'-- ### processRetention: ', '') , char(9), '') , char(10), '')
			when text like '%### Auteur%' then replace(replace(REPLACE(text,'-- ### Auteur: ', '') , char(9), '') , char(10), '')
			when text like '%### createDate%' then replace(replace(REPLACE(text,'-- ### createDate: ', ''), char(9), '') , char(10), '')
            
            ELSE ''
            END AS DESCRIPTION  
        FROM tempdb.dbo.temptable1
        WHERE text LIKE '%###%';

		
      
	-- Table qui recevra les informations finales

       INSERT INTO [enum].[process] (
  processId
	,processGroupsId 
	,processTypeId 
	,processName 
	,procedureName 
	,processDescription 
	,proccessType 
	,defaultWait 
	,monitoringLength 
	,lastDuration
	,jobLevel 
	,retention 
	,processRetention 
	,auteur 
	,createDate 
	) 
	--tous ces replace sont aux fins d'elimination des des retours de lignes ou des espaces 
         SELECT
		      (select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 2) AS processId
         ,(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 3) AS processGroupsId
         ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 4) AS processTypeId
         ,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 5) AS processName
		     ,@NameSP
         ,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 6)  AS processDesscription
         ,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 7) AS processType
		     ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 8) AS defaultWait
         ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 9) AS monitoringLength
         ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 10) AS lastDuration
         ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 11)  AS jobLevel
         ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as datetime2) from tempdb.dbo.temptable2 WHERE rowid = 12) AS retention
		     ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as datetime2) FROM tempdb.dbo.temptable2 WHERE rowid = 13) AS processRetention
         ,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 14)  AS Auteur
          ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as datetime2) FROM tempdb.dbo.temptable2 WHERE rowid = 15) AS createDate

        DROP TABLE tempdb.dbo.temptable1;
        DROP TABLE tempdb.dbo.temptable2;


		SET @CountSP += 1;
	END;

	--SELECT * FROM @enumprocess;
	DELETE
	FROM @temptable0
END
GO
/****** Object:  StoredProcedure [dbo].[proc_ToCallAgregationName]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_ToCallAgregationName]
AS
BEGIN
	--cette procedure execute toutes les procedures se trouvant dans la table de processus d'agregation
	--**************************************************************
	-- declation de variables necessaires à la réalisation de la proc
	--***************************************************************
	DECLARE @processAgregationId INT
		,@processAgregationLogId INT
		,@processAgregationName VARCHAR(200)
		,@frequency VARCHAR(50) --moment de lancement de la proc (par jour ou par heure)
		,@StrSql NVARCHAR(1000)
		,@currentDate DATETIME2(0) = FORMAT(DATEADD(SECOND, - 2, GETDATE()), 'yyyy-M-d hh:m')  --date a laquelle l'agregation sera faite
		,@lastDate DATETIME2(0)    --   date de l'anciènne agregation
		,@maxcreateDate DATETIME2(0)    --date max de l'agrégation actuelle
		,@lastExecuteLogOfAgregate DATETIME2(0)
		,@agregationLogName VARCHAR(200)
		,@date1 DATETIME2(0)
		,@date2 DATETIME2(0)

	--*************************************************************************
	-- rubrique de calcul et de convertion de date  
	--************************************************************************
	--SELECT   SQL_VARIANT_PROPERTY(@date1,'BaseType') AS 'Base Type'
	SET @lastDate = (
			SELECT lastDate
			FROM [enum].lastAgregateDate
			)
	--recupère la date max lors de la dernière agregation
	--sera inserer dans une une table lastAgregateDate pour comparaison avec la prochaine 
	--agregation
	SET @maxcreateDate = (
			SELECT max(createDate)
			FROM [dbo].metrics
			WHERE createDate < @currentDate
			)

	--***************************************************************************
	--table temporaire qui recoit les différentes procedures d'agreggation
	--**************************************************************************
	DECLARE @T_Work TABLE (
		processAgregationId INT
		,processAgregationName VARCHAR(150)
		,frequency VARCHAR(50)
		)

	INSERT @T_Work
	--*************************************************************************
	-- selection des procedures dont l'aggréggation est faite par jour 
	--************************************************************************
	SELECT [enum].[processAgregation].processAgregationId
		,processAgregationName
		,frequency
	FROM enum.processAgregation

	--WHERE frequency = 'day'  
	--select * from   [enum].[processAgreggation]  --where frequency = 'day'
	SELECT TOP 1 @processAgregationId = processAgregationId
		,@processAgregationName = processAgregationName
		,@frequency = frequency
	FROM @T_Work
	ORDER BY processAgregationId


	--*************************************************************************
	-- boucle sur l'identifiant de la la table pour executer toute les procedures 
	--qui ont été sélectionnées  en passant le parametre adéquate
	--************************************************************************	

	WHILE @processAgregationId IS NOT NULL
	BEGIN
		BEGIN TRY
			--ces variable sont à des fins de la table log d'agregation
			SET @processAgregationLogId = @processAgregationId
			SET @agregationLogName = @processAgregationName
			SET @lastExecuteLogOfAgregate = @currentDate

			SELECT @StrSql = @processAgregationName + N' @lastDate , @currentDate';

			EXEC sp_executesql @strSql
				,N'@lastDate datetime2(0), @currentDate datetime2(0)'
				,@lastDate
				,@currentDate

			-- log si le processus d'agregation a fonctionné
			INSERT INTO enum.agregationLogByDay (
				processAgregationId
				,agregationLogLogName
				,lastExecuteLogOfAgregate
				,isProcessError
				,ErrorMessage
				)
			VALUES (
				@processAgregationId
				,@agregationLogName
				,@lastExecuteLogOfAgregate
				,0
				,ERROR_MESSAGE()
				)
		END TRY

		BEGIN CATCH
			SET @processAgregationLogId = @processAgregationId
			SET @agregationLogName = @processAgregationName
			SET @lastExecuteLogOfAgregate = @currentDate

			-- log si le processus d'agregation n'a pas fonctionné
			INSERT INTO enum.agregationLogByDay (
				processAgregationId
				,agregationLogLogName
				,lastExecuteLogOfAgregate
				,isProcessError
				,ErrorMessage
				)
			VALUES (
				@processAgregationId
				,@agregationLogName
				,@lastExecuteLogOfAgregate
				,1
				,ERROR_MESSAGE()
				)
		END CATCH
--supression de la ligne déja traitée
		DELETE
		FROM @T_Work
		WHERE processAgregationId = @processAgregationId
--selection d'une nouvelle ligne de données à traiter
		SELECT TOP 1 @processAgregationId = processAgregationId
			,@processAgregationName = processAgregationName
			,@frequency = frequency
		FROM @T_Work
		ORDER BY processAgregationId

		IF @@ROWCOUNT <= 0
			SET @processAgregationId = NULL
	END;

	--*************************************************************************
	-- mise à jour de la table de date de dernière agréggation 
	--qui ici est la dernière date introduite dans la table des metrics  en ce moment d'agregation
	-- en outre la valeur max de la table des metrics en ce moment d'agregation
	--************************************************************************	
	UPDATE [enum].lastAgregateDate
	SET lastDate = @maxcreateDate
END;
GO
/****** Object:  StoredProcedure [dbo].[proc_ToCallprocedureName]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_ToCallprocedureName]

	--cette procedure execute toutes les procedures de collecte de données se trouvant dans la table process
AS
BEGIN
	--declaration de variables de travails
	DECLARE @startTime DATETIME2(0)
		,@endTime DATETIME2(0)
		,@processId INT
		,@parameter VARCHAR(100)
		,@procedureName VARCHAR(100)  --non de la procedure
		,@stringsql VARCHAR(100)
		,@wait INT -- dorrée d'execution de la procedure
		,@monitoringLength INT
		,@createDate DATETIME2  --date de creation
		,@lastDuration INT
		,@jobLevel INT
		,@date1 DATETIME2
		,@date2 DATETIME2
		,@strSql NVARCHAR(max)
		,@processLogId INT
		,@param VARCHAR(100)
		,@JprocessLogName VARCHAR(128)
		,@lastExecuteLog DATETIME2

	--table temporaire de reception de toutes les procedures qui seront executé au momment du wait
	DECLARE @T_Work TABLE (
		processId INT
		,procedureName VARCHAR(150)
		,parameter VARCHAR(200)
		,wait INT
		,monitoringLength INT
		,createDate DATETIME2(0)
		,lastDuration INT
		,jobLevel INT
		)

	INSERT @T_Work (
		processId
		,procedureName
		,parameter
		,wait
		,monitoringLength
		,createDate
		,lastDuration
		,jobLevel
		)
	-- recherche des données dans la table de process
	SELECT [enum].[process].processId
		,procedureName
		,parameter
		,wait
		,monitoringLength
		,createDate
		,lastDuration
		,jobLevel
	FROM [enum].[process]
	INNER JOIN [enum].[planification] ON [enum].[process].processId = [enum].[planification].planificationId
	WHERE dateadd(SECOND, wait, createDate) <= getdate()

	SELECT TOP 1 @processId = processId
		,@procedureName = procedureName
		,@parameter = parameter
		,@wait = wait
		,@monitoringLength = monitoringLength
		,@createDate = createDate
		,@lastDuration = lastDuration
		,@jobLevel = jobLevel
	FROM @T_Work
	ORDER BY processId


	--boucle sur chaque id de la la table temporaire  pour executer les procedures 
	WHILE @processId IS NOT NULL
	BEGIN
		BEGIN TRY
			SET @processLogId = @processId
			SET @JprocessLogName = @procedureName
			SET @lastExecuteLog = @createDate
			--debut d'execution du process
			SET @startTime = GETDATE();

			--select @Processtocall, @param
			SELECT @StrSql = @procedureName + ' @parameter= ''' + @parameter + '''';

			--select   @StrSql
			--print  @StrSql
			EXEC sp_executesql @strSql

			--date de fin d'execution du process
			SET @endTime = GETDATE();

			--différence entre la date de début et de fin d'execution du processus à des fin de classification des job
			SELECT @LastDuration = DATEDIFF(ss, @startTime, @endTime);
--condition pour les niveua de job 
			IF (@LastDuration < 1)
				SET @jobLevel = 1
			ELSE IF (
					@LastDuration >= 1
					AND @LastDuration < 6
					)
				SET @jobLevel = 2
			ELSE
				SET @jobLevel = 3

			--en cas de reussite du process
			INSERT INTO [enum].processLog (
				processId
				,processLogName
				,lastExecuteLog
				,isProcessError
				,ErrorMessage
				)
			VALUES (
				@processLogId
				,@JprocessLogName
				,@lastExecuteLog
				,0
				,ERROR_MESSAGE()
				)

			--mise à jour de la colone createdate de la table de procces une fois le processus executé
			UPDATE [enum].process
			SET createDate = getdate()
				,LastDuration = @LastDuration
				,jobLevel = @jobLevel
			WHERE processId = @processId
		END TRY

		BEGIN CATCH
			SET @processLogId = @processId
			SET @JprocessLogName = @procedureName
			SET @lastExecuteLog = @createDate

			--en cas d'echec d'execution du process
			INSERT INTO [enum].processLog (
				processId
				,processLogName
				,lastExecuteLog
				,isProcessError
				,ErrorMessage
				)
			VALUES (
				@processLogId
				,@JprocessLogName
				,@lastExecuteLog
				,1
				,ERROR_MESSAGE()
				)
		END CATCH
--supression de la ligne deja traitée
		DELETE
		FROM @T_Work
		WHERE processId = @processId
--selection d'une nouvelle ligne
		SELECT TOP 1 @processId = processId
			,@procedureName = procedureName
			,@parameter = parameter
			,@wait = wait
			,@monitoringLength = monitoringLength
			,@createDate = createDate
			,@lastDuration = lastDuration
			,@jobLevel = jobLevel
		FROM @T_Work
		ORDER BY processId

		IF @@ROWCOUNT <= 0
			SET @processId = NULL
	END;
END;
GO
/****** Object:  StoredProcedure [process].[proc_dbfileGrowthSize]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_dbfileGrowthSize] 

@parameter VARCHAR(100)
	--cette procedure calcule en Mo la taille d'acroissement des fichers db pour un disk données
	--le parametre ici indique le drive en question
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************

	-- ### processId: 7
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille d'acroissement des fichiers de la db
	-- ### processDescription:  retourne  la taille totale d'acroissement des fichiers db pour un disque
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@recepOutputParcint VARCHAR(100)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'total_dbfileGrowthSize'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des drives
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recherche du disk et du processId corespondant
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_dbfileGrowthSize'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp



	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle sur chaque id de la table et son hard drive
	WHILE @id IS NOT NULL
	BEGIN
		--pour obtenir la taille totale d'acroissement des db pour ce drive la 
		SELECT @value1 = CAST(SUM(FileGrowthMo) AS DECIMAL(18, 2))
		FROM (
			SELECT CASE 
					WHEN f.is_percent_growth = 1
						THEN (CAST(f.size AS FLOAT) * f.growth / 100) * 8 / 1024
					ELSE CAST(f.growth AS FLOAT) * 8 / 1024
					END AS FileGrowthMo
			FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
			WHERE volume_mount_point LIKE '' + @diskName + ':\'
			) AS FileSizes

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection de la nouvelle ligne
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_free_percent_File_LOG_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_free_percent_File_LOG_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule en % la taille de fichiers log de chaque database
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************

	-- ### processId: 18
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille libre des fichiers log de la db en %
	-- ### processDescription:  retourne en pourcentage la taille libre pour chaque fichier log de la  db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@recepOutputParcint VARCHAR(100)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--recherche  du processId corespondant
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_Get_free_percent_File_LOG_Size_per_db'
			)
	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'free_percent_File_LOG_Size_per_db'

	----		--------------------------------------
	--table temporaire pour recevoir les différentes db 
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--appel de la procedure qui liste les différents db
	EXEC [dbo].[proc_GetDbName]

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	--select * from @recepDataparcint
	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucles sur les différentes db pour calculer leur %
	WHILE @id IS NOT NULL
	BEGIN
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[percent_free] = (size-fileproperty(name,''SpaceUsed''))/128.000)/size * 100
	FROM sys.database_files 
	WHERE type_desc LIKE ''LOG''';

		--print @strSql
		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--select d'un nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_free_percent_File_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_free_percent_File_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule en % la taille de fichiers data disponible de chaque database
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 13
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille libre de la db en %
	-- ### processDescription:  retourne en pourcentage l'espace libre pour chaque db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--recherche  du processId corespondant
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_Get_free_percent_File_Size_per_db'
			)
	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'free_percent_File_Size_per_db'

	----		--------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @temp
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--cette proc renvoie la liste des db 
	EXEC [dbo].[proc_GetDbName]

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @temp

	--select * from @temp
	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle suer chaque db pour calculer son % disponible de fichier data
	WHILE @id IS NOT NULL
	BEGIN
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[percent_free] = (size-fileproperty(name,''SpaceUsed''))/128.000)/size * 100
	FROM sys.database_files 
	WHERE type_desc LIKE ''ROWS''';

		--print @strSql
		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE dbName = @dbName
--select d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_table_freeSpace_without_compresses]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_table_freeSpace_without_compresses] 

@parameter VARCHAR(100) = NULL

	--cette procedure calcule pour chaque base données la taille disponible de chaque table non compressé 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 30
	-- ### processGroupId: 7
	-- ### processTypeId: 1
	-- ### processName: taille libre d'une table nom compréssée 
	-- ### processDescription:  retourne la taille libre d'une table non compréssée d'une base de données avec le nombre de record
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-30 09:35:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)
		,@numberOfRecord INT

	-----		-------------------------------------------
	--------------------------------------------------------
	--recherche  du processId corespondant
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_Get_table_freeSpace_without_compresses'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'freeSpace_table_without_compresses'

	----		--------------------------------------
	--table qui recoit la db et table non compressées
	DECLARE @recepttable_without_compresses TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		,numberOfRecord INT
		)

	INSERT @recepttable_without_compresses (
		dbName
		,tableName
		,numberOfRecord
		)
	--cette procedure retourne les tables et base données non comprésées
	EXEC dbo.get_table_without_compresses

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
		,@numberOfRecord = numberOfRecord
	FROM @recepttable_without_compresses

	--select * from @recepttable_without_compresses
	--boucle sur chaque ligne de la table temporaire
	WHILE @id IS NOT NULL
	BEGIN
		--calcule de la taille disponible dans chaque table de la db avec le nombre record
		SELECT @strsql = N'select @value1= (select CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS decimal(18, 2)) AS freeSpaceMB
FROM 
    ' + @dbname + '.sys.tables t
INNER JOIN      
    ' + @dbname + '.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    ' + @dbname + '.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    ' + @dbname + '.sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    ' + @dbname + '.sys.schemas s ON t.schema_id = s.schema_id
	where  t.name = ''' + right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + ''') '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1
--insertion de données 

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value2
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@numberOfRecord
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepttable_without_compresses
		WHERE id = @id
--selection d'une nouvelle ligne à traitée
		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
			,@numberOfRecord = numberOfRecord
		FROM @recepttable_without_compresses

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_table_Space_without_PrimaryKey]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_table_Space_without_PrimaryKey] 

@parameter VARCHAR(100) = NULL

	--cette procedure calcule la taille d'une table dans une base données sans clé primaire
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 32
	-- ### processGroupId: 7
	-- ### processTypeId: 1
	-- ### processName: taille total d'une table sans pk 
	-- ### processDescription:  retourne la taille totale d'une table sans PK d'une base de données 
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-30 09:35:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)

	-----		-------------------------------------------
	--------------------------------------------------------
	--recherche  du processId corespondant
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_Get_table_Space_without_PrimaryKey'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'Space_table_without_PrimaryKey'

	----		--------------------------------------
	--table temporaire qui recevra les db et tables sans PK
	DECLARE @recepttable_without_PrimaryKey TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		)

	--cette procedure retourne les db et table sans PK
	INSERT @recepttable_without_PrimaryKey
	EXEC dbo.get_table_without_PrimaryKey

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
	FROM @recepttable_without_PrimaryKey


--boucle sur l'id de la table temporaire
	WHILE @id IS NOT NULL
	BEGIN
		-- en fonction de la db et de la table calcule de la taille de chaque table pour chaque db
		SELECT @strsql = N'select @value1= (SELECT CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS decimal(18, 2)) AS TotalSpaceMB
FROM 
    ' + @dbname + '.sys.tables t
INNER JOIN      
    ' + @dbname + '.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    ' + @dbname + '.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    ' + @dbname + '.sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    ' + @dbname + '.sys.schemas s ON t.schema_id = s.schema_id
	where  t.name = ''' +right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + ''') '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1
--insertion des données
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--suprime la ligne déja traitée
		DELETE TOP (1)
		FROM @recepttable_without_PrimaryKey
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
		FROM @recepttable_without_PrimaryKey

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	
GO
/****** Object:  StoredProcedure [process].[proc_Get_table_TotalSpace_without_compresses]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_table_TotalSpace_without_compresses] 

@parameter VARCHAR(100)
	--cette procedure calcule pour chaque base données la taille totale de chaque table non compressé 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 29
	-- ### processGroupId: 7
	-- ### processTypeId: 1
	-- ### processName: taille total d'une table non compréssée 
	-- ### processDescription:  retourne la taille totale d'une table non compressée d'une base de données avec le nombre de record
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-30 09:35:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)
		,@numberOfRecord INT

	-----		-------------------------------------------
	--------------------------------------------------------
	--recherche du disk et du processId corespondant
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_Get_table_TotalSpace_without_compresses'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'zise_table_without_compresses'

	----		--------------------------------------
	--pour la reception des db et table non compressée
	DECLARE @recepttable_without_compresses TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		,numberOfRecord INT
		)

	INSERT @recepttable_without_compresses (
		dbName
		,tableName
		,numberOfRecord
		)
	--cette proc retourne les db et table non compressée
	EXEC dbo.get_table_without_compresses

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
		,@numberOfRecord = numberOfRecord
	FROM @recepttable_without_compresses

	
	--boucle sur chaque id de la table temporaire
	WHILE @id IS NOT NULL
	BEGIN
		--calcul de la taille totale de la  table 
		SELECT @strsql = N'select @value1= (SELECT CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS decimal(18, 2)) AS TotalSpaceMB
FROM 
    ' + @dbname + '.sys.tables t
INNER JOIN      
    ' + @dbname + '.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    ' + @dbname + '.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    ' + @dbname + '.sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    ' + @dbname + '.sys.schemas s ON t.schema_id = s.schema_id
	where  t.name = ''' + right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + ''') '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value2
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@numberOfRecord
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--suprime la ligne déja traitée
		DELETE TOP (1)
		FROM @recepttable_without_compresses
		WHERE id = @id
--selectionne une nouvelle ligne
		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
			,@numberOfRecord = numberOfRecord
		FROM @recepttable_without_compresses

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_table_UsedSpace_without_compresses]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_table_UsedSpace_without_compresses] 

@parameter VARCHAR(100) = NULL

	--cette procedure calcule pour chaque base données la taille utilisée de chaque table non compressé 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 31
	-- ### processGroupId: 7
	-- ### processTypeId: 1
	-- ### processName: taille utilisé d'une table nom compréssée 
	-- ### processDescription:  retourne la taille utilisé d'une table non compréssée d'une base de données avec le nombre de record
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-30 09:35:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)
		,@numberOfRecord INT

	-----		-------------------------------------------
	--------------------------------------------------------
	--recherche du disk et du processId corespondant
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_Get_table_UsedSpace_without_compresses'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'UsedSpace_table_without_compresses'

	----		--------------------------------------
	--table qui recevra les bases et table non compréssées
	DECLARE @recepttable_without_compresses TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		,numberOfRecord INT
		)

	INSERT @recepttable_without_compresses (
		dbName
		,tableName
		,numberOfRecord
		)
	--retourne toute les bases et tables non compréssées
	EXEC dbo.get_table_without_compresses

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
		,@numberOfRecord = numberOfRecord
	FROM @recepttable_without_compresses

	SELECT *
	FROM @recepttable_without_compresses
--boucle sur chaque Id de la table temporaire pour avoir la db et la table 
	WHILE @id IS NOT NULL
	BEGIN
		--calcul de l'espace utilié de chaque table 
		SELECT @strsql = N'select @value1= (select CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS decimal(18, 2)) AS UsedSpaceMB
FROM 
    ' + @dbname + '.sys.tables t
INNER JOIN      
    ' + @dbname + '.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    ' + @dbname + '.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    ' + @dbname + '.sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    ' + @dbname + '.sys.schemas s ON t.schema_id = s.schema_id
	where  t.name = ''' + right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + ''') '  --suprime le shema si non ne fonctionne pas 

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value2
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@numberOfRecord
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepttable_without_compresses
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
			,@numberOfRecord = numberOfRecord
		FROM @recepttable_without_compresses

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Get_table_with_partition_without_incremental_option]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_table_with_partition_without_incremental_option] 

@parameter VARCHAR(100) = NULL

	--cette procedure calcule retourne pour chaque bd les table partitioné sans statistique incrementale 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 33
	-- ### processGroupId: 8
	-- ### processTypeId: 1
	-- ### processName: table partitionner sans option  statistique incremental
	-- ### processDescription:  retourne les bases de données avec les tables partitionner sans option statistique incremental
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-05-02 11:05:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)

	-----		-------------------------------------------
	--------------------------------------------------------
	--recherche du processId corespondant
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_Get_table_with_partition_without_incremental_option'
			)
	SET @unit = 'nombe'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'db et table  partitionner sans option incremental'

	--table temporaire de rection des db et tables partitionnées 
	----		--------------------------------------
	DECLARE @receptPartitions TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		)

	INSERT @receptPartitions (
		dbName
		,tableName
		)
	--retourne la db avec les tables partitionées 
	EXEC dbo.getTable_with_partition

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
	FROM @receptPartitions

	--boucle pour deterniner si la taible partitionée à l'option statistique incrémentale 
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @strsql = N'select @value1= (SELECT   s.is_incremental
				FROM  ' + @dbname + '.sys.tables t
				inner join  ' + @dbname + '.sys.stats s on s.object_id = t.object_id
				WHERE t.name LIKE ''' + @tableName + '''
					and is_incremental = 0
                    group by t.name, s.is_incremental
					) '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)

		DELETE TOP (1)
		FROM @receptPartitions
		WHERE id = @id

		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
		FROM @receptPartitions

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	
GO
/****** Object:  StoredProcedure [process].[proc_Get_Used_Size_Disk]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Get_Used_Size_Disk] 

@parameter VARCHAR(100)
	--cette procedure calcule retourne pour chaque hard drive la taille utilisé 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci-dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 2
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille disk utilise
	-- ### processDescription:  retourne la taille disk utilise
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(12, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'Used_Size_Disk'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	--table de reception du hard drive name
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recherche diskName et processId corespondand
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_Get_Used_Size_Disk'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp


	------------------------------------------------------------------------
	--------------------------------------------------------------------------
--	boucle sur chaque id de la table pour calculer en fonction du diskName la taille utilisée
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = CAST(min(total_bytes) / 1024 / 1024 - min(available_bytes) / 1024 / 1024 AS DECIMAL(18, 2))
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
		WHERE volume_mount_point LIKE '' + @diskName + ':\';

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne dejé traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	
GO
/****** Object:  StoredProcedure [process].[proc_Get_Used_Size_Disk_OS]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [process].[proc_Get_Used_Size_Disk_OS] 

@parameter VARCHAR(100) = null

--cette proc calcule la taille utilisée de tous les disques dur ce trouvant dans un Os
--le parametre est à titre indicatif car la proc generale execute plusieur autres proc qui prenne un prametre

--********************************************************************************
--les données ci-dessous commencant par    -- ###   seront       inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collecte de données  et
-- selon cette syntaxe 

--**************************************************************************************
-- ### processId: 37
-- ### processGroupId: 11
-- ### processTypeId: 1
-- ### processName: taille utilisé du disque fixe du server OS
-- ### processDescription:  retourne la taille disk fixe de l'os
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00


AS
BEGIN
----------------------------------------------------------------------
--déclaration des variable
	-------------------------------------------------------------------
DECLARE @id INT
		,@processId INT
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
    ,@STRLine VARCHAR(8000) 
		, @Drive varchar(500) 
		, @Freesize real
		 ,@TotalSize real
		 ,@usedSize real 
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------


		SET @unit = 'Mo'
		SET @servername = (SELECT @@SERVERNAME AS instanceName);
		SET @createdate = GETDATE()
		set @value4 = 'Get_Used_Size_Disk_OS'


----------------------------------------------------------------------
--table temporaire pour recevoir les noms des disk et sa taille totale
	-------------------------------------------------------------------
	
CREATE TABLE #DrvLetter (
    Drive VARCHAR(500),
    )

	INSERT INTO #DrvLetter
EXEC xp_cmdshell 'wmic volume where drivetype="3" get caption, freespace, capacity'  -- script power shell pour recuperation des infos système

DELETE   -- supression des infos non necessaire comme les disk reservés sys
FROM #DrvLetter
WHERE drive IS NULL OR len(drive) < 4 OR Drive LIKE '%Capacity%'
	OR Drive LIKE  '%\\%\Volume%'

	
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recuprération de l'id corespondant à ce process dans la table de planification
	set @processId =( SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_Get_Used_Size_Disk_OS')

	--boucle sur la table pour traitement des données et insertion dans metric
	WHILE EXISTS(SELECT 1 FROM #DrvLetter)
	BEGIN

	SET ROWCOUNT 1

SELECT @STRLine = drive FROM #DrvLetter

-- Get TotalSize
SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine)) AS real)/1024/1024
--SELECT @TotalSize

-- Remove Total Size
SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX(' ',@STRLine)),'')
-- Get Drive

SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)))
--SELECT @Drive

SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))),'')))

SET @Freesize = cast(LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))) as real)/1024/1024
--SELECT @Freesize/1024/1024

set @usedSize =  @TotalSize - @Freesize
	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@usedSize
			,@Drive
			,@value4
			,@unit
			,@servername
			,@createdate
			)

		DELETE FROM #DrvLetter
END

SET ROWCOUNT 0

drop table #DrvLetter
END;
GO
/****** Object:  StoredProcedure [process].[proc_GetavailableMemory]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetavailableMemory] 

@parameter VARCHAR(100)

	--cette procedure calcule la memoire disponible du système
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 21
	-- ### processGroupId: 3
	-- ### processTypeId: 1
	-- ### processName: taille disponible de la mémoire
	-- ### processDescription:  retourne la taille disponible de la mémoire
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		-- ,@parameter VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--avalaible memory 
	SELECT @value1 = cast(sum(available_physical_memory_kb / 1024.0) AS DECIMAL(18, 2))
	FROM sys.dm_os_sys_memory
	CROSS APPLY sys.dm_os_process_memory;

	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'availableMemory'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des memoires
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,parameter VARCHAR(100)
		)

	INSERT @temp (
		processId
		,parameter
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetavailableMemory'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@parameter = parameter
	FROM @temp

	------------------------------------------------------------------------
	--boucle pour insertion desdonnées 
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supresion de la ligne déja traitée 
		DELETE TOP (1)
		FROM @temp
		WHERE parameter = @parameter
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@parameter = parameter
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetDbFileSize]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetDbFileSize] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille des fichiers de la base de données  pour un disck données 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 6
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille des fichiers db sur le disk 
	-- ### processDescription:  retourne  la taille totale  des fichiers db pour un disque
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
	

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'Get_Db_File_Size'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetDbFileSize'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp


	--boucle sur les différente ligne de la table temporaire pour calculer la taille 
	--des fichiers de db se trouvant dans ce drive donnée
	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = CAST(sum(f.size) * 8 / 1024 AS DECIMAL(12, 2))
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
		WHERE volume_mount_point LIKE '' + @diskName + ':\'

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée de la table temporaire
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName

-- selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetEmpty_File_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetEmpty_File_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule libre des fichiers data de chaqe base données  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 11
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: espace libre de la db
	-- ### processDescription:  retourne  l'espace libre pour chaque base données du serveur
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetEmpty_File_Size_per_db'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'Empty_File_Size_per_db'

	----		--------------------------------------
	--reception des différentes db du système
	DECLARE @recepdbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepdbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--retourne les db 
	EXEC [dbo].[proc_GetDbName]

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepdbName


	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle pour calculer l'espace libre de chaque fichier data de la db
	WHILE @id IS NOT NULL
	BEGIN
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[FREE_SPACE_MB] = size-fileproperty(name,''SpaceUsed''))/128.000
	FROM sys.database_files 
	WHERE type_desc LIKE ''ROWS''';

		--print @strSql
		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne deja traitée
		DELETE TOP (1)
		FROM @recepdbName
		WHERE dbName = @dbName
-- selectio  d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepdbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetEmpty_Log_File_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetEmpty_Log_File_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille libre des fichiers log pour chaqe base données  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 16
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille libre des fichiers log de la db
	-- ### processDescription:  retourne  la taille libre pour chaque fichier log de la  db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetEmpty_Log_File_Size_per_db'
			)
	SET @value4 = 'Empty_Log_File_Size_per_db'

	----recoit les db
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	
	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--retourne les db
	EXEC [dbo].[proc_GetDbName]


	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle sur chaque db et calcule la taille disponible 
	WHILE @id IS NOT NULL
	BEGIN
		--boucle pour calculer l'espace libre des fichiers data pour chaque db
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[FREE_SPACE_MB] = size-fileproperty(name,''SpaceUsed''))/128.000
	FROM sys.database_files 
	WHERE type_desc LIKE ''LOG''';

		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--suprime la ligne déja traitée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetFile_growth_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFile_growth_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille d'acroissement  des fichiers data pour chaqe base données  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 14
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille d'acroissement de la db
	-- ### processDescription:  retourne la taille d'acroissement pour chaque db serveur
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetFile_growth_Size_per_db'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'File_growth_Size_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]

	--SELECT *
	--FROM @recepDataparcint
	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--boucle pour calculer la taille d'acroissement des fichiers data de chaque bd
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = [f].[growth] * 8 / 1024
		FROM [master].[sys].[master_files] [f]
		INNER JOIN sys.databases AS s ON f.database_id = s.database_id
		WHERE type_desc LIKE 'ROWS'
			AND s.Name LIKE '' + @dbName + ''

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--suprime la ligne déja traitée 
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetFile_Size_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFile_Size_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille  physique des fichiers data pour chaqe base données  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 10
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille physique de la db
	-- ### processDescription:  retourne la taille physique pour chaque db du serveur
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetFile_Size_per_db'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'File_Size_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--boucle pour calculer la taille de chaque db  en ce qui concerne le ficheir data
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = sum([f].[size] * 8 / 1024)
		FROM [master].[sys].[master_files] [f]
		INNER JOIN sys.databases AS s ON f.database_id = s.database_id
		WHERE type_desc LIKE 'ROWS'
			AND s.Name LIKE '' + @dbName + ''

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traité
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	
GO
/****** Object:  StoredProcedure [process].[proc_GetFile_Size_Used_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFile_Size_Used_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille utilisée   des fichiers data pour chaqe base données  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	--**************************************************************************************
	-- ### processId: 12
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: espace utilisé de la db
	-- ### processDescription:  retourne la taille utilisé pour chaque db du serveur
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetFile_Size_Used_per_db'
			)
	SET @value4 = 'File_Size_Used_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDb TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDb
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]


	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDb

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		--boucle pour calculer la taille utilisée de chaque db pour les ficheirs data	
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[SPACE_USED_MB] = fileproperty(name,''SpaceUsed'')/128.000
	FROM sys.database_files 
	WHERE type_desc LIKE ''ROWS'')';

		--print @strSql
		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepDb
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDb

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetFreeSizeDiskPerCent]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFreeSizeDiskPerCent] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille en % pour chaque hard drive     
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 4
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille libre du disk en %
	-- ### processDescription:  retourne  la taille libre d'un disk en pourcentage
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'GetFreeSizeDiskPerCent'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetFreeSizeDiskPerCent'

	
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	SELECT *
	FROM @temp

	------------------------------------------------------------------------
	--boucle pour calculer la taille disk disponible 
	--il s'agit ici d'un disk utilisé par sql server
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = ((cast(min(available_bytes) AS DECIMAL(18, 2)) / cast(min(total_bytes) AS DECIMAL(18, 2))) * 100)
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
		WHERE volume_mount_point LIKE '' + @diskName + ':\';

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetFreeSizeDiskPerCent_OS]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFreeSizeDiskPerCent_OS] 

@parameter VARCHAR(100)= null

--cette proc calcule la taille utilisée de tous les disques dur ce trouvant dans un Os
--le parametre est à titre indicatif car la proc generale execute plusieur autres proc qui prenne un prametre

--********************************************************************************
--les données ci-dessous commencant par    -- ###   seront       inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collecte de données  et
-- selon cette syntaxe 

--**************************************************************************************
-- ### processId: 38
-- ### processGroupId: 11
-- ### processTypeId: 1
-- ### processName: taille disponible en pourcentage du disque fixe du server OS
-- ### processDescription:  retourne  la taille libre d'un disk en pourcentage
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

AS
BEGIN
----------------------------------------------------------------------
--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
    ,@STRLine VARCHAR(8000) 
		, @Drive varchar(500) 
		, @Freesize real
		 ,@TotalSize real
		 ,@per_cent_free_size real 
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------


		SET @unit = '%'
		SET @servername = (SELECT @@SERVERNAME AS instanceName);
		SET @createdate = GETDATE()
		set @value4 = 'GetFreeSizeDiskPerCent_OS'


	----------------------------------------------------------------------
--table temporaire pour recevoir les noms des disk et sa taille totale
	-------------------------------------------------------------------
	
CREATE TABLE #DrvLetter (
    Drive VARCHAR(500),
    )

	INSERT INTO #DrvLetter
EXEC xp_cmdshell 'wmic volume where drivetype="3" get caption, freespace, capacity'  -- script powershell pour recuperation des infos disk système

DELETE   -- supression des infos no necessaire comme les disk reservés sys
FROM #DrvLetter
WHERE drive IS NULL OR len(drive) < 4 OR Drive LIKE '%Capacity%'
	OR Drive LIKE  '%\\%\Volume%'

	--select * from #DrvLetter
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recuprération de l'id corespondant à ce process dans la table de planification
	set @processId =( SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_GetFreeSizeDiskPerCent_OS')

	
	--boucle sur la table pour traitement des données et insertion dans metrics
	WHILE EXISTS(SELECT 1 FROM #DrvLetter)
	BEGIN

	SET ROWCOUNT 1

SELECT @STRLine = drive FROM #DrvLetter

-- taille totale
SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine)) AS real)/1024/1024
--SELECT @TotalSize

-- suprime la taille totale
SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX(' ',@STRLine)),'')
-- nom du drive

SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)))
--SELECT @Drive

SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))),'')))

SET @Freesize = cast(LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))) as real)/1024/1024
--SELECT @Freesize/1024/1024

set @per_cent_free_size =  (@Freesize/@TotalSize) *100
	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@per_cent_free_size
			,@Drive
			,@value4
			,@unit
			,@servername
			,@createdate
			)

		DELETE FROM #DrvLetter
END

SET ROWCOUNT 0

drop table #DrvLetter
END;


GO
/****** Object:  StoredProcedure [process].[proc_GetFreeSpaceAfterGrowth]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetFreeSpaceAfterGrowth] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille libre d'un disk après retrait de la taille d'acroissement de la db    
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 8
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille disk libre apres growth
	-- ### processDescription:  retourne la taille libre du disk aprèes retrait des fichiers growth
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'GetFreeSpaceAfterGrowth'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetFreeSpaceAfterGrowth'

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	--	SELECT *
	--FROM @temp
	------------------------------------------------------------------------
	--boucle sur chaque nom de disk pour calculer le taille disk libre
	--apres retrait de la taile fichiers d'acroissement
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = CAST(MIN(VolumeAvailableMo) - SUM(FileGrowthMo) AS DECIMAL(18, 2))
		FROM (
			SELECT CASE 
					WHEN f.is_percent_growth = 1
						THEN (CAST(f.size AS FLOAT) * f.growth / 100) * 8 / 1024
					ELSE CAST(f.growth AS FLOAT) * 8 / 1024
					END AS FileGrowthMo
				,CAST(vs.available_bytes AS FLOAT) / 1024 / 1024 AS VolumeAvailableMo
			FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			WHERE volume_mount_point LIKE '' + @diskName + ':\'
			) AS fileSizes

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetHdFreeSize]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetHdFreeSize] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille  libre d' un disk donnée   
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 3
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille libre du disk 
	-- ### processDescription:  retourne la taille libre du disk 
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@recepOutputParcint VARCHAR(100)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'GetHdFreeSize'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetHdFreeSize'

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	SELECT *
	FROM @temp

	------------------------------------------------------------------------
	--boucle pour calculer la taille libre d'un disk donnée
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = cast(min(available_bytes) / 1024 / 1024 AS DECIMAL(18, 2))
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
		WHERE volume_mount_point LIKE '' + @diskName + ':\';

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée 
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetHdFreeSize_OS]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [process].[proc_GetHdFreeSize_OS] 

@parameter VARCHAR(100) = null

--cette proc calcule la taille disponible de tous les disques dur ce trouvant dans un Os
--le parametre est à titre indicatif car la proc generale execute plusieur autres proc qui prenne un prametre

--********************************************************************************
--les données ci-dessous commencant par    -- ###   seront       inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collecte de données  et
-- selon cette syntaxe 
--**************************************************************************************
-- ### processId: 36
-- ### processGroupId: 11
-- ### processTypeId: 1
-- ### processName: taille disponible du disque fixe du server OS
-- ### processDescription:  retourne la taille disponible d'un  disk  donné
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00


AS
BEGIN



----------------------------------------------------------------------
--déclaration des variable
	-------------------------------------------------------------------
--déclaration de variables 
DECLARE @id INT
		,@processId INT
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
    ,@STRLine VARCHAR(8000) 
		, @Drive varchar(500) 
		, @Freesize real
		 ,@TotalSize real
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------


		SET @unit = 'Mo'
		SET @servername = (SELECT @@SERVERNAME AS instanceName);
		SET @createdate = GETDATE()
		set @value4 = 'GetHdFreeSize_OS'


----------------------------------------------------------------------
--table temporaire pour recevoir les noms des disk et sa taille totale
	-------------------------------------------------------------------
	-- drop table #DrvLetter
CREATE TABLE #DrvLetter (
    Drive VARCHAR(500),
    )

	INSERT INTO #DrvLetter
EXEC xp_cmdshell 'wmic volume where drivetype="3" get caption, freespace, capacity'  -- script power shell pour recuperation des infos système

DELETE   -- supression des infos no necessaire comme les disk reservés sys
FROM #DrvLetter
WHERE drive IS NULL OR len(drive) < 4 OR Drive LIKE '%Capacity%'
	OR Drive LIKE  '%\\%\Volume%'

	--select * from #DrvLetter
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recuprération de l'id corespondant à ce process dans la table de planification
	set @processId =( SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_GetHdFreeSize_OS')
--*******************************************************************************************************************************
	--boucle sur la table pour traitement des données et insertion dans metric
	WHILE EXISTS(SELECT 1 FROM #DrvLetter)
	BEGIN

	SET ROWCOUNT 1

SELECT @STRLine = drive FROM #DrvLetter

-- taille totale
SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine)) AS real)/1024/1024
--SELECT @TotalSize

-- supression de la taille totale 
SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX(' ',@STRLine)),'')
-- obtention dudrive 

SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)))
--SELECT @Drive

SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))),'')))

SET @Freesize = cast(LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))) as real)/1024/1024
--SELECT @Freesize/1024/1024

	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------
	INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@Freesize
			,@Drive
			,@value4
			,@unit
			,@servername
			,@createdate
			)


	DELETE FROM #DrvLetter
END

SET ROWCOUNT 0

drop table #DrvLetter
END;


GO
/****** Object:  StoredProcedure [process].[proc_GetHdSizeOtherFiles]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetHdSizeOtherFiles] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille   des fichiers systèmes pour un disk donnée  
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 5
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: space disk other file
	-- ### processDescription:  retourne la taille disk utilisé par les autres fichiers systèmes
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'GetHdSizeOtherFiles'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetHdSizeOtherFiles'

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	--	SELECT *
	--FROM @temp
	------------------------------------------------------------------------
	--boucle pour calculer la taille des autres fichiers systèmes pour un disk données
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = CAST(MIN(VolumeTotalMo) - (SUM(FileSizeMo) + MIN(VolumeAvailableMo)) AS DECIMAL(18, 2))
		FROM (
			SELECT CAST(vs.total_bytes AS FLOAT) / 1024 / 1024 AS VolumeTotalMo
				,CAST(f.size AS FLOAT) * 8 / 1024 AS FileSizeMo
				,CAST(vs.available_bytes AS FLOAT) / 1024 / 1024 AS VolumeAvailableMo
			FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			WHERE volume_mount_point LIKE '' + @diskName + ':\'
			) AS OtherMo

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetLOGFile_GrowthSize_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetLOGFile_GrowthSize_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille d'acroissement des fichies log pour chaque db 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	--**************************************************************************************
	-- ### processId: 19
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille d'acroissement des fichiers lob de la db
	-- ### processDescription:  retourne  la taille d'acroissement pour chaque fichier log de la  db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetLOGFile_GrowthSize_per_db'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'LOGFile_GrowthSize_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--cette proc retourne la liste db
	EXEC [dbo].[proc_GetDbName]

	--SELECT *
	--FROM @recepDataparcint
	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--selon la db calcule la taille d'acroissement des fichiers log
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = [f].[growth] * 8 / 1024
		FROM [master].[sys].[master_files] [f]
		INNER JOIN sys.databases AS s ON f.database_id = s.database_id
		WHERE type_desc LIKE 'LOG'
			AND s.Name LIKE '' + @dbName + ''

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetLogFile_Size_Used_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetLogFile_Size_Used_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille utilisée par des fichies log pour chaque db 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 17
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille utilisé des fichiers log de la db
	-- ### processDescription:  retourne  la taille utilisée pour chaque fichier log de la  db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@strSql NVARCHAR(1000)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetLogFile_Size_Used_per_db'
			)
	SET @value4 = 'LogFile_Size_Used_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]


	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		--boucle pour calculer le taille utilisée par des fichiers log pour chaque db	
		SET @strSql = N'USE ' + QUOTENAME(@dbName) + N'SELECT @value1= (select
		[SPACE_USED_MB] = fileproperty(name,''SpaceUsed'')/128.000
	FROM sys.database_files 
	WHERE type_desc LIKE ''LOG'')';

	
		EXECUTE sp_executesql @strSql
			,N'@value1 decimal(18,2) OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja utilisée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
----selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetLOGFileSize_per_db]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetLOGFileSize_per_db] 

@parameter VARCHAR(100)

	--cette procedure calcule la taille physique des fichies log pour chaque db 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 15
	-- ### processGroupId: 4
	-- ### processTypeId: 1
	-- ### processName: taille des fichiers log de la db
	-- ### processDescription:  retourne  la taille physique pour chaque fichier log de la  db
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetLOGFileSize_per_db'
			)
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'LOGFileSize_per_db'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--bouclepour calcule la taille physique des fichies log pour chaque db 
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = [f].[size] * 8 / 1024
		FROM [master].[sys].[master_files] [f]
		INNER JOIN sys.databases AS s ON f.database_id = s.database_id
		WHERE type_desc LIKE 'LOG'
			AND s.Name LIKE '' + @dbName + ''

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression d'une ligne déja utilisée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetMax_wait_time_ms]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetMax_wait_time_ms] 

@parameter VARCHAR(100)

	--cette procedure retourne en miliseconde la durrée maximale d'une wait
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 27
	-- ### processGroupId: 6
	-- ### processTypeId: 1
	-- ### processName: temp maximal d'atente d'un processus 
	-- ### processDescription: retourne en miliseconde l'attente maximale d'un processus
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	DECLARE @id INT
		,@waitType VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@recepOutputParcint VARCHAR(100)

	-----		-------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetMax_wait_time_ms'
			)
	SET @unit = 'ms'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = SYSDATETIME() --GETDATE()

	----		--------------------------------------
	--table qui recoit les différents type de wait 
	DECLARE @recepwaitType TABLE (
		id INT identity(1, 1)
		,waitType VARCHAR(100)
		)

	INSERT @recepwaitType (waitType)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--cette procedure retourne les diffents type de wait
	EXEC [dbo].[proc_GetwaitType]


	SELECT TOP 1 @id = id
		,@waitType = waitType
	FROM @recepwaitType

	------------------------------------------------------------------------
	--boucle sur différent type de wait pour avoir ca durrée maximale en miliseconde 
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = (
				SELECT TOP 1 max_wait_time_ms
				FROM sys.dm_os_wait_stats
				WHERE wait_type LIKE '' + @waitType + ''
				)

		--select @value1, @param
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value2
			,value3
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@waitType
			,@parameter
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja utilisée
		DELETE TOP (1)
		FROM @recepwaitType
		WHERE waitType = @waitType
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@waitType = waitType
		FROM @recepwaitType

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetNumber_of_deadlocks]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetNumber_of_deadlocks] 

@parameter VARCHAR(100)
	--cette procedure compte le nombre de deadlocks pourvant se produire dans une instance pour une db
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 34
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: nombre de deadlocks
	-- ### processDescription:  retourne le nombre de deadlocks ce produisant dans une base de donnée
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	-----		-------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetNumber_of_deadlocks'
			)
	SET @unit = 'qty'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'numberOf_deadlocks'

	----		--------------------------------------
	--table pour reception des db
	DECLARE @recepDbName TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDbName (dbName)
	----------------------------------------------------------------------
	-- cet§te proc retourne la liste des db 
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName]

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	--SELECT *
	--FROM  @recepDbName
	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDbName

	------------------------------------------------------------------------
	--boucle sur chaque db pour avoir le nombre Deadlocks encouru
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = cntr_value
		FROM sys.dm_os_performance_counters
		WHERE object_name = 'SQLServer:Locks'
			AND counter_name LIKE 'Number of Deadlocks/sec'
			AND instance_name LIKE '' + @dbName + '';

		--select @value1, @param
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepDbName
		WHERE dbName = @dbName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDbName

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetNumberOfPartitions]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetNumberOfPartitions] 

@parameter VARCHAR(100) = NULL

	--cette procedure retourne le nomber de partition restante à la fin dans une table
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 25
	-- ### processGroupId: 8
	-- ### processTypeId: 1
	-- ### processName: nombre de partition vide à la fin
	-- ### processDescription:  retourne le nombre de partition vide à la fin  d'une table partitionner 
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)
		,@shema VARCHAR(50)

	-----		-------------------------------------------
	--------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_GetNumberOfPartitions'
			)
	SET @unit = 'qty'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'empty partition at the end'

	----		--------------------------------------
	--cette table recoit les db et table partitionnées
	DECLARE @receptPartitions TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		)

	INSERT @receptPartitions (
		dbName
		,tableName
		)
	--cette proc retourne le liste des db et table partitionné
	EXEC dbo.getTable_with_partition

	
	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
	FROM @receptPartitions

	--boucle sur chaque base et table correspondente pour compter le nombre de partition vide à la fin
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @strsql = N'select @value1= (SELECT count(1)
				FROM ' + @dbname + '.sys.partitions p
				INNER JOIN ' + @dbname + '.sys.tables t ON p.object_id = t.object_id
				WHERE t.name LIKE ''' +right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + '''
					AND p.index_id = 1
					AND partition_number > (  
						SELECT TOP (1) pp.partition_number
						FROM ' + @dbname + '.sys.partitions pp
						INNER JOIN ' + @dbname + '.sys.tables tt ON pp.object_id = tt.object_id
						WHERE tt.name LIKE ''' +right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + '''
							AND pp.rows > 0
						ORDER BY pp.partition_number DESC
						)) '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)

		DELETE TOP (1)
		FROM @receptPartitions
		WHERE id = @id

		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
		FROM @receptPartitions

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	-- exec [process].[proc_GetNumberOfPartitions] 
	--  select * from metrics
GO
/****** Object:  StoredProcedure [process].[proc_GetPer_cent_FreeAfterGrowth]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetPer_cent_FreeAfterGrowth] 

@parameter VARCHAR(100)

	--cette procedure retourne en % la taille libre d'un disk apres retarit de la taille d'acroissement de la db
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 9
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille disk libre apres growth en %
	-- ### processDescription:  retourne la taille libre du disk en pourcentage aprèes retrait des fichiers growth
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'GetPer_cent_FreeAfterGrowth'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetPer_cent_FreeAfterGrowth'

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	SELECT *
	FROM @temp

	------------------------------------------------------------------------
	--boucle sur chaque diskname pour calculer en pourcentage la taille disponible 
	--apres retrait du pourcentage de la taille d'acroissement 
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = CAST((MIN(VolumeAvailableMo) - SUM(FileGrowthMo)) / MIN(VolumeTotalMo) * 100 AS DECIMAL(6, 2))
		FROM (
			SELECT CASE 
					WHEN f.is_percent_growth = 1
						THEN (CAST(f.size AS FLOAT) * f.growth / 100) * 8 / 1024
					ELSE CAST(f.growth AS FLOAT) * 8 / 1024
					END AS FileGrowthMo
				,CAST(vs.available_bytes AS FLOAT) / 1024 / 1024 AS VolumeAvailableMo
				,CAST(vs.total_bytes AS FLOAT) / 1024 / 1024 AS VolumeTotalMo
			FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			WHERE volume_mount_point LIKE '' + @diskName + ':\'
			) AS fileSizes

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja tratée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_GetSizeDisk]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_GetSizeDisk] 

@parameter VARCHAR(100)

	--cette procedure retourne la taille physique d'un disk
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 1
	-- ### processGroupId: 1
	-- ### processTypeId: 1
	-- ### processName: taille totale du disk
	-- ### processDescription: retourne la taille physique d'un disk
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration de variables 
	DECLARE @id INT
		,@diskName VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@recepOutputParcint VARCHAR(100)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'proc_GetSizeDisk'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des disk
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,diskName VARCHAR(100)
		)

	INSERT @temp (
		processId
		,diskName
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_GetSizeDisk'

	--select @recepOutputParcint = données 
	--from @recepDataparcint
	SELECT TOP 1 @id = id
		,@processId = processId
		,@diskName = diskName
	FROM @temp

	SELECT *
	FROM @temp

	------------------------------------------------------------------------
	--boucle pour chaque nom de disk pour calculer la taille totale disk
	--disk utilis" par sql server
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = cast(min(total_bytes) / 1024 / 1024 AS DECIMAL(18, 2))
		FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
		WHERE volume_mount_point LIKE '' + @diskName + ':\';

		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@diskName
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE diskName = @diskName
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@diskName = diskName
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;
	-- exec [process].[proc_GetSizeDisk] 'C'
	--  select * from metrics
GO
/****** Object:  StoredProcedure [process].[proc_GetSizeDisk_OS]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [process].[proc_GetSizeDisk_OS] 

@parameter VARCHAR(100) = null

--cette proc calcule la taille physique de tous les disques dur ce trouvant dans un Os
--le parametre est à titre indicatif car la proc generale execute plusieur autres proc qui prenne un prametre

--********************************************************************************
--les données ci-dessous commencant par    -- ###   seront       inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collecte de données  et
-- selon cette syntaxe 
--**************************************************************************************
-- ### processId: 35
-- ### processGroupId: 11
-- ### processTypeId: 1
-- ### processName: taille totale du disque fixe du server oS
-- ### processDescription: retourne la taille physique d'un disk donné
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

AS

BEGIN


----------------------------------------------------------------------
--déclaration de variables 
DECLARE @id INT
		,@processId INT
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
    ,@STRLine VARCHAR(8000) 
		, @Drive varchar(500) 
		, @TotalSize real
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------

		SET @unit = 'Mo'    --unité de mesure  
		SET @servername = (SELECT @@SERVERNAME AS instanceName);  --non du serveur
		SET @createdate = GETDATE()  --date de création
		set @value4 = 'physical_disk_size_OS'   --description


	----------------------------------------------------------------------
--table temporaire pour recevoir les noms des disk et sa taille totale
	-------------------------------------------------------------------
CREATE TABLE #DrvLetter (
    Drive VARCHAR(500),
    )

	INSERT INTO #DrvLetter
EXEC xp_cmdshell 'wmic volume where drivetype="3" get caption, capacity'  -- script power shell pour recuperation des infos système

DELETE   -- supression des infos no necessaire comme les disk reservés sys
FROM #DrvLetter
WHERE drive IS NULL OR len(drive) < 4 OR Drive LIKE '%Capacity%'
	OR Drive LIKE  '%\\%\Volume%'

	--select * from #DrvLetter
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recuprération de l'id corespondant à ce process dans la table de planification
	set @processId =( SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_GetSizeDisk_OS')

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle sur la table pour traitement des données et insertion dans metric
	WHILE EXISTS(SELECT 1 FROM #DrvLetter)
	BEGIN

	SET ROWCOUNT 1

SELECT @STRLine = drive FROM #DrvLetter

-- obtenir TotalSize
SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine)) AS real)/1024/1024
--SELECT @TotalSize

-- suprimer TotalSize 
SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX(' ',@STRLine)),'')
-- obtenir le drive

SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)))
--SELECT @Drive


	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@TotalSize
			,@Drive
			,@value4
			,@unit
			,@servername
			,@createdate
			)


	DELETE FROM #DrvLetter
END

SET ROWCOUNT 0

drop table #DrvLetter
END;
	


GO
/****** Object:  StoredProcedure [process].[proc_getTotalMemory]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_getTotalMemory] @parameter VARCHAR(100)
	--cette procedure retourne la taille totale de la memoire du système 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 20
	-- ### processGroupId: 3
	-- ### processTypeId: 1
	-- ### processName: taille physique de la mémoire
	-- ### processDescription:  retourne la taille physique de la mémoire
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		-- ,@parameter VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--calcule la taille totale de la memoire 
	SELECT @value1 = (
			SELECT cast(sum(total_physical_memory_kb / 1024.0) AS DECIMAL(18, 2)) AS total_physical_memory_mb
			FROM sys.dm_os_sys_memory
			CROSS APPLY sys.dm_os_process_memory
			);

	SET @unit = 'Mo'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = SYSDATETIME()
	SET @value4 = 'TotalMemory'

	----		--------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,parameter VARCHAR(100)
		)

	INSERT @temp (
		processId
		,parameter
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recheche du processId correspondant
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_getTotalMemory'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@parameter = parameter
	FROM @temp

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
	
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traité
		DELETE TOP (1)
		FROM @temp
		WHERE parameter = @parameter
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@parameter = parameter
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_Getwait_time_ms]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_Getwait_time_ms] 

@parameter VARCHAR(100)
	--cette procedure retourne en miliseconde le wait d'un processus 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 28
	-- ### processGroupId: 6
	-- ### processTypeId: 1
	-- ### processName: attente en ms d''un processus
	-- ### processDescription:  retourne en miliseconde l'attente  d'un processus
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	DECLARE @id INT
		,@waitType VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	-----		-------------------------------------------
	SET @processId = (
			SELECT processId
			FROM [enum].process
			WHERE procedureName LIKE 'process.proc_GetMax_wait_time_ms'
			)
	SET @unit = 'ms'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = SYSDATETIME()

	----		--------------------------------------
	--table de reception du type de wait
	DECLARE @recepwaitType TABLE (
		id INT identity(1, 1)
		,waitType VARCHAR(100)
		)

	INSERT @recepwaitType (waitType)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--retourne les différent type de wait
	EXEC [dbo].[proc_GetwaitType]


	SELECT TOP 1 @id = id
		,@waitType = waitType
	FROM @recepwaitType

	------------------------------------------------------------------------
	--boucle sur chaque type de wait pour envoyer sa durée
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @value1 = (
				SELECT TOP 1 wait_time_ms
				FROM sys.dm_os_wait_stats
				WHERE wait_type LIKE '' + @waitType + ''
				)

		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value2
			,value3
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@waitType
			,@parameter
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @recepwaitType
		WHERE waitType = @waitType
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@waitType = waitType
		FROM @recepwaitType

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_memoryUsedBySQLServer]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_memoryUsedBySQLServer] 

@parameter VARCHAR(100)

	--cette procedure retourne en % la taille de memoire utilisée par sql server
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 22
	-- ### processGroupId: 3
	-- ### processTypeId: 1
	-- ### processName: taille de la mémoire utilisé par SQL server
	-- ### processDescription:  retourne la taille de la mémoire utilisé par sql server
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		-- ,@parameter VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	--calculle en %  la memoire utilisée par sql server
	-------------------------------------------------------------------
	SELECT @value1 = (cast(physical_memory_in_use_kb / 1024.0 AS DECIMAL(18, 2)) / cast(total_physical_memory_kb / 1024.0 AS DECIMAL(18, 2))) * 100
	FROM sys.dm_os_sys_memory
	CROSS APPLY sys.dm_os_process_memory

	SELECT @value1

	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = SYSDATETIME()
	SET @value4 = 'memoryUsedBySQLServer'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des memoires
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,parameter VARCHAR(100)
		)

	INSERT @temp (
		processId
		,parameter
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_memoryUsedBySQLServer'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@parameter = parameter
	FROM @temp

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supression de la ligne déja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE parameter = @parameter
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@parameter = parameter
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_partion_vide_au_Debut]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_partion_vide_au_Debut] 

@parameter VARCHAR(100) = NULL

	--cette procedure retourne le nombre de partition vide au debut  dans une table d'une db
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 26
	-- ### processGroupId: 8
	-- ### processTypeId: 1
	-- ### processName: nombre de partition vide au début
	-- ### processDescription:  retourne le nombre de partition vide au debut d'une table partitionner
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	DECLARE @id INT
		,@processId INT
		,@value1 NVARCHAR(100)
		,@strSql NVARCHAR(max)
		,@unit VARCHAR(10)
		,@dbName NVARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@tableName NVARCHAR(100)

	-----		-------------------------------------------
	--------------------------------------------------------
	SET @processId = (
			SELECT processId
			FROM enum.process
			WHERE procedureName LIKE 'process.proc_partion_vide_au_Debut'
			)
	SET @unit = 'qty'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'empty partition at the beginning'

	----		--------------------------------------
	--table de reception des db et tables partitionnées
	DECLARE @receptPartitions TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		,tableName VARCHAR(100)
		)

	INSERT @receptPartitions (
		dbName
		,tableName
		)
	--cette proc retourne les db et tables partitionnées
	EXEC dbo.getTable_with_partition

	SELECT TOP 1 @id = id
		,@tableName = tableName
		,@dbName = dbName
	FROM @receptPartitions

	--en fonction de la db et de la table boucle pour calculer le nombre de partition vide au debut
	WHILE @id IS NOT NULL
	BEGIN
		SELECT @strsql = N'select @value1= (SELECT count(1)
				FROM ' + @dbname + '.sys.partitions p
				INNER JOIN ' + @dbname + '.sys.tables t ON p.object_id = t.object_id
				WHERE t.name LIKE ''' + right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + '''
					AND p.index_id = 1
					AND partition_number < (  
						SELECT TOP (1) pp.partition_number
						FROM ' + @dbname + '.sys.partitions pp
						INNER JOIN ' + @dbname + '.sys.tables tt ON pp.object_id = tt.object_id
						WHERE tt.name LIKE ''' + right(@tableName, len(@tableName)  - len(LEFT(@tableName, CHARINDEX('.', @tableName)))) + '''
							AND pp.rows > 0
						ORDER BY pp.partition_number 
						)) '

		EXECUTE sp_executesql @strsql
			,N'@value1 int OUTPUT'
			,@value1 = @value1 OUTPUT

		SELECT @value1
--insertion de données
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@tableName
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)
--supression de la ligne déja traité
		DELETE TOP (1)
		FROM @receptPartitions
		WHERE id = @id
--selection d'une nouvelle 
		SELECT TOP 1 @id = id
			,@tableName = tableName
			,@dbName = dbName
		FROM @receptPartitions

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO
/****** Object:  StoredProcedure [process].[proc_percentMemoryUsed]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_percentMemoryUsed] 

@parameter VARCHAR(100)

	--cette procedure retourne le  % de memoire utilisée 
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 23
	-- ### processGroupId: 3
	-- ### processTypeId: 1
	-- ### processName: pourcentage de mémoire utilisé
	-- ### processDescription:  retourne le pourcentage de mémoire utilisé
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		-- ,@parameter VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--calcul de la memoire utilisée
	SELECT @value1 = cast(sum(memory_utilization_percentage) AS DECIMAL(18, 2))
	FROM sys.dm_os_sys_memory
	CROSS APPLY sys.dm_os_process_memory;

	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'percentMemoryUsed'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des memoires qui n'exite pas 
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,parameter VARCHAR(100)
		)

	INSERT @temp (
		processId
		,parameter
		)
	----------------------------------------------------------------------
	--obtention de l'id corespondant 
	-------------------------------------------------------------------
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_percentSuccesTamponCache'


	SELECT TOP 1 @id = id
		,@processId = processId
		,@parameter = parameter
	FROM @temp

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--boucle pour insertion des données 
	WHILE @id IS NOT NULL
	BEGIN
		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
	
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@servername
			,@createdate
			)

		DELETE TOP (1)
		FROM @temp
		WHERE parameter = @parameter

		SELECT TOP 1 @id = id
			,@parameter = parameter
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
	
END
GO
/****** Object:  StoredProcedure [process].[proc_percentSuccesTamponCache]    Script Date: 17/05/2018 00:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [process].[proc_percentSuccesTamponCache] 

@parameter VARCHAR(100)

	--cette procedure retourne le taux de suxès au cache tampond en ce qui concerne la memoire
	--********************************************************************************
	--les données donc le debut comment par     -- ###    ci§dessous     seront inscrites automatiquement dans la table de process
	--par conséquent il est obligatoire de les inscrires au débuts de chaque procedure de collect de données et
	-- en fonction de la sp inscrivez les infos qui correspondent selon cette syntaxe
	-- ### processId: 24
	-- ### processGroupId: 3
	-- ### processTypeId: 1
	-- ### processName: taux de succès aux cache tampon
	-- ### processDescription: retourne le taux de succès au cache tampon pour la memoire
	-- ### processType: procedure
	-- ### defaultWait: 30
	-- ### monitoringLength: -1
	-- ### lastDuration: 0
	-- ### jobLevel: 0
	-- ### retention: 2018-06-16 12:05:00
	-- ### processRetention: 2018-07-16 12:05:00
	-- ### Auteur: Armand
	-- ### createDate: 2018-04-18 12:05:00
AS
BEGIN
	----------------------------------------------------------------------
	--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		-- ,@parameter VARCHAR(100)
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)

	----------------------------------------------------------------------
	--affcetation des données aux variable 
	-------------------------------------------------------------------
	--calcule le taux de suxcess au cache tempon
	SELECT @value1 = CAST((
				SELECT cntr_value
				FROM sys.dm_os_performance_counters
				WHERE counter_name = 'buffer cache hit ratio'
				) AS DECIMAL(15, 2)) / (
			SELECT cntr_value
			FROM sys.dm_os_performance_counters
			WHERE counter_name = 'buffer cache hit ratio base'
			) * 100
	FROM sys.dm_os_process_memory;

	SET @unit = '%'
	SET @servername = (
			SELECT @@SERVERNAME AS instanceName
			);
	SET @createdate = GETDATE()
	SET @value4 = 'percentSuccesTamponCache'

	----------------------------------------------------------------------
	--table temporaire pour recevoir les noms des memoires par conséquent   n'exite pas 
	-------------------------------------------------------------------
	DECLARE @temp TABLE (
		id INT identity(1, 1)
		,processId INT
		,parameter VARCHAR(100)
		)

	INSERT @temp (
		processId
		,parameter
		)
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	--recherche de l'id corespondant 
	SELECT pp.processId
		,pp.parameter
	FROM [enum].process p
	INNER JOIN enum.planification pp ON p.processId = pp.processId
	WHERE p.procedureName LIKE 'process.proc_percentSuccesTamponCache'

	

	SELECT TOP 1 @id = id
		,@processId = processId
		,@parameter = parameter
	FROM @temp

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		----------------------------------------------------------------------
		--insertions des données dans la table des metrics
		-------------------------------------------------------------------
	
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@value1
			,@parameter
			,@value4
			,@unit
			,@servername
			,@createdate
			)
--supresion de la ligne deja traitée
		DELETE TOP (1)
		FROM @temp
		WHERE parameter = @parameter
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
			,@parameter = parameter
		FROM @temp

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

GO


USE [monitoring]
GO

/****** Object:  StoredProcedure [dbo].[select_data_from_metrics]    Script Date: 22/05/2018 14:56:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[select_data_from_metrics]

--cette procedure permet de faire une selection dans la table des metriques des autres server
--pour leur deployement vers le server centrale 
--elle met à 1 les données selectionnées pour ne prendre que celles qui sont à null au prochain passage
as
begin

update dbo.metrics
set isSync =1
output         
		  deleted.processId
		, deleted.value1
		, deleted.value2
		, deleted.value3
		, deleted.value4
		, deleted.unitMeasure
		, deleted.dbName
		, deleted.serverName
		, deleted.createDate
		, deleted.isSync
WHERE      isSync IS NULL

end
GO


create proc [dbo].[select_data_from_agregation]

--cette procedure permet de faire une selection dans la table des agregation des autres server
--pour leur deployement vers le server centrale 
--elle met à 1 les données selectionnées pour ne prendre que celles qui sont à null au prochain passage

as
begin

update dbo.agregation_by_day
set isSync =1
output         
		  deleted.[processId]     
		 ,deleted.[currentValue]
		, deleted.[minimum]
		, deleted.[maximum]
		, deleted.[croissance]
		, deleted.[volumePoint]
		, deleted.[tableRecort]
		, deleted.[unit]
		, deleted.[description]
		, deleted.[dbName]
		, deleted.[serverName]
		, deleted.[createDate]
		, deleted.isSync
WHERE      isSync IS NULL

end
GO


---------------------------------------------------------------------------------
--------------------------------------------------------------------------------
USE [monitoring]
GO

create PROCEDURE [process].[proc_Get_max_Size_per_db] @parameter varchar (100) = null



--********************************************************************************
--ces données seront inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque sp et
-- en fonction de la sp inscrivez les infos qui correspondent
--**************************************************************************************
-- ### tessss: 0
-- ### processId: 39
-- ### processGroupId: 4
-- ### processTypeId: 1
-- ### processName: espace maximum de la db pour fichiers data
-- ### processDescription:  retourne la taille maximale d'une db pour les fichiers data
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

AS
BEGIN
----------------------------------------------------------------------
--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@maxSize int
		--,@parameter varchar(100) = null
		,@strSql NVARCHAR(1000)
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------

	SET @unit = 'Mo'
		SET @servername = (
				SELECT @@SERVERNAME AS instanceName
				);
		SET @createdate = GETDATE()
		SET @processId = (
				SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_Get_max_Size_per_db'
				)

		set @value4 = 'max_Size_per_db'
	----------------------------------------------------------------------
--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDb TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDb 
		
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName] 
	SELECT *
	FROM @recepDb

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDb

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		
SET @strSql = N' select @maxSize = (select  max_size 
FROM '+@dbName+'.sys.database_files
where type_desc = ''ROWS'')'
execute sp_executesql @strsql, N'@maxSize int OUTPUT', @maxSize = @maxSize out
select @maxSize
			
		
	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@maxSize
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)

		DELETE TOP (1)
		FROM @recepDb
		WHERE dbName = @dbName

		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDb

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;

go

------------------------------------------------------------
---------------------------------------------------------------
USE [monitoring]
GO

create PROCEDURE [process].[proc_Get_log_max_Size_per_db] @parameter varchar (100) = null



--********************************************************************************
--ces données seront inscrites automatiquement dans la table de process
--par conséquent il est obligatoire de les inscrires au débuts de chaque sp et
-- en fonction de la sp inscrivez les infos qui correspondent
--**************************************************************************************
-- ### test: 40
-- ### processId: 40
-- ### processGroupId: 4
-- ### processTypeId: 1
-- ### processName: espace maximum de la db pour fichiers log
-- ### processDescription:  retourne la taille maximale d'une db pour les fichiers log
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

AS
BEGIN
----------------------------------------------------------------------
--déclaration des variable
	-------------------------------------------------------------------
	DECLARE @id INT
		,@processId INT
		,@value1 DECIMAL(18, 2)
		,@unit VARCHAR(10)
		,@dbName VARCHAR(100)
		,@value4 VARCHAR(100)
		,@servername VARCHAR(100)
		,@createdate DATETIME2(0)
		,@maxSize int
		--,@parameter varchar(100) = null
		,@strSql NVARCHAR(1000)
	----------------------------------------------------------------------
--affcetation des données aux variable 
	-------------------------------------------------------------------

	SET @unit = 'Mo'
		SET @servername = (
				SELECT @@SERVERNAME AS instanceName
				);
		SET @createdate = GETDATE()
		SET @processId = (
				SELECT processId
				FROM [enum].process
				WHERE procedureName LIKE 'process.proc_Get_log_max_Size_per_db'
				)

		set @value4 = 'max_log_Size_per_db'
	----------------------------------------------------------------------
--table temporaire pour recevoir les noms des bases de données 
	-------------------------------------------------------------------
	DECLARE @recepDb TABLE (
		id INT identity(1, 1)
		,dbName VARCHAR(100)
		)

	INSERT @recepDb 
		
	----------------------------------------------------------------------
	-------------------------------------------------------------------
	EXEC [dbo].[proc_GetDbName] 
	SELECT *
	FROM @recepDb

	SELECT TOP 1 @id = id
		,@dbName = dbName
	FROM @recepDb

	------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WHILE @id IS NOT NULL
	BEGIN
		
SET @strSql = N' select @maxSize = (select  max_size 
FROM '+@dbName+'.sys.database_files
where type_desc = ''LOG'')'
execute sp_executesql @strsql, N'@maxSize int OUTPUT', @maxSize = @maxSize out
select @maxSize
			
		
	----------------------------------------------------------------------
--insertions des données dans la table des metrics
	-------------------------------------------------------------------
		INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
		VALUES (
			@processId
			,@maxSize
			,@parameter
			,@value4
			,@unit
			,@dbName
			,@servername
			,@createdate
			)

		DELETE TOP (1)
		FROM @recepDb
		WHERE dbName = @dbName

		SELECT TOP 1 @id = id
			,@dbName = dbName
		FROM @recepDb

		IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
END;


go


---------------------------------------------------------------------------------
use monitoring
go

create  proc  dbo.db_and_Table_with_express_maintenance

as
begin

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +='
    SELECT ''' + name + ''', s.name+''.''+t.name
    FROM ' + QUOTENAME(name) + '.sys.tables AS t
    INNER JOIN ' + QUOTENAME(name) + '.sys.schemas AS s
    ON t.schema_id = s.schema_id'
    FROM sys.databases
    WHERE database_id > 4;

EXECUTE sp_executesql @sql

end
go
----------------------------------------------------------------------------------------------------------------

use monitoring
go


create proc [process].[db_and_table_data_compression_option]  @parameter varchar(100) = null

----********************************************************************************
----cette procedure fera une collecte par jour pour une analyse express des données de la db 
----en cas d'ajout d'une procedures fesant la meme chose, elle devra avoir syntaxe ci-dessous 
---- 
----**************************************************************************************

-- ### prosId: 4
-- ### processId: 43
-- ### processGroupId: 12
-- ### processTypeId: 1
-- ### processName: type of data compression 
-- ### processDescription:  permet permet de savoir le type de compression qu'on retrouve sur une table  
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

as 
begin

declare  @id int
,@dbName varchar(50)
,@data_compression_option Nvarchar(max) 
,@processId varchar(10)
,@value4 varchar(100)
,@unit varchar(50)
,@tableName  varchar(100)
,@createDate datetime2(0) = getdate()
,@serverName varchar(100) = (SELECT @@SERVERNAME as instanceName)
,@value1 varchar(1000)

--table de reception des différentes bases de données 
declare  @db_and_table table (id int identity(1,1) , dbName varchar(50), tableName varchar(100))
INSERT @db_and_table 
	exec dbo.db_and_Table_with_express_maintenance
	--select * from  @db_and_table
	
--tables de reception des données collectées
declare @expressTable table (
	 Id INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
	 ,processId int
	 ,data_compression int 
	 	,tableName varchar(100) 
		,name varchar(100)
		,unit varchar(50)
		,dbName varchar(100)
	,serverName varchar(100)
	,createDate datetime2(0)
	);

set @value4 = 'db_and_table_data_compression_option'
	SET @unit = 'number'
SET @processId = ( select processId 
				FROM [enum].process 
				WHERE procedureName LIKE 'process.db_and_table_data_compression_option')

SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id



--boucle sur les différentes ligne de la table temporaire contenant les noms de base de données 
while @id is not null                           
begin 
-- en fonction de la base de données recherche les informations necessaire dans les système 
select @data_compression_option = N'select @value1 =(select top(1)  p.data_compression 
						from '+@dbName+'.sys.partitions p 
						inner join  '+@dbName+'.sys.tables t 
						on t.object_id = p.object_id  
						where  t.name = '''+right(@tableName, len(@tableName)  
						- len(LEFT(@tableName, CHARINDEX('.', @tableName))))+''')'

				execute sp_executesql @data_compression_option, N'@value1 int OUTPUT', @value1 = @value1 out
			--	select @value1

--insert @expressTable (
--	 processId 
--	 ,data_compression  
--	 	,tableName 
--		,name 
--		,unit 
--		,dbName 
--	,serverName 
--	,createDate 
--	)
--values
--(
--@processId
--,@value1
--,@tableName
--,@value4
--,@unit
--,@dbName
--,@serverName
--,@createDate
--)

INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
values
(
@processId
,@value1
,@tableName
,@value4
,@unit
,@dbName
,@serverName
,@createDate
)

--supression de la ligne déja traitée 
DELETE
		FROM @db_and_table
		WHERE id = @id

--nouvelle  selection d'une nouvelle pour un nouveau traitement 
		SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id

		--si les cellule sont 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL

	END;

--select * from  @expressTable
END;

--exec  [process].[db_and_table_data_compression_option]
 --  select * from  dbo.metrics 

go
------------------------------------------------------------------------------------------------------------------
use monitoring
go

create proc [process].[db_and_table_is_incremental_option]  @parameter varchar(100) = null

----********************************************************************************
----cette procedure fera une collecte par jour pour une analyse express des données de la db 
----en cas d'ajout d'une procedures fesant la meme chose, elle devra avoir syntaxe ci-dessous 
---- 
----**************************************************************************************
-- ### prosId: 4
-- ### processId: 41
-- ### processGroupId: 12
-- ### processTypeId: 1
-- ### processName: statistique incrémental 
-- ### processDescription:  permet de savoir si une table possède l'option statistique incrémental ou pas 
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

as 
begin

declare  @id int
,@dbName varchar(50)
,@is_incremental_option Nvarchar(max) 
,@processId varchar(10)
,@value4 varchar(100)
,@unit varchar(50)
,@tableName  varchar(100)
,@createDate datetime2(0) = getdate()
,@serverName varchar(100) = (SELECT @@SERVERNAME as instanceName)
,@value1 varchar(1000)

--table de reception des différentes bases de données 
declare  @db_and_table table (id int identity(1,1) , dbName varchar(50), tableName varchar(100))
INSERT @db_and_table 
	exec dbo.db_and_Table_with_express_maintenance
	--select * from  @db_and_table

--tables de reception des données collectées
declare @expressTable table (
	 Id INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
	 ,processId int
	 ,is_incremental int 
	 	,tableName varchar(100) 
		,name varchar(100)
		,unit varchar(50)
		,dbName varchar(100)
	,serverName varchar(100)
	,createDate datetime2(0)
	);

set @value4 = 'db_and_table_is_incremental_option'
	SET @unit = 'bit'
SET @processId= ( select processId 
				FROM [enum].process 
				WHERE procedureName LIKE 'process.db_and_table_is_incremental_option')

SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id


--boucle sur les différentes ligne de la table temporaire contenant les noms de base de données 
while @id is not null                           
begin 
-- en fonction de la base de données recherche les informations necessaire dans les système 

select @is_incremental_option = N'select @value1 =(select top(1)  s.is_incremental 
						FROM '+@dbname+'.sys.stats s
						inner join  '+@dbName+'.sys.tables t 
						on t.object_id = s.object_id  
						where  t.name = '''+right(@tableName, len(@tableName)  
						- len(LEFT(@tableName, CHARINDEX('.', @tableName))))+''')'

				execute sp_executesql @is_incremental_option, N'@value1 int OUTPUT', @value1 = @value1 out
					--	select @value1

	--insertion de données dans la table creé plus haut							

--insert @expressTable (
--	 processId 
--	 ,data_compression  
--	 	,tableName 
--		,name 
--		,unit 
--		,dbName 
--	,serverName 
--	,createDate 
--	)
--values
--(
--@processId
--,@value1
--,@tableName
--,@value4
--,@unit
--,@dbName
--,@serverName
--,@createDate
--)

INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
values
(
@processId
,@value1
,@tableName
,@value4
,@unit
,@dbName
,@serverName
,@createDate
)

--supression de la ligne déja traitée 
DELETE
		FROM @db_and_table
		WHERE id = @id

--nouvelle  selection d'une nouvelle pour un nouveau traitement 
		SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id

		--si les cellule sont 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL

	END;

delete @expressTable
END;

 --select * from  dbo.metrics 

go
----------------------------------------------------------------------------------------------------
use monitoring 

go
create proc [process].[db_and_table_no_recompute_option]  @parameter varchar(100) = null

----********************************************************************************
----cette procedure fera une collecte par jour pour une analyse express des données de la db 
----en cas d'ajout d'une procedures fesant la meme chose, elle devra avoir syntaxe ci-dessous 
---- 
----**************************************************************************************
-- ### prosId: 4
-- ### processId: 42
-- ### processGroupId: 12
-- ### processTypeId: 1
-- ### processName: statistique no recompute 
-- ### processDescription:  permet de savoir si une table possède l'option statistique no recumpute ou pas 
-- ### processType: procedure
-- ### defaultWait: 30
-- ### monitoringLength: -1
-- ### lastDuration: 0
-- ### jobLevel: 0
-- ### retention: 2018-06-16 12:05:00
-- ### processRetention: 2018-07-16 12:05:00
-- ### Auteur: Armand
-- ### createDate: 2018-04-18 12:05:00

as 
begin

declare  @id int
,@dbName varchar(50)
,@no_recompute_option Nvarchar(max) 
,@processId varchar(10)
,@value4 varchar(100)
,@unit varchar(50)
,@tableName  varchar(100)
,@createDate datetime2(0) = getdate()
,@serverName varchar(100) = (SELECT @@SERVERNAME as instanceName)
,@value1 varchar(1000)

--table de reception des différentes bases de données 
declare  @db_and_table table (id int identity(1,1) , dbName varchar(50), tableName varchar(100))
INSERT @db_and_table 
	exec dbo.db_and_Table_with_express_maintenance
	--select * from  @db_and_table

--tables de reception des données collectées
declare @expressTable table (
	 Id INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
	 ,processId int
	 ,no_recompute int 
	 	,tableName varchar(100) 
		,name varchar(100)
		,unit varchar(50)
		,dbName varchar(100)
	,serverName varchar(100)
	,createDate datetime2(0)
	);

set @value4 = 'db_and_table_no_recumpute_option'
	SET @unit = 'bit'
SET @processId = ( select processId 
				FROM [enum].process 
				WHERE procedureName LIKE 'process.db_and_table_no_recompute_option')

SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id



--boucle sur les différentes ligne de la table temporaire contenant les noms de base de données 
while @id is not null                           
begin 
-- en fonction de la base de données recherche les informations necessaire dans les système 

select @no_recompute_option = N'select @value1 =(select top(1)  s.no_recompute 
						FROM '+@dbname+'.sys.stats s
						inner join  '+@dbName+'.sys.tables t 
						on t.object_id = s.object_id  
						where  t.name = '''+right(@tableName, len(@tableName)  
						- len(LEFT(@tableName, CHARINDEX('.', @tableName))))+''')'

				execute sp_executesql @no_recompute_option, N'@value1 int OUTPUT', @value1 = @value1 out
					--	select @value1

	--insertion de données dans la table creé plus haut							

--insert @expressTable (
--	 processId 
--	 ,data_compression  
--	 	,tableName 
--		,name 
--		,unit 
--		,dbName 
--	,serverName 
--	,createDate 
--	)
--values
--(
--@processId
--,@value1
--,@tableName
--,@value4
--,@unit
--,@dbName
--,@serverName
--,@createDate
--)

INSERT INTO [dbo].metrics (
			processId
			,value1
			,value3
			,value4
			,unitMeasure
			,dbName
			,serverName
			,createDate
			)
values
(
@processId
,@value1
,@tableName
,@value4
,@unit
,@dbName
,@serverName
,@createDate
)

--supression de la ligne déja traitée 
DELETE
		FROM @db_and_table
		WHERE id = @id

--nouvelle  selection d'une nouvelle pour un nouveau traitement 
		SELECT TOP 1 @id = id
		,@dbName = dbName
		,@tableName = tableName
	FROM @db_and_table
	ORDER BY id

		--si les cellule sont 0
		IF @@ROWCOUNT <= 0
			SET @id = NULL

	END;

delete @expressTable
END;

--exec  [process].[db_and_table_no_recompute_option]
 --  select * from  dbo.metrics 


----------------------------------------------------------------------------------------------------------




