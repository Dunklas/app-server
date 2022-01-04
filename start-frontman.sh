#!/bin/bash

cd /tmp
git clone --branch certbot git@github.com:Dunklas/frontman.git
cp servers.json frontman/servers.json

cd frontman
make stop
make certbot
make start
