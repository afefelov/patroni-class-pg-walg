#!/bin/bash
set -e
source /etc/container_environment.sh; wal-g backup-fetch /var/lib/postgresql/data LATEST