#!/bin/sh
source ./venv/bin/activate
export FLASK_APP=webApp.py
flask db migrate
flask db upgrade
exec gunicorn -b :5000 --access-logfile - --error-logfile - webApp:app

