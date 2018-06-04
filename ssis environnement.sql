--environnement d'execution ssis package server1

DECLARE @var sql_variant = N'monitoring'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'dbName'
, @sensitive=False
, @description=N''
, @environment_name=N'ssis'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'MARCELODJ\SERVER1'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'serverName', @sensitive=False
, @description=N''
, @environment_name=N'ssis'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO

Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] 
@environment_name=N'ssis'
, @environment_folder_name=N'monitor'
, @reference_id=@reference_id OUTPUT
, @project_name=N'monitoring'
, @folder_name=N'monitor'
, @reference_type=A
Select @reference_id

-----------------------------------------------------------------------------
--------------------------------------------------------------------------

--environnement d'execution ssis package server2
DECLARE @var sql_variant = N'monitoring'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'dbName'
, @sensitive=False
, @description=N''
, @environment_name=N'ssis2'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'MARCELODJ\SERVER2'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'serverName', @sensitive=False
, @description=N''
, @environment_name=N'ssis2'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO

Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] 
@environment_name=N'ssis2'
, @environment_folder_name=N'monitor'
, @reference_id=@reference_id OUTPUT
, @project_name=N'monitoring'
, @folder_name=N'monitor'
, @reference_type=A
Select @reference_id

------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--environnement d'execution ssis package server3

DECLARE @var sql_variant = N'monitoring'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'dbName'
, @sensitive=False
, @description=N''
, @environment_name=N'ssis3'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO
DECLARE @var sql_variant = N'MARCELODJ\SERVER3'
EXEC [SSISDB].[catalog].[create_environment_variable] 
@variable_name=N'serverName', @sensitive=False
, @description=N''
, @environment_name=N'ssis3'
, @folder_name=N'monitor'
, @value=@var, @data_type=N'String'
GO

Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] 
@environment_name=N'ssis3'
, @environment_folder_name=N'monitor'
, @reference_id=@reference_id OUTPUT
, @project_name=N'monitoring'
, @folder_name=N'monitor'
, @reference_type=A
Select @reference_id


