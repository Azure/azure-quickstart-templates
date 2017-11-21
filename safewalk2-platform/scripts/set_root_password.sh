#!/bin/bash

usermod --password $(echo $1 | openssl passwd -1 -stdin) root

