"""
WSGI config for {{ project_name }} project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/{{ docs_version }}/howto/deployment/wsgi/
"""
import sys
import os

APPS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), 'apps'))
if APPS_DIR not in sys.path:
    sys.path.insert(0, APPS_DIR)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mainsite.settings")

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()