#!/usr/bin/env bash
#
# create the configmap from env secrets
#
pname=${0##\/*}
binpath=$(dirname "$0")
setupdir=$(dirname "$(realpath "$binpath")")
version="v25.01.01-uc0.2.1"

tmpl="conf/unity-configmap-template-pg.yaml"
cfg="manifests/base/unity-configmap.yaml"

UNITY_DBHOST="${UNITY_DBHOST}"
UNITY_DBNAME="${UNITY_DBNAME:-ucdb}"
UNITY_DBUSER="${UNITY_DBUSER:-ucadmin}"
UNITY_DBPASS="${UNITY_DBPASS}"
UNITY_S3_BUCKET="${UNITY_S3_BUCKET}"

# ---------------------------------

if [[ -z "$S3_ACCESS_KEY" || -z "$S3_SECRET_KEY" ]]; then
    echo "$pname Error, missing S3 credentials."
    exit 1
fi
if [ -z "$UNITY_DBHOST" ]; then
    echo "$pname Error, UNITY_DBHOST is unset"
    exit 1
fi
if [ -z "$UNITY_DBPASS" ]; then
    echo "$pname Error, UNITY_DBPASS is unset"
    exit 1
fi
if [ -z "$UNITY_S3_BUCKET" ]; then
    echo "$pname Error, UNITY_S3_BUCKET is unset"
    exit 1
fi

cd "$setupdir"
if [ $? -ne 0 ]; then
    echo "$pname Error with path permissions in 'cd $setupdir'"
    exit 2
fi

export UNITY_DBHOST
export UNITY_DBNAME
export UNITY_DBUSER
export UNITY_DBPASS
export UNITY_S3_BUCKET

echo " -> Creating ConfigMap from template '$cfg'"
( cat $tmpl | envsubst > $cfg )


exit $?
