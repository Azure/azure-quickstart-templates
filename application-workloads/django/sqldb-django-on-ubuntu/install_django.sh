#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update && sudo apt-get upgrade -y

# Install pip
apt-get -y install python3-pip

# Install Django
pip3 install Django

# Install database packages
apt-get install -y freetds-dev freetds-bin
pip3 install pymssql

# Install Apache
apt-get install -y apache2 libapache2-mod-wsgi-py3

# create a django app
cd /var/www
django-admin startproject helloworld

# Create a new file named views.py in the /var/www/helloworld/helloworld directory. This will contain the view
# that renders the "hello world" page
echo "from django.http import HttpResponse
from django.shortcuts import render
from django.http import HttpRequest
from django.template import RequestContext
from datetime import datetime
import pymssql


def contact(request):
    html = '<html><body>Contact</body><html>'
    return HttpResponse(html)


def about(request):
    html = '<html><body>About</body><html>'
    return HttpResponse(html)


def home(request):
    conn = pymssql.connect(server='$2.database.windows.net',user='$3@$2', password='$4', database='$5')
    cursor = conn.cursor()
    cursor.execute(\"IF OBJECT_ID('votes', 'U') IS NOT NULL DROP TABLE votes\")
    cursor.execute(\"CREATE TABLE votes ( name VARCHAR(100), value INT NOT NULL, PRIMARY KEY(name))\")
    cursor.executemany(
        \"INSERT INTO votes VALUES (%s, %d)\",
        [('NodeJS', '2'),
         ('Python', '33'),
         ('C#', '2')])
    # you must call commit() to persist your data if you don't set autocommit to True
    conn.commit()
    cursor.execute('SELECT * FROM votes')

    result = '<table style=\"width:100%\">'
    row = cursor.fetchone()
    while row:
        result += f'<tr><th>{row[0]}: {row[1]} votes</th></tr>'
        row = cursor.fetchone()
    result += '</table>'
    html = f'<html><body>{result}</body><html>'
    return HttpResponse(html)" | tee /var/www/helloworld/helloworld/views.py

# Update urls.py
echo "from django.urls import path
from helloworld import views
urlpatterns = [
    path('contact/', views.contact, name='contact'),
    path('about/', views.about, name='about'),
    path('', views.home, name='home'),
]" | tee /var/www/helloworld/helloworld/urls.py

sed -i "s|ALLOWED_HOSTS = \[\]|ALLOWED_HOSTS = \['*'\]|" /var/www/helloworld/helloworld/settings.py

# Apache Config
echo "<VirtualHost *:80>
ServerName $1
</VirtualHost>
WSGIScriptAlias / /var/www/helloworld/helloworld/wsgi.py
WSGIPythonPath /var/www/helloworld" | tee /etc/apache2/sites-available/helloworld.conf

# Enable Site
a2ensite helloworld

# Restart Apache
service apache2 reload
