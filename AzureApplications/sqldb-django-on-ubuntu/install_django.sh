#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y update

# install Python
sudo apt-get -y install python-setuptools

# install DJango
sudo easy_install django

sudo apt-get -y install freetds-dev freetds-bin
sudo apt-get -y install python-dev python-pip
sudo pip install pymssql
# install Apache
sudo apt-get -y install apache2 libapache2-mod-wsgi

# create a django app
cd /var/www
sudo django-admin startproject helloworld

# Create a new file named views.py in the /var/www/helloworld/helloworld directory. This will contain the view
# that renders the "hello world" page
echo "from django.http import HttpResponse
from django.shortcuts import render
from django.http import HttpRequest
from django.template import RequestContext
from datetime import datetime
import pymssql
def contact(request):
    html = '<html><body>Hsello World!</body><html>'
    return HttpResponse(html)
def about(request):
    html = '<html><body>Hsello World!</body><html>'
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
    html = '<html><body>New World!</body><html>'
    cursor.execute('SELECT * FROM votes')
    result = ''
    row = cursor.fetchone()
    
    while row:
        result += str(row[0]) + str(' : ') + str(row[1]) + str('votes')
        
        row = cursor.fetchone()
    html ='<html><body><h2><pre>'
    html+= str(result)
    return HttpResponse(html)" | sudo tee /var/www/helloworld/helloworld/views.py


# Update urls.py
echo "from django.conf.urls import patterns, url
urlpatterns = patterns('',
    url(r'^$', 'helloworld.views.home', name='home'),
    url(r'^contact$', 'helloworld.views.contact', name='contact'),
    url(r'^about$', 'helloworld.views.about', name='about'),
)" | sudo tee /var/www/helloworld/helloworld/urls.py

# Setup Apache
echo "<VirtualHost *:80>
ServerName $1
</VirtualHost>
WSGIScriptAlias / /var/www/helloworld/helloworld/wsgi.py
WSGIPythonPath /var/www/helloworld" | sudo tee /etc/apache2/sites-available/helloworld.conf

#enable site
sudo a2ensite helloworld

#restart apache
sudo service apache2 reload