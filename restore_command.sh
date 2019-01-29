#!/bin/bash
set -e
source /etc/container_environment.sh; wal-g wal-fetch $1 $2  > /dev/null 2>&1