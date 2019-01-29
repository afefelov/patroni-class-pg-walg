#!/bin/bash
set -e
source /etc/container_environment.sh
if [ ! -z "$WALE_S3_PREFIX" ]; then
    wal-g wal-push /var/lib/postgresql/data/$1  > /dev/null 2>&1
fi
