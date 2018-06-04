Use [monitoring];
GO
 
BACKUP SERVICE MASTER KEY TO FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\myserviceMasterKey'
ENCRYPTION BY PASSWORD = 'password';



--RESTORE SERVICE MASTER KEY FROM FILE = 'path_to_file'   
--    DECRYPTION BY PASSWORD = 'password' 



OPEN MASTER KEY DECRYPTION BY PASSWORD = 'password'
BACKUP MASTER KEY TO FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\mydbmasterkey'
ENCRYPTION BY PASSWORD = 'password'



--RESTORE MASTER KEY FROM FILE = 'path_to_file'   
--    DECRYPTION BY PASSWORD = 'password'  
--    ENCRYPTION BY PASSWORD = 'password' 



BACKUP CERTIFICATE Cert_UserPasswd 
TO FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\mycerticate.cer'
WITH PRIVATE KEY(
  FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\mycertificateKey',
  ENCRYPTION BY PASSWORD = 'password'
);


--restore CERTIFICATE Cert_UserPasswd 
--FROM FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\mycerticate.cer'
--WITH PRIVATE KEY(
--  FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\mycertificateKey',
--  ENCRYPTION BY PASSWORD = 'CABR2lle'
--);



