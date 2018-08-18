--Pour activer le courrier de la base de données, exécutez le code suivant

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
 
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO




-- Creation d'un profil mail  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'marcelo DJ',  
    @description = 'Profile used for sending outgoing notifications using Gmail.' ;  
GO

-- Accorder l'accès au profil au rôle DBMailUsers 
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'marcelo DJ',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

-- Créer un compte de messagerie de base de données
-- on peut associent un compte à plusieur profil  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'ARMAND TSAMEZA',  
    @description = 'Mail account for sending outgoing notifications.',  
    @email_address = 'marceltsameza@gmail.com',  
    @display_name = 'Automated Mailer',  
    @mailserver_name = 'smtp.gmail.com',
    @port = 587,
    @enable_ssl = 1,
    @username = 'marceltsameza@gmail.com',
    @password = 'cabrelle' ;  
GO

-- Ajouter le compte au profil  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'marcelo DJ',  
    @account_name = 'ARMAND TSAMEZA',  
    @sequence_number =1 ;  
GO


--**********************************en cas d'erreur supprimer avec ca*************************************************************************
--	EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'Notifications'
--EXECUTE msdb.dbo.sysmail_delete_principalprofile_sp @profile_name = 'Notifications'
--EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'Gmail'
--EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'Notifications'
--*****************************************************************************************************************

--email de test   qui ne fonctionne pas 
--par conséquent suivez les instruction du lien ci-desous pour pour la confing de votre client mail

--https://www.sqlshack.com/configure-database-mail-sql-server/  (database mail pour GMAIL)
--https://be.aide.yahoo.com/kb/SLN4075.html   (database mail pour yahoo)
EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'marcelo DJ',
     @recipients = 'marceltsameza@gmail.com',
     @body = 'The database mail configuration was completed successfully.',
     @subject = 'Automated Success Message';
GO






