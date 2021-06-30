#! /usr/bin/env python

# Copyright (c) 2016 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Simple script that shows how to use the Cloudera Director API to initialize
# the environment and instance templates

from urllib2 import HTTPError
from cloudera.director.latest.models import Login, User
from cloudera.director.common.client import ApiClient
from cloudera.director.latest import AuthenticationApi, UsersApi
import sys
import logging

# logging starts
logging.basicConfig(filename='/var/log/cloudera-azure-initialize.log', level=logging.DEBUG)
logging.info('started')


class ExitCodes(object):
    """
    Exit code definition
    """
    OK = 0
    ERROR = 1


def prepare_user(username, password):
    """
    Create a new user account (admin) for Cloudera Director Server
    :param username: Username for the new account
    :param password: Password for the new account
    :return:         API exit code
    """
    # Cloudera Director server runs at http://127.0.0.1:7189
    try:
        logging.info('Creating new admin user for Cloudera Director Server')
        client = ApiClient("http://localhost:7189")
        AuthenticationApi(client).login(
            Login(username="admin", password="admin"))  # create new login base on user input
        users_api = UsersApi(client)
        # Admin user by default has both roles
        users_api.create(User(username=username, password=password, enabled=True,
                              roles=["ROLE_ADMIN", "ROLE_READONLY"]))

        logging.info('Successfully created new admin user %s.' % dirUsername)
    except HTTPError, e:
        logging.error("Failed to create user '%s'. %s" % (username, e.msg))
        return ExitCodes.ERROR

    # delete existing admin user using the new account
    try:
        logging.info("Deleting default user 'admin' for Cloudera Director Server")
        client = ApiClient("http://localhost:7189")
        AuthenticationApi(client).login(Login(username=username, password=password))
        users_api = UsersApi(client)
        users_api.delete("admin")

        logging.info("Successfully deleted default user 'admin'")
        return ExitCodes.OK
    except HTTPError, e:
        logging.error("Failed to delete default user 'admin'. %s" % e.msg)
        return ExitCodes.ERROR

dirUsername = sys.argv[1]
dirPassword = sys.argv[2]

sys.exit(prepare_user(dirUsername, dirPassword))
