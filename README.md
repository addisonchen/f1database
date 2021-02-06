The front end of the project is a Flask web application. The back end is a MySQL database. The project uses python 3.7.1 and Flask version 1.1.1. In addition to flask, the web application uses the libraries pymysql, random, flask_wtf, and wtforms. 
“pip install flask-wtf” will install both the flask_wtf and wtforms libraries. 
“pip install flask” will install the flask library.
“python3 -m pip install PyMySQL” will install the pymysql library.

The file structure of the flask application:

FLASK_F1:
run.py
flaskf1:
static
templates
dbhandler.py
forms.py
router.py

To set up the database, get the “schemamaker.sql” file from the static folder. Run this file in MySQLWorkbench in a local instance on port 3306. This will create a database named “formula1” with the necessary tables, procedures, functions, and sample data.

To run the flask web application, open a terminal and navigate into the FLASK_F1 directory. In the command line run “export FLASK_APP=run.py” then “flask run”. Open a browser and go to the url “http://localhost:5000/”. Under “Connect a database” click the button “connect”. This will direct the user to a login page. Enter the password for the root user and click “connect”.

The application is now running and connected to the local formula1 database. Navigate to “teams”, “drivers”, or “raw data” to see charts, graphs, and tables with sample data. Click on “modify data” to choose between adding, deleting, and modifying data from the database.
