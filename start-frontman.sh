#!/bin/bash

cd /tmp
git clone git@github.com:Dunklas/frontman.git
cp servers.json /tmp/frontman/servers.json

cd frontman
make stop
make certbot
make start
