#!/usr/bin/env bash
#
# create the configmap from env secrets
#
binpath=$(dirname "$0")
setupdir=$(dirname "$(realpath "$binpath")")
version="v24.09.26"

tmpl="conf/unity-configmap-template.yaml"
cfg="manifests/base/unity-configmap.yaml"

UNITY_MYSQL_HOST="${UNITY_MYSQL_HOST:-mysql-service.unity.svc.cluster.local:3306}"
UNITY_MYSQL_DB="${UNITY_MYSQL_DB:-ucdb}"
UNITY_MYSQL_USER="${UNITY_MYSQL_USER:-uc_admin}"
UNITY_MYSQL_PASSWORD="${UNITY_MYSQL_PASSWORD}"
UNITY_S3_LOCATION="${UNITY_S3_LOCATION:-unity/uc}"


if [[ -z "$S3_ACCESS_KEY" || -z "$S3_SECRET_KEY" ]]; then
    echo "Error, missing S3 credentials."
    exit 1
fi
if [ -z "$UNITY_MYSQL_PASSWORD" ]; then
    echo "Error, UNITY_MYSQL_PASSWORD is unset"
    exit 1
fi
cd "$setupdir"
if [ $? -ne 0 ]; then
    echo "Error with path permissions in 'cd $setupdir'"
    exit 2
fi

export UNITY_MYSQL_HOST
export UNITY_MYSQL_DB
export UNITY_MYSQL_USER
export UNITY_MYSQL_PASSWORD
export UNITY_S3_LOCATION

echo " -> Creating ConfigMap from template '$cfg'"
( cat $tmpl | envsubst > $cfg )


exit $?
