#!/bin/bash
set -e
chmod 777 /etc/container_environment.sh
gosu postgres patroni /var/lib/postgresql/patroni.yml