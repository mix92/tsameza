use monitoring
go

create PROC     alert.proc_low_disk_space_per_cent

   @thresholdWarnning int  
	,@thresholdUrgent int  
	,@from varchar(100)
	,@subject varchar(100)
	,@to varchar(200)


--cette proc signale en pourcentage l'espace disk restante
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 2
-- ### thresholdWarnning: 25
-- ### thresholdUrgent: 15
-- ### thresholText: null
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low percent disk space notification
-- ### recipient: marceltsameza@gmail.com

AS
begin

	DECLARE 
	-- @thresholdWarnning int = 30 --  un seuil d'avertissement 
	--,@thresholdUrgent int = 15  --  un seuil d'urgence 
	--,@from varchar(50) = 'marceltsameza@gmail.com'
	--,@subject varchar(100) = 'Low percent disk space notification'
	--,@to varchar(50) = 'marceltsameza@gmail.com; tsamezamarcel@yahoo.fr'   --les personne à etre notifier 
	@percent_free_space_disk int 
	,@volume_mont_point varchar(100)
	, @indication varchar(100)
	, @serverName varchar(100)
	, @id int
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)

	--table temporaire de reception des différents informations à analyser
	declare @temp table (
		id int identity (1,1)
		,percent_free_space_disk int
		,volume_mont_point varchar(100)
		,indication varchar(100)
		,serverName varchar(100)
		)

	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
		SELECT 
		 value1  as free_space
		,value3 as volume_mont_point
		,value4 as indication
		,serverName as serverName
		from metrics
		where processId = 38
		group by value1, value3, value4, serverName


SELECT TOP 1 @id = id
		,@percent_free_space_disk = percent_free_space_disk
		,@volume_mont_point = volume_mont_point
		,@indication = indication
		,@serverName = serverName
	FROM @temp

	--select * from @temp
	--boucle sur les différents données selectionnés pour verifier si une donnée corespond 
	-- au kpi fixé dans la table d'alerte
	while @id is not null
begin
--si la donnée est inferieur au KPI d'avertissement
	IF @percent_free_space_disk < @thresholdWarnning   
	BEGIN
	--formation du message 

		set @warnningMessage = 'warnning Low per_cent disk space notification . the disk space becomes less than ' 
		+ CAST(@thresholdWarnning as varchar(12)) + ' in ' + @volume_mont_point +  'on server' + @serverName 
	
		--et envoie de l'arlerte au DBA

				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END


	--si la donnée est inferieur au KPI d'urgence
  if @percent_free_space_disk <  @thresholdUrgent
 BEGIN
 	--formation du message 

		set @urgentMessage = ' Urgent Low percent disk space notification. the disk space becomes less than' 
		+ CAST(@thresholdUrgent as varchar(12)) + ' in ' + @volume_mont_point + 'on server' + @serverName 

				--et envoie de l'arlerte au DBA
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @urgentMessage	
	END

--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
		,@percent_free_space_disk = percent_free_space_disk
		,@volume_mont_point = volume_mont_point
		,@indication = indication
		,@serverName = serverName
	FROM @temp
--dans ce cas plus de ligne 
	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
end

go



--******************************************************************************************************************

create PROC dbo.proc_freeSpaceDb_alerts_of_type_data
	
	@threshold_warnning_Db int
	,@threshold_urgent_Db int
	,@from varchar(100)
	,@subject varchar(100)
	,@to varchar(200)


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
-- ### alertTypeId: 2
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 870
-- ### thresholText: null
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low  database space nitification in file type data
-- ### recipient: marceltsameza@gmail.com
--*********************************************************************************
--declaration des variable de travail
--**********************************************************************************

	DECLARE 
	-- @threshold_warnning_Db int = 870 -- 100 space db
	@threshold_warnning_Growth int = 2   -- 70 space db
	--,@threshold_urgent_Db int = 870 -- 100 space db
	,@threshold_urgent_Growth int = 3   -- 70 space db
	--,@from varchar(50) = 'marceltsameza@gmail.com'
	--,@subject varchar(100) = 'Low  database space Alerts of datatype ROWS'
	--,@to varchar(50) = 'marceltsameza@gmail.com; tsamezamarcel@yahoo.fr'
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
	,@strsql Nvarchar(max)         --pour recherche de taille max de la db


	--table temporaire de reception des taille maximales de chaques db en ce qui concerne des fichiers data
		declare @tempMaxSize table 
	(maxSizeId int identity (1,1)
	, maxSize int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

insert @tempMaxSize
		SELECT 
		 max(value1)  as maxSize
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 39
		group by  value3, value4,  dbname, serverName

	--table temporaire de reception des element auto growth en ce qui concerne des fichiers data
		declare @tempGrowth table 
	(growthId int identity (1,1)
	, growth int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

insert @tempGrowth
		SELECT 
		 max(value1)  as growth
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 14
		group by  value3, value4,  dbname, serverName

	--table temporaire de reception des element e l'espace free db en ce qui concerne les fichiers data
	declare @tableFreeSpace table 
	(id int identity (1,1)
	, dbFreeSpace int
	, typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

	insert @tableFreeSpace
		SELECT  
		 max(value1)  as dbFreeSpace
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 11
		group by  value3, value4,  dbname, serverName

	
	--select * from metrics
	--table temporaire de jointure sur les trois tables precedente pour reception des  infos finales
	declare @temp table 
	(id int identity (1,1)
	,dbFreeSpace int, f_typeFile varchar(100), f_indication varchar(100), f_dbName varchar(100), f_serverName varchar(100)
	,growth int , g_typeFile varchar(100), g_indication varchar(100), g_dbName varchar(100), g_serverName varchar(100)
	,maxSize int , m_typeFile varchar(100), m_indication varchar(100), m_dbName varchar(100), m_serverName varchar(100)
	)
	insert @temp
		SELECT 
		 f.dbFreeSpace  as dbFreeSpace
		, f.typeFile as volume
		,f.indication as indication
		, f.dbname as dbName
		,f.serverName as serverName
		 ,g.growth as growth
		,g.typeFile as volume
		,g.indication as indication
		, g.dbname as dbName
		, g.serverName as serverName
		 ,m.maxSize as maxSize
		,m.typeFile as volume
		,m.indication as indication
		, m.dbname as dbName
		, m.serverName as serverName
		from @tableFreeSpace f join @tempGrowth g on f.id = g.growthId join  @tempMaxSize m on m.maxSizeId = g.growthId

SELECT TOP 1 @id = id
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
	BEGIN

	--message à envoyer
		DECLARE @warnningMessage varchar(500) = ' warnning: Low space db Notification. The following space of data base are currently reporting less than ' 
		+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
		+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

		--profil mail de notification
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END
 else IF @dbFreeSpace < @threshold_urgent_Db  --espace free inférieur au kpi  d'urgence 
	and @maxSizeSpace != -1   --taille fixe
	and  @growthSpace != 0  --autogrowth active
	and @dbFreeSpace/@growthSpace < @threshold_urgent_Growth  
	BEGIN

	--message à envoyer
		DECLARE @urgentMessage varchar(500) = ' urgent: Low space db Notification. The following space of data base are currently reporting less than ' 
		+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
		+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

		--profil mail de notification
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END

	--supréssion de l'id déja traité de la table 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

 --nouvelle selection de l'element a traité
		SELECT TOP 1 @id = id
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

--***********************************************************************************************************
go
use monitoring
go

create PROC  alert.proc_alert_express

   @thresholdWarnning int = null -- number of qty under which to launch an  warnning alert
	,@thresholdUrgent int   -- number of qty under which to launch an  urgent alert
	,@from varchar(100)
	,@subject varchar(100)
	,@to varchar(200)

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

-- ### alertTypeId: 2
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
--,@thresholdUrgent int = 0   --indique une option non activé sur une table 
	,@objectIndication varchar(100)
	,@description varchar(100)
	,@dbName  varchar(100)
	,@serverName varchar(100)
	, @id int
	, @statistiqueMessage varchar(500)
	,@mode varchar(100)
	--table temporaire de reception des différentes informations à analyser
	declare @temp table 
	(id int identity (1,1)
	,is_option int
	,objectIdication varchar(100)
	,description varchar(100)
	,dbName varchar(100)
	,serverName varchar(100) 
	)
	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
		SELECT 
		 value1 as is_statistique_option
		,value3  as objectIndication
		,value4  as description
		,dbName as db
		,serverName as serverName
		from dbo.metrics
		where processId in (41, 42, 43)

--select * from @temp
SELECT TOP 1 @id = id
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
		   set @statistiqueMessage = 'ugent Notification of  '+@description +':  The '+@description +' is desabled'+'  '
		 + ' in  '+ @objectIndication+'  ' +  'of the dataBase'+'  ' +  @dbName +'  '+ 'on server'+'  ' + @serverName
		 			EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body =  @statistiqueMessage
		 end

--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
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

--********************************************************************************************************************
go

use monitoring
go

create PROC     alert.proc_low_number_Of_Partion_at_the_end

   @thresholdWarnning int  -- number of qty under which to launch an  warnning alert
	,@thresholdUrgent int  -- number of qty under which to launch an  urgent alert
	,@from varchar(100)
	,@subject varchar(100)
	,@to varchar(200)

--cette proc signa le nombre de partition vide à la fin 
--********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 
-- 
--***********************************************************************************
--les données ci-desous seront inscrite automatiqement dans la table des alert par 
--conséquent il est tres importent  de respecter cette syntaxe 

--***********************************************************************************
-- ### alertTypeId: 2
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 900
-- ### thresholText: null
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low number of partitions Alerts at the end
-- ### recipient: marceltsameza@gmail.com

AS
begin

	DECLARE 
	-- @thresholdWarnning int = 870 -- 100 indique un seuil d'avertissement 
	--,@thresholdUrgent int = 900   -- 70 indique un seuil d'urgence 
	--,@from varchar(50) = 'marceltsameza@gmail.com'
	--,@subject varchar(100) = 'Low number of partitions Alerts at the end'
	--,@to varchar(50) = 'marceltsameza@gmail.com; tsamezamarcel@yahoo.fr'   --les personne à etre notifier 
	@availaiblePartition int 
	,@tableName varchar(100)
	, @indication varchar(100)
	, @dbName  varchar(100)
	, @serverName varchar(100)
	, @id int
	,@warnningMessage varchar(500)
	,@urgentMessage varchar(500)

	--table temporaire de reception des différents informations à analyser
	declare @temp table (
		id int identity (1,1)
		,availaiblePartition int
		,tableName varchar(100)
		,indication varchar(100)
		,dbName varchar(100)
		,serverName varchar(100)
		)

	insert @temp
	-- selection des données dans la tables des metrics pour les processID concerné
		SELECT 
		 value1  as availaiblePartition
		,value3 as tableName
		,value4 as indication
		,dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 25
		group by value1, value3, value4,  dbname, serverName


SELECT TOP 1 @id = id
		,@availaiblePartition = availaiblePartition
		,@tableName = tableName
		,@indication = indication
		,@dbName = dbName
		,@serverName = serverName
	FROM @temp

	--select * from @temp
	--boucle sur les différents données selectionnés pour verifier si une donnée corespond 
	-- au kpi fixé dans la table d'alerte
	while @id is not null
begin
--si la donnée est inferieur au KPI d'avertissement
	IF @availaiblePartition < @thresholdWarnning   
	BEGIN
	--formation du message 

		set @warnningMessage = ' warnning Low number partitions Notification. The following number of partitions are currently reporting less than ' 
		+ CAST(@thresholdWarnning as varchar(12)) + ' in ' + @tableName +  'of the dataBase' +  @dbName + 'on server' + @serverName 
	
		--et envoie de l'arlerte au DBA

				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END

	--si la donnée est inferieur au KPI d'urgence
 else if @availaiblePartition <  @thresholdUrgent
 BEGIN
 	--formation du message 

		set @urgentMessage = ' Urgent Low number partitions Notification. The following number of partitions are currently reporting less than ' 
		+ CAST(@thresholdUrgent as varchar(12)) + ' in ' + @tableName +  'of the dataBase' +  @dbName + 'on server' + @serverName 

				--et envoie de l'arlerte au DBA
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @urgentMessage	
	END

--supression  de la ligne déja traitée 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id
--selection d'une nouvelle ligne 
		SELECT TOP 1 @id = id
		,@availaiblePartition = availaiblePartition
		,@tableName = tableName
		,@indication = indication
		,@dbName = dbName
		,@serverName = serverName
	FROM @temp
--dans ce cas plus de ligne 
	IF @@ROWCOUNT <= 0
			SET @id = NULL
	END;
end

--****************************************************************************************************************
go

create PROC dbo.proc_freeSpaceDb_alerts_of_type_log
	
	@threshold_warnning_Db int
	,@threshold_urgent_Db int
	,@from varchar(100)
	,@subject varchar(100)
	,@to varchar(200)


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
-- ### alertTypeId: 2
-- ### thresholdWarnning: 870
-- ### thresholdUrgent: 870
-- ### thresholText: null
-- ### transmitter: marceltsameza@gmail.com
-- ### subject: Low space database nitification in data type log
-- ### recipient: marceltsameza@gmail.com
--*********************************************************************************
--declaration des variable de travail
--**********************************************************************************

	DECLARE 
	 --@threshold_warnning_Db int = 870 -- 100 space db
	@threshold_warnning_Growth int = 2   -- 70 space db
	--, @threshold_urgent_Db int = 870 -- 100 space db
	,@threshold_urgent_Growth int = 3   -- 70 space db
	--,@from varchar(50) = 'marceltsameza@gmail.com'
	--,@subject varchar(100) = 'Low  database space Alerts of datatype LOG'
	--,@to varchar(50) = 'marceltsameza@gmail.com; tsamezamarcel@yahoo.fr'
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
	,@strsql Nvarchar(max)         --pour recherche de taille max de la db


	--table temporaire de reception des taille maximales de chaques db en ce qui concerne des fichiers data
		declare @tempMaxSize table 
	(maxSizeId int identity (1,1)
	, maxSize int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

insert @tempMaxSize
		SELECT 
		 max(value1)  as maxSize
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 40
		group by  value3, value4,  dbname, serverName

	--table temporaire de reception des element auto growth en ce qui concerne des fichiers data
		declare @tempGrowth table 
	(growthId int identity (1,1)
	, growth int 
	,typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

insert @tempGrowth
		SELECT 
		 max(value1)  as growth
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 19
		group by  value3, value4,  dbname, serverName

	--table temporaire de reception des element e l'espace free db en ce qui concerne les fichiers data
	declare @tableFreeSpace table 
	(id int identity (1,1)
	, dbFreeSpace int
	, typeFile varchar(100)
	, indication varchar(100)
	, dbName varchar(100)
	, serverName varchar(100))

	insert @tableFreeSpace
		SELECT  
		 max(value1)  as dbFreeSpace
		, value3 as volume
		,value4 as indication
		, dbname as dbName
		, serverName as serverName
		from metrics
		where processId = 16
		group by  value3, value4,  dbname, serverName


	--select * from metrics
	--table temporaire de jointure sur les trois tables precedente pour reception des  infos finales
	declare @temp table 
	(id int identity (1,1)
	,dbFreeSpace int, f_typeFile varchar(100), f_indication varchar(100), f_dbName varchar(100), f_serverName varchar(100)
	,growth int , g_typeFile varchar(100), g_indication varchar(100), g_dbName varchar(100), g_serverName varchar(100)
	,maxSize int , m_typeFile varchar(100), m_indication varchar(100), m_dbName varchar(100), m_serverName varchar(100)
	)
	insert @temp
		SELECT 
		 f.dbFreeSpace  as dbFreeSpace
		, f.typeFile as volume
		,f.indication as indication
		, f.dbname as dbName
		,f.serverName as serverName
		 ,g.growth as growth
		,g.typeFile as volume
		,g.indication as indication
		, g.dbname as dbName
		, g.serverName as serverName
		 ,m.maxSize as maxSize
		,m.typeFile as volume
		,m.indication as indication
		, m.dbname as dbName
		, m.serverName as serverName
		from @tableFreeSpace f join @tempGrowth g on f.id = g.growthId join  @tempMaxSize m on m.maxSizeId = g.growthId

--select * from @temp


SELECT TOP 1 @id = id
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
	BEGIN

	--message à envoyer
		DECLARE @warnningMessage varchar(500) = ' warnning: Low space db Notification. The following space of data base are currently reporting less than ' 
		+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
		+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

		--profil mail de notification
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END
 else IF @dbFreeSpace < @threshold_urgent_Db  --espace free inférieur au kpi  d'urgence 
	and @maxSizeSpace != -1   --taille fixe
	and  @growthSpace != 0  --autogrowth active
	and @dbFreeSpace/@growthSpace < @threshold_urgent_Growth  
	BEGIN

	--message à envoyer
		DECLARE @urgentMessage varchar(500) = ' urgent: Low space db Notification. The following space of data base are currently reporting less than ' 
		+ CAST(@threshold_warnning_Db as varchar(12)) + ' in file type ' + @typeFilefreeSpace +  'of the dataBase' +  @dbNamefreeSpace + 'on server' + @serverNamefreeSpace 
		+ 'the data base will growth ' + CAST(@dbFreeSpace/@growthSpace as varchar(12)) + ' more times again'

		--profil mail de notification
				EXEC msdb.dbo.sp_send_dbmail 
						 @profile_name = 'marcelo DJ'
		        ,@recipients = @to
		        ,@subject = @subject
		        ,@body = @warnningMessage	
	END

	--supréssion de l'id déja traité de la table 
	DELETE TOP (1)
		FROM @temp
		WHERE id = @id

 --nouvelle selection de l'element a traité
		SELECT TOP 1 @id = id
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
--*******************************************************************************************************

--creation d'un job à des fins des gestion des alertes 

--creation d'un job à des fins des gestion des alertes 

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'gestion alert')
EXEC msdb.dbo.sp_delete_job @job_name=N'gestion alert', @delete_unused_schedule=1
GO

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'gestion alert', 
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
EXEC msdb.dbo.sp_add_jobserver @job_name=N'gestion alert', @server_name = @instance
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'gestion alert', @step_name=N'exec  process low number of partion at the end', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  alert.proc_low_number_Of_Partion_at_the_end  

870
, 900
,''marceltsameza@gmail.com''
,''Low number of partitions Alerts at the end''
, ''marceltsameza@gmail.com''', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'gestion alert', @step_name=N'process alert express', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  alert.proc_alert_express

0
, 0
,''marceltsameza@gmail.com''
,''express alert notification''
, ''marceltsameza@gmail.com''', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'gestion alert', @step_name=N'proc_freeSpaceDb_alerts_of_type_log', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.proc_freeSpaceDb_alerts_of_type_log
870
, 870
,''marceltsameza@gmail.com''
,''Low space database nitification in data type log''
, ''marceltsameza@gmail.com''', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'gestion alert', @step_name=N'proc_freeSpaceDb_alerts_of_type_data', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.proc_freeSpaceDb_alerts_of_type_data
870
, 870
,''marceltsameza@gmail.com''
,''Low space database nitification in file type data''
, ''marceltsameza@gmail.com''', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'gestion alert', @step_name=N'proc_low_disk_space_per_cent', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec alert.proc_low_disk_space_per_cent
25
, 15
,''marceltsameza@gmail.com''
,''Low per_cent disk space notification''
,''marceltsameza@gmail.com''', 
		@database_name=N'monitoring', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'gestion alert', 
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
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'gestion alert', @name=N'job schedul', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180614, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

--**********************************************************************************************************************