

# Pour activer l'environnement virtuel:
# /venv/Scripts/activate.bat

from flask import Flask, render_template, flash, redirect, url_for, request, session
import pyodbc
from datetime import datetime
from datetime import timedelta
import os
# conn = pyodbc.connect(
#     'DRIVER={SQL Server};' 'Server=MARCELODJ;' 'Database=monitoring;' 'Trusted_Connection=yes')
# cursor = conn.cursor()
# cursor.execute(
#     "select processId, description, serverName, dbName, objectIndication, status, message ,max(createDate) as createDate from alertSysteme where serverName = 'MARCELODJ' group by processId, description , serverName, dbName, objectIndication, status, message order by status desc ")
# for r in cursor:
#     pass
    # print("alertSysteme: {}".format(r))

app = Flask(__name__)

app.config['SECRTE_KEY'] = os.urandom(24)

@app.route("/")
def hello():
    return render_template('home.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')


@app.route('/dashboard')
def dashboard():
    conn = pyodbc.connect(
        'DRIVER={SQL Server};' 'Server=MARCELODJ;' 'Database=monitoring;' 'Trusted_Connection=yes')
    cursor = conn.cursor()
    cursor.execute(
        "select  A.description, A.dbName, A.objectIndication, A.status, message ,A.createDate ,A.processId from alertSysteme A INNER JOIN (select processId,  MAX(createDate) AS maxDate from alertSysteme GROUP BY processId) groupel ON A.processId = groupel.processId AND A.createDate = groupel.maxDate	where serverName = 'MARCELODJ'"
        )
    mainserver = cursor.fetchall()
    mainserver = list(mainserver)

    cursor.execute(
        "select  A.description, A.dbName, A.objectIndication, A.status, message ,A.createDate ,A.processId from alertSysteme A INNER JOIN (select processId,  MAX(createDate) AS maxDate from alertSysteme GROUP BY processId) groupel ON A.processId = groupel.processId AND A.createDate = groupel.maxDate	where serverName = 'MARCELODJ\SERVER1'"
        )
    serveur1 = cursor.fetchall()
    serveur1 = list(serveur1)
    cursor.close()

    return render_template('dashboard.html',mainserver=mainserver, serveur1=serveur1)

@app.route('/historique/<string:sn>/<string:pn>/<string:dbn>/<string:oi>/') #
def historique(sn,pn,dbn,oi):
    if len(oi)==1:
        oi = oi+':\\'
    if sn == "MS":
        Sname = 'MARCELODJ'
    if sn == "S1":
        Sname = 'MARCELODJ\SERVER1'

    query = "select  processValue, warnningValue, emergencyValue ,status ,createDate, processId from dbo.alertSysteme where serverName = ? and dbName = ? and description = ? and objectIndication = ? order by createDate desc"
    val = (Sname,dbn,pn,oi)
    if dbn=='None':
        query = "select  processValue, warnningValue, emergencyValue ,status ,createDate, processId from dbo.alertSysteme where serverName = ? and description = ? and objectIndication = ? order by createDate desc"
        val = (Sname,pn,oi)
    if oi=='None':
        query = "select  processValue, warnningValue, emergencyValue ,status ,createDate, processId from dbo.alertSysteme where serverName = ? and dbName = ? and description = ? and objectIndication is NULL order by createDate desc"
        val = (Sname,dbn,pn)

    conn = pyodbc.connect(
        'DRIVER={SQL Server};' 'Server=MARCELODJ;' 'Database=monitoring;' 'Trusted_Connection=yes')
    cursor = conn.cursor()
    cursor.execute(query,val)

    historique = cursor.fetchall()
    cursor.close()

    if len(historique)>0:

        return render_template('historique.html',n=len(historique),res=historique)
    else:
        return render_template('historique.html',n=0)

@app.route('/demo',methods=["GET","POST"])
def demo():
    if request.method == 'POST':
        processId = int(request.form['processId'])
        kpiValue = int(request.form['kpiValue'])
        objectIndication = request.form['objectIndication']
        processName = request.form['processName']
        unitMeasure = request.form['unitMeasure']
        dbName = request.form['dbName']
        serverName = request.form['serverName']
        # date = request.form['date']

        now = datetime.now()
        date = now + timedelta(seconds=30)



        conn = pyodbc.connect(
            'DRIVER={SQL Server};' 'Server=MARCELODJ\SERVER1;' 'Database=monitoring;' 'Trusted_Connection=yes')
        cursor = conn.cursor()
        query = "INSERT INTO [dbo].[metrics] ([processId] ,[value1] ,[value3] ,[value4] ,[unitMeasure], [dbName] ,[serverName] ,[createDate]) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        val = (processId,kpiValue,objectIndication,processName,unitMeasure,dbName,serverName,date)
        print(val)
        cursor.execute(query,val)
        conn.commit()
        cursor.close()
        # flash("Les données ont bien été insérées","success")
        return redirect(url_for('dashboard'))

    return render_template('demo.html')



if __name__ == "__main__":
    app.run(debug=True,host='127.0.0.1',port=50000)
