--script generale alerte de type deux

use monitoring
go

/****** pour les procedures et tables des alerts ******/
CREATE SCHEMA [alert]
GO
--*************************************************creation des différentes tables pour le système alertes*****************
--table stockant les types d'alertes
CREATE TABLE [alert].[alertType](
	 [alertTypeId] [int] IDENTITY(1,1) NOT NULL primary key 
	,alertTypeName varchar(100)
)

--table de reception des informations concernant les alertes
create table dbo.alertSysteme(
alertSystemeId int identity(1,1) not null primary key
,processId int not null
,description varchar(100)
,processValue int
,WarnningValue int 
,emergencyValue int
,serverName varchar(100)
,dbName varchar(100)
,objectIndication varchar(100)
,status varchar(100)
,message varchar(max)
,createDate datetime2(0)
,CONSTRAINT alertType_processId_process 
FOREIGN KEY (processId) REFERENCES [enum].[process] (processId)

)
-----------------------------------------------------------------------------------------------------------


insert into  [alert].[alertType](alertTypeName)
values
('table in data bases')
,('Email')
----------------------------------------------------------------------------------------------------------------
--table stockant les les différents processus d'alerte

CREATE TABLE [alert].[alertProcess](
	[alertProcessId] [int] IDENTITY(1,1) NOT NULL primary key
	,alertTypeId int not null 
	,processTypeId int not null
	,processGroupsId int not null
	,[processAlertName] [varchar](200) NULL
	,[thresholdWarnning] [int] NULL
	,[thresholdUrgent] [int] NULL
	,[thresholText]  [varchar](200) NULL
	,[transmitter] [varchar](100) NULL
	,[subject] [varchar](200) NULL
	,[recipient] [varchar](100) NULL
  ,CONSTRAINT [alertProcess_processId_processType_processId] FOREIGN KEY([processTypeId])
  REFERENCES [enum].[processType] ([processTypeId])
 ,CONSTRAINT [groups_groupsId_alertProcess_groupsId] FOREIGN KEY([processGroupsId])
  REFERENCES [enum].[processGroups] ([processGroupsId])
 ,CONSTRAINT alertType_alertTypeId_alertProcess 
FOREIGN KEY (alertTypeId) REFERENCES [alert].[alertType] (alertTypeId)
)
----------------------------------------------------------------------------------------------------------------
--table de journalisation des processus d'alertes

CREATE TABLE [alert].[logProcessAlert](
	 [logProcessAlertId] [int] IDENTITY(1,1) NOT NULL primary key
	 ,alertProcessId int 
	,[logprocessAlertName] [varchar](200) NULL
  ,logDate DATETIME2(0)
	,isProcessError bit
	,ErrorMessage varchar(max)
	,CONSTRAINT logProcessAlert_logProcessAlertId_alertProcess 
	FOREIGN KEY (alertProcessId) REFERENCES [alert].[alertProcess]
)
---------------------------------fin table----------------------------------------------------------------------------

------------------------------creation des procedures et travil planifier sur les alertes--------------------------------

--******************************travail d'insertion des données dant la table alertSystème*******************************

--*************************************************************************************************************************
go
--***************************************différentes procedures d'alertind************************************************
use monitoring
go

create PROC  alert.proc_alert_of_satistique_option_type_Table

@thresholdUrgent int
,@thresholdWarnning int = null
,@thresholText varchar(100) = null

--cette proc envera des alertes  pour toutes  tablese trouvant 
---dans une base de donnée n'ayant pas les options mentionnées
--ci-desous en ce qui concerne un serveur données
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 1
-- ### processTypeId: 1 
-- ### processGroupsId: 12
-- ### thresholdWarnning: 0
-- ### thresholdUrgent: 0
-- ### thresholText: null
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: desable statistique option 
-- ### recipient: marceltsameza@gmail.com

AS
begin

	DECLARE 
	 @statistique_option int 
	 ,@processId int
	--,@thresholdUrgent int = 0   --indique une option non activé sur une table 
	,@objectIndication varchar(100)
	,@description varchar(100)
	,@dbName  varchar(100)
	,@serverName varchar(100)
	, @id int
	, @statistiqueMessage varchar(500)
	,@mode varchar(100)
	,@warningDate datetime2(0) = getdate() 
	,@emergencyDate datetime2(0) = getdate() 
	
	--table temporaire de reception des différentes informations à analyser
	declare @temp table 
	(id int identity (1,1)
	,processId int
	,is_option int
	,objectIdication varchar(100)
	,description varchar(100)
	,dbName varchar(100)
	,serverName varchar(100)
	,createDate datetime2(0) 
	)
	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as expressAnalyse
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId in (41, 42, 43)
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate
--select * from @temp
SELECT TOP 1 @id = id
		,@processId = processId
		,@statistique_option = is_option
		,@objectIndication = objectIdication
		,@description = description
		,@dbName = dbName
		,@serverName = serverName
	FROM @temp

	--boucle sur les différents données selectionnés pour verifier si une donnée corespond 
	-- aux kpi fixé dans la table d'alerte
	while @id is not null
begin
    -- CASE 
		 -- when  @statistique_incrementale = @thresholdUrgent  then 
		 if  @statistique_option = @thresholdUrgent
		 begin
		 set @mode = 'urgence'
		   set @statistiqueMessage = 'ugent Notification of  '+@description +':  The '+@description +' is desabled'+'  '
		 + ' in  '+ @objectIndication+'  ' +  'of the dataBase'+'  ' +  @dbName +'  '+ 'on server'+'  ' + @serverName 	
insert into dbo.alertSysteme
(processId ,description, processValue, emergencyValue, serverName ,dbName ,objectIndication ,status ,message ,createDate )
values
(@processId, @description, @statistique_option, @thresholdUrgent, @serverName, @dbName, @objectIndication, @mode, @statistiqueMessage, @emergencyDate)
end
else
begin
set @mode = 'ok'
 set @statistiqueMessage = ''
insert into dbo.alertSysteme
(processId ,description , processValue, serverName ,dbName ,objectIndication ,status ,message ,createDate )
values
(@processId, @description , @statistique_option, @serverName, @dbName, @objectIndication, @mode, @statistiqueMessage, @emergencyDate)
end
	
--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
		,@processId = processId
		,@statistique_option = is_option
		,@objectIndication = objectIdication
		,@description = description
		,@dbName = dbName
		,@serverName = serverName
	FROM @temp
--dans ce cas si plus de ligne 
	IF @@ROWCOUNT <= 0
			SET @id = NULL
END;
end
go
--------------------------------------------------------------------------------------------------------------------
create PROC alert.proc_freeSpaceDb_alerts_of_type_log_type_table
	
	@threshold_warnning_Db int
	,@threshold_urgent_Db int
	,@thresholText varchar(100) = null



AS
begin

--cette proc envera des alertes  pour toutes databases se trouvant 
---dans une instance dont est faible  en ce qui concerne les fichiers journal
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 1
-- ### processTypeId: 1 
-- ### processGroupsId: 4
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 870
-- ### thresholText: none
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low space database nitification in data type log
-- ### recipient: marceltsameza@gmail.com
--*********************************************************************************
--declaration des variable de travail
--**********************************************************************************

	DECLARE 
	
	@threshold_warnning_Growth int = 2   -- 70 space db
	--,@threshold_warnning_Db int = 870 -- 100 space db
	--,@threshold_urgent_Db int = 870 -- 100 space db
	,@threshold_urgent_Growth int = 3   -- 70 space db
	,@dbFreeSpace int
	,@growthSpace int 
	,@maxSizeSpace int
	,@typeFilefreeSpace varchar(100) --en ce qui concerne la db
	,@typeFilegrowth varchar(100)     --en ce qui concerne le growth
	,@typeFilemaxsize varchar(100)  -- en ce qui concerne la taille max
	, @indicationfreeSpace varchar(100)  --en ce qui concerne la db
	, @indicationGrowth varchar(100)      --en ce qui concerne le growth
	, @indicationmaxsize varchar(100)      --en ce qui concerne la taille max
	, @dbNamefreeSpace  varchar(100)     --en ce qui concerne la db
	, @dbNamegrowth  varchar(100)           --en ce qui concerne le growth
	, @dbNamemaxsize  varchar(100)    --en ce qui concerne la taille max
	, @serverNamefreeSpace varchar(100)    --en ce qui concerne la db
	, @serverNamegrowth varchar(100)        --en ce qui concerne le growth
	, @serverNamemaxsize varchar(100)    --en ce qui concerne la taille max
	, @id int
	,@processType1 int --en ce qui concerne la db
	,@processType2 int --en ce qui concerne le growth
	,@processType3 int --en ce qui concerne la taille max
	,@strsql Nvarchar(max)         --pour recherche de taille max de la db
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)
	,@warningMode varchar(50)
	,@emergencyMode varchar(50)
	,@warningDate datetime2(0) = getdate() 
	,@emergencyDate datetime2(0) = getdate()



	--table temporaire de reception des taille maximales de chaques db en ce qui concerne des fichiers data
		declare @tempMaxSize table 
	(maxSizeId int identity (1,1)
	,processId3 int
	, maxSize int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

insert @tempMaxSize
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 40
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate

	--table temporaire de reception des element auto growth en ce qui concerne des fichiers data
		declare @tempGrowth table 
	(growthId int identity (1,1)
	,processId2 int
	, growth int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

insert @tempGrowth
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 19
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate

	--table temporaire de reception des element e l'espace free db en ce qui concerne les fichiers data
	declare @tableFreeSpace table 
	(id int identity (1,1)
	,processId1 int
	, dbFreeSpace int
	, typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

	insert @tableFreeSpace
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 16
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate


	--select * from metrics
	--table temporaire de jointure sur les trois tables precedente pour reception des  infos finales
	declare @temp table 
	(id int identity (1,1)
	,processId1 int,dbFreeSpace int, f_typeFile varchar(100), f_indication varchar(100), f_dbName varchar(100), f_serverName varchar(100)
	,processId2 int,growth int , g_typeFile varchar(100), g_indication varchar(100), g_dbName varchar(100), g_serverName varchar(100)
	,processId3 int,maxSize int , m_typeFile varchar(100), m_indication varchar(100), m_dbName varchar(100), m_serverName varchar(100)
	)
	insert @temp
		SELECT 
		f.processId1
		,f.dbFreeSpace  as dbFreeSpace
		, f.typeFile as volume
		,f.indication as indication
		, f.dbname as dbName
		,f.serverName as serverName
		,g.processId2
		 ,g.growth as growth
		,g.typeFile as volume
		,g.indication as indication
		, g.dbname as dbName
		, g.serverName as serverName
		,m.processId3
		 ,m.maxSize as maxSize
		,m.typeFile as volume
		,m.indication as indication
		, m.dbname as dbName
		, m.serverName as serverName
		from @tableFreeSpace f join @tempGrowth g on f.id = g.growthId join  @tempMaxSize m on m.maxSizeId = g.growthId

--select * from @temp


SELECT TOP 1 @id = id
		,@processType1 = processId1
		,@dbFreeSpace = dbFreeSpace
		,@typeFilefreeSpace = f_typeFile
		,@indicationfreeSpace = f_indication
		,@dbNamefreeSpace = f_dbName
		,@serverNamefreeSpace = f_serverName
		,@growthSpace = growth
		,@typeFilegrowth = g_typeFile
		,@indicationGrowth = g_indication
		,@dbNamegrowth = f_dbName
		,@serverNamegrowth = g_serverName
		,@maxSizeSpace = maxSize
		,@typeFilemaxsize = m_typeFile
		,@indicationmaxsize = m_indication
		,@dbNamemaxsize = m_dbName
		,@serverNamemaxsize = m_serverName
	FROM @temp

--select * from @temp

	while @id is not null
begin

	IF @dbFreeSpace < @threshold_warnning_Db   --espace libre db < au kpi  d'attention
	and @maxSizeSpace != -1   --taille fixe
	and  @growthSpace != 0  --autogrowth active
	and @dbFreeSpace/@growthSpace < @threshold_warnning_Growth 
	begin
		IF @dbFreeSpace < @threshold_urgent_Db  --espace free inférieur au kpi  d'urgence 
				and @maxSizeSpace != -1   --taille fixe
				and  @growthSpace != 0  --autogrowth active
				and @dbFreeSpace/@growthSpace < @threshold_urgent_Growth  
			BEGIN
					set  @emergencyMode = 'urgence'
					--message à envoyer
						set @urgentMessage = ' urgent: Low space db Notification. The following space of data base are currently reporting less than ' 
						+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
						+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

						--profil mail de notification
				 insert into dbo.alertSysteme
					(processId ,description, processValue, emergencyValue ,serverName ,dbName ,status ,message ,createDate )
				values
				(@processType1, @indicationfreeSpace, @dbFreeSpace, @threshold_urgent_Db , @serverNamefreeSpace, @dbNamefreeSpace,   @emergencyMode, @urgentMessage, @emergencyDate)
			end
		else 
				BEGIN
					set @warningMode = 'attention'
					--message à envoyer
						set @warnningMessage  = ' warnning: Low space db Notification. The following space of data base are currently reporting less than ' 
						+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
						+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

				 insert into dbo.alertSysteme
					(processId ,description , processValue, WarnningValue ,serverName ,dbName ,status ,message ,createDate )
				values
				(@processType1, @indicationfreeSpace  , @dbFreeSpace, @threshold_warnning_Db, @serverNamefreeSpace, @dbNamefreeSpace,  @warningMode, @warnningMessage, @warningDate)
		end
 end
else
begin
set @warningMode = 'ok'
set @warnningMessage  = ''
 insert into dbo.alertSysteme
  (processId ,description, processValue ,serverName ,dbName  ,status ,message ,createDate)
values
(@processType1, @indicationfreeSpace  , @dbFreeSpace, @serverNamefreeSpace, @dbNamefreeSpace,  @warningMode, @warnningMessage, @warningDate)
end



	--supréssion de l'id déja traité de la table 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

 --nouvelle selection de l'element a traité
		SELECT TOP 1 @id = id
		,@processType1 = processId1
		,@dbFreeSpace = dbFreeSpace
		,@typeFilefreeSpace = f_typeFile
		,@indicationfreeSpace = f_indication
		,@dbNamefreeSpace = f_dbName
		,@serverNamefreeSpace = f_serverName
		,@growthSpace = growth
		,@typeFilegrowth = g_typeFile
		,@indicationGrowth = g_indication
		,@dbNamegrowth = f_dbName
		,@serverNamegrowth = g_serverName
		,@maxSizeSpace = maxSize
		,@typeFilemaxsize = m_typeFile
		,@indicationmaxsize = m_indication
		,@dbNamemaxsize = m_dbName
		,@serverNamemaxsize = m_serverName
	FROM @temp

	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;

	--supression des table temporaire à la fin du traitement
	delete  @tableFreeSpace
	delete @tempGrowth
	delete @tempMaxSize

end
go
-------------------------------------------------------------------------------------------------------------
use monitoring
go
create proc alert.proc_freeSpaceDb_alerts_of_type_data_type_table
	
  	 @threshold_warnning_Db int
  	,@threshold_urgent_Db int
		,@thresholText varchar(100) = null

AS
begin

--cette proc envera des alertes  pour toutes databases se trouvant 
---dans une instance dont est faible  en ce qui concerne les fichiers data
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 1
-- ### processTypeId: 1 
-- ### processGroupsId: 4
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 870
-- ### thresholText: none
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low  database space nitification in file type data
-- ### recipient: marceltsameza@gmail.com
--*********************************************************************************
--declaration des variable de travail
--**********************************************************************************

	DECLARE 

	@threshold_warnning_Growth int = 2   -- 70 space db
	--,@threshold_warnning_Db int = 870 -- 100 space db
	--,@threshold_urgent_Db int = 870 -- 100 space db
	,@threshold_urgent_Growth int = 3   -- 70 space db
	,@dbFreeSpace int
	,@growthSpace int 
	,@maxSizeSpace int
	,@typeFilefreeSpace varchar(100) --en ce qui concerne la db
	,@typeFilegrowth varchar(100)     --en ce qui concerne le growth
	,@typeFilemaxsize varchar(100)  -- en ce qui concerne la taille max
	, @indicationfreeSpace varchar(100)  --en ce qui concerne la db
	, @indicationGrowth varchar(100)      --en ce qui concerne le growth
	, @indicationmaxsize varchar(100)      --en ce qui concerne la taille max
	, @dbNamefreeSpace  varchar(100)     --en ce qui concerne la db
	, @dbNamegrowth  varchar(100)           --en ce qui concerne le growth
	, @dbNamemaxsize  varchar(100)    --en ce qui concerne la taille max
	, @serverNamefreeSpace varchar(100)    --en ce qui concerne la db
	, @serverNamegrowth varchar(100)        --en ce qui concerne le growth
	, @serverNamemaxsize varchar(100)    --en ce qui concerne la taille max
	, @id int
	,@processType1 int --en ce qui concerne la db
	,@processType2 int --en ce qui concerne le growth
	,@processType3 int --en ce qui concerne la taille max
	,@strsql Nvarchar(max)         --pour recherche de taille max de la db
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)
	,@warningMode varchar(50)
	,@emergencyMode varchar(50)
	,@warningDate datetime2(0) = getdate() 
	,@emergencyDate datetime2(0) = getdate()



	--table temporaire de reception des taille maximales de chaques db en ce qui concerne des fichiers data
		declare @tempMaxSize table 
	(maxSizeId int identity (1,1)
	,processId3 int
	, maxSize int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

insert @tempMaxSize
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 39
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate

	--table temporaire de reception des element auto growth en ce qui concerne des fichiers data
		declare @tempGrowth table 
	(growthId int identity (1,1)
	,processId2 int
	, growth int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

insert @tempGrowth
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 14
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate

	--table temporaire de reception des element e l'espace free db en ce qui concerne les fichiers data
	declare @tableFreeSpace table 
	(id int identity (1,1)
	,processId1 int
	, dbFreeSpace int
	, typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100)
	,createDate datetime2(0))

	insert @tableFreeSpace
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 11
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate


	--select * from metrics
	--table temporaire de jointure sur les trois tables precedente pour reception des  infos finales
	declare @temp table 
	(id int identity (1,1)
	,processId1 int,dbFreeSpace int, f_typeFile varchar(100), f_indication varchar(100), f_dbName varchar(100), f_serverName varchar(100)
	,processId2 int,growth int , g_typeFile varchar(100), g_indication varchar(100), g_dbName varchar(100), g_serverName varchar(100)
	,processId3 int,maxSize int , m_typeFile varchar(100), m_indication varchar(100), m_dbName varchar(100), m_serverName varchar(100)
	)
	insert @temp
		SELECT 
		f.processId1
		,f.dbFreeSpace  as dbFreeSpace
		, f.typeFile as volume
		,f.indication as indication
		, f.dbname as dbName
		,f.serverName as serverName
		,g.processId2
		 ,g.growth as growth
		,g.typeFile as volume
		,g.indication as indication
		, g.dbname as dbName
		, g.serverName as serverName
		,m.processId3
		 ,m.maxSize as maxSize
		,m.typeFile as volume
		,m.indication as indication
		, m.dbname as dbName
		, m.serverName as serverName
		from @tableFreeSpace f join @tempGrowth g on f.id = g.growthId join  @tempMaxSize m on m.maxSizeId = g.growthId

--select * from @temp


SELECT TOP 1 @id = id
		,@processType1 = processId1
		,@dbFreeSpace = dbFreeSpace
		,@typeFilefreeSpace = f_typeFile
		,@indicationfreeSpace = f_indication
		,@dbNamefreeSpace = f_dbName
		,@serverNamefreeSpace = f_serverName
		,@growthSpace = growth
		,@typeFilegrowth = g_typeFile
		,@indicationGrowth = g_indication
		,@dbNamegrowth = f_dbName
		,@serverNamegrowth = g_serverName
		,@maxSizeSpace = maxSize
		,@typeFilemaxsize = m_typeFile
		,@indicationmaxsize = m_indication
		,@dbNamemaxsize = m_dbName
		,@serverNamemaxsize = m_serverName
	FROM @temp

--select * from @temp

	while @id is not null
begin

	IF @dbFreeSpace < @threshold_warnning_Db   --espace libre db < au kpi  d'attention
	and @maxSizeSpace != -1   --taille fixe
	and  @growthSpace != 0  --autogrowth active
	and @dbFreeSpace/@growthSpace < @threshold_warnning_Growth 
	begin
		IF @dbFreeSpace < @threshold_urgent_Db  --espace free inférieur au kpi  d'urgence 
				and @maxSizeSpace != -1   --taille fixe
				and  @growthSpace != 0  --autogrowth active
				and @dbFreeSpace/@growthSpace < @threshold_urgent_Growth  
			BEGIN
					set  @emergencyMode = 'urgence'
					--message à envoyer
						set @urgentMessage = ' urgent: Low space db Notification. The following space of data base are currently reporting less than ' 
						+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
						+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

						--profil mail de notification
				 insert into dbo.alertSysteme
					(processId ,description ,processValue ,emergencyValue ,serverName ,dbName ,status ,message ,createDate )
				values
				(@processType1, @indicationfreeSpace, @dbFreeSpace ,@threshold_urgent_Db , @serverNamefreeSpace, @dbNamefreeSpace,   @emergencyMode, @urgentMessage, @emergencyDate)
			end
		else 
				BEGIN
					set @warningMode = 'attention'
					--message à envoyer
						set @warnningMessage  = ' warnning: Low space db Notification. The following space of data base are currently reporting less than ' 
						+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
						+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

				 insert into dbo.alertSysteme
					(processId ,description ,processValue ,WarnningValue ,serverName ,dbName ,status ,message ,createDate )
				values
				(@processType1, @indicationfreeSpace, @dbFreeSpace, @threshold_warnning_Db, @serverNamefreeSpace, @dbNamefreeSpace,  @warningMode, @warnningMessage, @warningDate)
		end
 end
else
begin
set @warningMode = 'ok'
set @warnningMessage  = ''
 insert into dbo.alertSysteme
  (processId ,description ,processValue ,serverName ,dbName  ,status ,message ,createDate)
values
(@processType1, @indicationfreeSpace , @dbFreeSpace, @serverNamefreeSpace, @dbNamefreeSpace,  @warningMode, @warnningMessage, @warningDate)
end

	--supréssion de l'id déja traité de la table 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

 --nouvelle selection de l'element a traité
		SELECT TOP 1 @id = id
		,@processType1 = processId1
		,@dbFreeSpace = dbFreeSpace
		,@typeFilefreeSpace = f_typeFile
		,@indicationfreeSpace = f_indication
		,@dbNamefreeSpace = f_dbName
		,@serverNamefreeSpace = f_serverName
		,@growthSpace = growth
		,@typeFilegrowth = g_typeFile
		,@indicationGrowth = g_indication
		,@dbNamegrowth = f_dbName
		,@serverNamegrowth = g_serverName
		,@maxSizeSpace = maxSize
		,@typeFilemaxsize = m_typeFile
		,@indicationmaxsize = m_indication
		,@dbNamemaxsize = m_dbName
		,@serverNamemaxsize = m_serverName
	FROM @temp

	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;

	--supression des table temporaire à la fin du traitement
	delete  @tableFreeSpace
	delete @tempGrowth
	delete @tempMaxSize

end
go
------------------------------------------------------------------------------------------------------------------------
use monitoring
go

create PROC     alert.proc_low_number_Of_Partion_at_the_end_type_table

   @thresholdWarnning int  -- number of qty under which to launch an  warnning alert
	,@thresholdUrgent int  -- number of qty under which to launch an  urgent alert
	,@thresholText varchar(100) = null


--cette proc signa le nombre de partition vide à la fin 
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 1
-- ### processTypeId: 1 
-- ### processGroupsId: 8
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 900
-- ### thresholText: none
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low number of partitions Alerts at the end
-- ### recipient: marceltsameza@gmail.com

AS
begin

	DECLARE 

	--@thresholdUrgent int = 900   -- 70 indique un seuil d'urgence 
	--,@thresholdWarnning int = 870 -- 100 indique un seuil d'avertissement 
	@availaiblePartition int 
	,@processName varchar(100)
	,@serverName varchar(100)
	,@dbName  varchar(100)
	,@objectIndication varchar(100)	
	,@id int
	,@processId int
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)
	,@warningMode varchar(50)
	,@emergencyMode varchar(50)
	,@warningDate datetime2(0) = getdate() 
	,@emergencyDate datetime2(0) = getdate()

	--table temporaire de reception des différents informations à analyser
	declare @temp table (
	id int identity (1,1)
	,processId int
	,processName varchar(100)
	,availaiblePartition int 
	,serverName varchar(100)
	,dbName  varchar(100)
	,objectIndication varchar(100)
	,createDate datetime2(0)	
		)

	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
	SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as tableName
		,m.value1  as availablePartition
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 25
		GROUP BY serverName
		)
		--where processId = 38
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate
		

SELECT TOP 1 @id = id
		,@processId = processId
		,@processName = processName
		,@availaiblePartition = availaiblePartition
		,@serverName = serverName
		,@dbName = dbName
		,@objectIndication = objectIndication
	FROM @temp

	--select * from @temp
	--boucle sur les différents données selectionnés pour verifier si une donnée corespond 
	-- au kpi fixé dans la table d'alerte
	while @id is not null
begin
--si la donnée est inferieur au KPI d'avertissement
	IF @availaiblePartition < @thresholdWarnning 
		begin
		if @availaiblePartition <  @thresholdUrgent
			BEGIN
				set @emergencyMode = 'urgence'
 	--formation du message 

				set @urgentMessage = ' Urgent Low number partitions Notification. The following number of partitions are currently reporting less than ' 
				+ CAST(@thresholdUrgent as varchar(12)) + ' in ' + @objectIndication +  'of the dataBase' +  @dbName + 'on server' + @serverName 

				--et envoie de l'arlerte au DBA
				insert into dbo.alertSysteme
				(processId ,description ,processValue ,emergencyValue ,serverName ,dbName , objectIndication ,status ,message ,createDate )
				values
				(@processId, @processName, @availaiblePartition ,@thresholdUrgent, @serverName, @dbName, @objectIndication, @emergencyMode, @urgentMessage, @emergencyDate) 
			end
	else  
				BEGIN
						set @warningMode = 'attention'
					--formation du message 

						set @warnningMessage = ' warnning Low number partitions Notification. The following number of partitions are currently reporting less than ' 
						+ CAST(@thresholdWarnning as varchar(12)) + ' in ' + @objectIndication +  'of the dataBase' +  @dbName + 'on server' + @serverName 
	
						--et envoie de l'arlerte au DBA
				insert into dbo.alertSysteme
				(processId ,description ,processValue ,WarnningValue ,serverName ,dbName , objectIndication ,status ,message ,createDate )
				values
				(@processId, @processName , @availaiblePartition ,@thresholdWarnning, @serverName, @dbName, @objectIndication, @warningMode, @warnningMessage, @warningDate)  
			end
	end
else
begin
set @warningMode = 'ok'
set @warnningMessage = ''
 insert into dbo.alertSysteme
(processId ,description, processValue ,serverName ,dbName , objectIndication ,status ,message ,createDate )
values
(@processId, @processName , @availaiblePartition, @serverName, @dbName, @objectIndication, @warningMode, @warnningMessage, @warningDate)  
end

--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
		,@processId = processId
		,@processName = processName
		,@availaiblePartition = availaiblePartition
		,@serverName = serverName
		,@dbName = dbName
		,@objectIndication = objectIndication
	FROM @temp
--dans ce cas plus de ligne 
	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
end
go
-------------------------------------------------------------------------------------------------------------------
use monitoring
go

create PROC     alert.proc_low_disk_space_per_cent_type_table

   @thresholdWarnning int  
	,@thresholdUrgent int 
	,@thresholText varchar(100) = null 



--cette proc signale en pourcentage l'espace disk restante
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 1
-- ### processTypeId: 1 
-- ### processGroupsId: 11
-- ### thresholdWarnning: 25
-- ### thresholdUrgent: 15
-- ### thresholText: none
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low percent disk space notification
-- ### recipient: marceltsameza@gmail.com

AS
begin

	DECLARE 
	 
	--@thresholdUrgent int = 15  --  un seuil d'urgence 
	--@thresholdWarnning int = 30 --  un seuil d'avertissement
	@percent_free_space_disk int 
	,@dataIndication varchar(100)
	, @serverName varchar(100)
	,@processName varchar(100)
	,@id int
	,@processId int
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)
	,@warningMode varchar(50)
	,@emergencyMode varchar(50)
	,@warningDate datetime2(0) = getdate() 
	,@emergencyDate datetime2(0) = getdate()

	--table temporaire de reception des différents informations à analyser
	declare @temp table (
		id int identity (1,1)
		,processId int
		,processName varchar(100)
		,serverName varchar(100)
		,dataIndication varchar(100)
		,free_space int
		,createDate datetime2(0)
		)

	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
		SELECT  
		m.processId
		,m.value4 as description
		,m.serverName as serverName
		,m.value3 as dataIndication
		,m.value1  as free_space
		,m.createDate
		from metrics m INNER JOIN
		(select serverName , MAX(createDate) AS maxDate
		from metrics 
		where processId = 38
		GROUP BY serverName
		)
		groupel ON m.serverName = groupel.serverName 
AND m.createDate = groupel.maxDate

SELECT TOP 1 @id = id
		,@processId = processId
		,@processName =  processName
		,@serverName = serverName
		,@dataIndication = dataIndication
		,@percent_free_space_disk = free_space
	FROM @temp

	select * from @temp
	--boucle sur les différents données selectionnés pour verifier si une donnée corespond 
	-- au kpi fixé dans la table d'alerte
	while @id is not null
begin
--si la donnée est inferieur au KPI d'avertissement
	IF @percent_free_space_disk < @thresholdWarnning 
	begin
		if @percent_free_space_disk < @thresholdUrgent
		begin
				set @emergencyMode = 'urgence'
 	--formation du message 

				set @urgentMessage = ' Urgent Low percent disk space notification. the disk space becomes less than' 
				+ CAST(@thresholdUrgent as varchar(12)) + ' in ' + @dataIndication + 'on server' + @serverName 
				insert into dbo.alertSysteme
				(processId ,description ,processValue ,emergencyValue ,serverName , objectIndication ,status ,message ,createDate )
				values
				(@processId, @processName, @percent_free_space_disk ,@thresholdUrgent , @serverName, @dataIndication ,@emergencyMode, @urgentMessage, @emergencyDate) 
		end 
	else  
					BEGIN
					--formation du message 
					set @warningMode = 'attention'
						set @warnningMessage = 'warnning Low per_cent disk space notification: the disk space becomes less than ' 
						+ CAST(@thresholdWarnning as varchar(12)) + ' in ' + @dataIndication +  'on server' + @serverName 
	
					insert into dbo.alertSysteme
				(processId ,description  ,processValue ,WarnningValue ,serverName, objectIndication ,status ,message ,createDate)
				values
				(@processId, @processName , @percent_free_space_disk ,@thresholdWarnning, @serverName, @dataIndication, @warningMode, @warnningMessage, @warningDate) 
		 end 
	end
	--si la donnée est inferieur au KPI d'urgence

else
begin
set @warningMode = 'ok'
set @warnningMessage = ''
 insert into dbo.alertSysteme
(processId ,description ,processValue ,serverName , objectIndication ,status ,message ,createDate )
values
(@processId, @processName , @percent_free_space_disk, @serverName, @dataIndication , @warningMode, @warnningMessage, @warningDate) 
end 

--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
		,@processId = processId
		,@processName =  processName
		,@serverName = serverName
		,@dataIndication = dataIndication
		,@percent_free_space_disk = free_space
	FROM @temp
--dans ce cas plus de ligne 
	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
end
go
---------------------------------------------------------------------------------------------------------------
USE [monitoring]
GO

create PROCEDURE [dbo].[proc_To_Call_alert_Process]
AS
BEGIN

--cette procedure fait une  execution de toute les procedures  d'alerting 

	DECLARE 
	@alertId int
 ,@alertProcessId int
 ,@processAlertName varchar(100)
 ,@thresholdWarnning int
 ,@thresholdUrgent int
 ,@thresholText  varchar(100)
 ,@strSql Nvarchar(max)
-----------------------------------------------------------
 ,@logDate DATETIME2(0)
---------------------------------------------------------------
--table temporaire pour la reception des différentes information provenat des la tables des alertes		
	DECLARE @T_Work TABLE (
		 alertId INT identity (1,1)
		,alertProcessId int
		,processAlertName varchar(100)
		,thresholdWarnning int
    ,thresholdUrgent int
    ,thresholText varchar(100)
   
		)
--insertion des données dans cette table 
	INSERT @T_Work 
--recherche des données dans la table des processalerts 
	SELECT 
		alertProcessId
		,processAlertName
		,thresholdWarnning
		,thresholdUrgent
		,thresholText
	FROM [alert].[alertProcess]
	where alertTypeId = 1

	--select * from @T_Work

	SELECT TOP 1 @alertId = alertId
	  ,@alertProcessId = alertProcessId
		,@processAlertName = processAlertName
		,@thresholdWarnning = thresholdWarnning
		,@thresholdUrgent = thresholdUrgent
		,@thresholText = thresholText
	FROM @T_Work
	ORDER BY alertId

	
	--  select * from @T_Work
--boucle sur chaque ligne des cette table pour executer les différentes procedures  qui s'y trouve
	WHILE @alertId IS NOT NULL
	BEGIN
	BEGIN TRY
			SET @logDate = GETDATE()
		
			SELECT @StrSql = @processAlertName + N' @thresholdWarnning , @thresholdUrgent, @thresholText';
         EXEC sp_executesql @strSql 
				 ,N'@thresholdWarnning int, @thresholdUrgent int, @thresholText varchar(100) '
				 ,@thresholdWarnning,@thresholdUrgent, @thresholText

	INSERT INTO [alert].[logProcessAlert](
	 alertProcessId
	,[logprocessAlertName] 
  ,logDate
	,isProcessError 
	,ErrorMessage 
)
			VALUES (
				@alertProcessId
				,@processAlertName
				,@logDate
				,1
				,ERROR_MESSAGE()
				)
END TRY
BEGIN CATCH
SET @logDate = GETDATE()
INSERT INTO [alert].[logProcessAlert](
	 alertProcessId
	,[logprocessAlertName] 
  ,logDate
	,isProcessError 
	,ErrorMessage 
)
			VALUES (
				@alertProcessId
				,@processAlertName
				,@logDate
				,0
				,ERROR_MESSAGE()
				)

END CATCH
--supression de la ligne déja traitée 
		DELETE
		FROM @T_Work
		WHERE alertId = @alertId
--selection d'une nouvelle ligne pour traitement
		SELECT TOP 1 @alertId = alertId
	  ,@alertProcessId = alertProcessId
		,@processAlertName = processAlertName
		,@thresholdWarnning = thresholdWarnning
		,@thresholdUrgent = thresholdUrgent
	FROM @T_Work
	ORDER BY alertId

		IF @@ROWCOUNT <= 0
			SET @alertId = NULL
	END;

END;
go


--***********************************************************************************************************************


--****************************************système d'insertion automatique des données dant la table alerteProcess*********
USE [monitoring];
GO
create proc   dbo.proc_to_generate_alert
as
begin
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

-- Table qui recevra les informations finales 
declare @temptable3 table  (
    alertId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
		,alertName varchar(200)
	 ,thresholdWarnning int 
   ,thresholdUrgent int
	 ,transmitter varchar(100)
	 ,subject varchar(200)
	 ,recipient varchar(100)
);
--DMV qui affiche les infos sur les noms des sp et noms de shémas d'une db spécifique
--------------------select * from   information_schema.routines

-- Liste des procedures de la base de donnée en ce qui concerne la collecte de donnés
INSERT @temptable0 (SPName)
select SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME
 from [monitoring].information_schema.routines
where routine_type = 'PROCEDURE'  and SPECIFIC_SCHEMA = 'alert'

SELECT @nbSP = COUNT(1) FROM @temptable0

WHILE @CountSP <= @nbSP 
BEGIN        
    
        SELECT @NameSP = SPName FROM @temptable0 WHERE rowid = @CountSP;

		--seront inserer ici les règles définies dans nos sp
        CREATE TABLE tempdb.dbo.temptable1  (
             text varchar(MAX) 
        );

	--les infos seront traitées de la tempdb.dbo.temptable1  et renvoyées dans cette table
          CREATE TABLE tempdb.dbo.temptable2  (
             rowid int IDENTITY(1,1),
             text varchar(255) 
        );

		--sp_helptext procédure système qui affiche la définition d'une règle définie par l'utilisateur
        SET @StrSQL = 'INSERT INTO tempdb.dbo.temptable1 EXEC (''sp_helptext ''''' + @NameSP + ''''''')';
        EXEC sp_executesql @StrSQL;

        INSERT INTO tempdb.dbo.temptable2
        SELECT
        CASE 
		  when text like '%### alertTypeId%' then REPLACE(text,'-- ### alertTypeId: ', '')
		  when text like '%### processTypeId%' then REPLACE(text,'-- ### processTypeId: ', '')
			when text like '%### processGroupsId%' then REPLACE(text,'-- ### processGroupsId: ', '')
			when text like '%### thresholdWarnning%' then REPLACE(text,'-- ### thresholdWarnning: ', '')
			when text like '%### thresholdUrgent%' then REPLACE(text,'-- ### thresholdUrgent: ', '')
			when text like '%### thresholText%' then REPLACE(text,'-- ### thresholText: ', '')
			when text like '%### transmitter%' then REPLACE(text,'-- ### transmitter: ', '')
			when text like '%### subject%' then REPLACE(text,'-- ### subject: ', '')
			when text like '%### recipient%' then REPLACE(text,'-- ### recipient: ', '')
		
            ELSE ''
            END AS DESCRIPTION  
        FROM tempdb.dbo.temptable1
        WHERE text LIKE '%###%';
		
        insert into [alert].[alertProcess](alertTypeId, processTypeId, processGroupsId, processAlertName, thresholdWarnning, thresholdUrgent, thresholText, transmitter, subject, recipient)
         SELECT
				(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 1) AS alertTypeId
				,(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 2) AS processTypeId
		    ,(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 3) AS processGroupsId
				,@NameSP
        ,(select cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 4) AS thresholdWarnning
        ,(SELECT cast(replace(replace(text, char(13), ''), char(10), '') as int) FROM tempdb.dbo.temptable2 WHERE rowid = 5) AS thresholdUrgent
				,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 6) AS thresholText
				,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 7) AS transmitter
				,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 8) AS subject
		    ,(SELECT text FROM tempdb.dbo.temptable2 WHERE rowid = 9) AS recipient

        DROP TABLE tempdb.dbo.temptable1;
        DROP TABLE tempdb.dbo.temptable2;
       
    SET @CountSP += 1;    
END;

--SELECT * from @temptable3

delete from @temptable0

end   
go            
--------------------------------------------------------------------------------------------------------------------------
 exec dbo.proc_to_generate_alert
-------------------------------------------------------------------------------------

--**************************************travail d'execution des différentes processus d'alerte*****************************

go
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'alert of type data')
EXEC msdb.dbo.sp_delete_job @job_name=N'alert of type data', @delete_unused_schedule=1
GO

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'alert of type data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'monitoring', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'alert of type data', @server_name = N'MARCELODJ'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'alert of type data', @step_name=N'table type', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[proc_To_Call_alert_Process]', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'alert of type data', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'monitoring', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'alert of type data', @name=N'type table', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=40, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180614, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

--*************************************************************************************************************************
USE [msdb]
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'ssis')
EXEC msdb.dbo.sp_delete_job @job_name=N'ssis', @delete_unused_schedule=1
GO

DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'ssis', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'monitoring', @job_id = @jobId OUTPUT
select @jobId
GO
DECLARE @instance varchar(50) = (SELECT CONVERT(sysname, SERVERPROPERTY('servername')));
EXEC msdb.dbo.sp_add_jobserver @job_name=N'ssis', @server_name = @instance
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'ssis', @step_name=N'ssis step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\monitor\monitoring\Package.dtsx\"" /SERVER MARCELODJ /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0,
		@proxy_name = N'SSISProxyDemo';
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ssis', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'monitoring', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'ssis', @name=N'schedul ssis', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=40, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180629, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO


--*************************************************************************************************************************
