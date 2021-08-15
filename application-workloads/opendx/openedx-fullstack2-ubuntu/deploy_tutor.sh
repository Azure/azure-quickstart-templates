#!/bin/bash
echo "deploy tutor"
#configure tutor
tutor local quickstart

echo "create admin user, can log in with edx@example.com"
tutor local createuser --staff --superuser admin edx@example.com


