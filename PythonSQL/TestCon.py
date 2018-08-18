import pyodbc
conn = pyodbc.connect(
    'DRIVER={SQL Server};' 'Server=MARCELODJ;' 'Database=monitoring;' 'Trusted_Connection=yes')
cursor = conn.cursor()
cursor.execute(
    "select description, serverName, dbName, objectIndication, status, message ,max(createDate) as createDate from alertSysteme where serverName = 'MARCELODJ' group by description , serverName, dbName, objectIndication, status, message ")
for r in cursor:
    print("alertSysteme: {}".format(r))
