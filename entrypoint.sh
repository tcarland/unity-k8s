#!/usr/bin/env bash
#
SERVER_CLASS_NAME="io.unitycatalog.server.UnityCatalogServer"
UNITY_USER_NAME="unity"
UNITY_HOME="/opt/unitycatalog"

set -ex
uid=$(id -u)
gid=$(id -g)
set +e
uidentry=$(getent passwd $uid)
set -e

# If there is no passwd entry for the container UID, attempt to create one
if [ -z "$uidentry" ] ; then
    if [ -w /etc/passwd ] ; then
        echo "$uid:x:$uid:$gid:${UNITY_USER_NAME:-anonymous uid}:$UNITY_HOME:/bin/false" >> /etc/passwd
    else
        echo "Container ENTRYPOINT failed to add passwd entry for anonymous UID"
    fi
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | awk '{print $3}')
fi

cd /opt/unitycatalog
exec java -cp "jars/classes:jars/*" ${SERVER_CLASS_NAME} $@
