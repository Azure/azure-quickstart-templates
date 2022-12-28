#!/bin/bash
echo "deploy tutor"
#configure tutor
tutor local quickstart

read -p "what's your admin user email: " EMAIL
tutor local createuser --staff --superuser admin $EMAIL
echo "create admin user, can log in with email"


