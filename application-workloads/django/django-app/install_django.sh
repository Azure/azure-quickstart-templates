#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get -y update

# install Python
apt-get -y install python3-pip

# install DJango
python3 -m pip install django

# install Apache
apt-get -y install apache2 libapache2-mod-wsgi-py3

# create a django app
cd /var/www
django-admin startproject helloworld

# Create a new file named views.py in the /var/www/helloworld/helloworld directory. This will contain the view
# that renders the "hello world" page
#echo "from django.http import HttpResponse
#def index(request):
#    return HttpResponse('Hello, world.')" | tee /var/www/helloworld/helloworld/views.py

# Update urls.py
#echo "from django.conf.urls import url
#from . import views

#urlpatterns = [
#    url('', views.index, name='index'),
#]" | tee /var/www/helloworld/helloworld/urls.py

sed -i "s|ALLOWED_HOSTS = \[\]|ALLOWED_HOSTS = \['*'\]|" /var/www/helloworld/helloworld/settings.py

# Setup Apache
echo "<VirtualHost *:80>
ServerName $1
</VirtualHost>
WSGIScriptAlias / /var/www/helloworld/helloworld/wsgi.py
WSGIPythonPath /var/www/helloworld" | tee /etc/apache2/sites-available/helloworld.conf

#enable site
a2ensite helloworld

#restart apache
service apache2 reload
