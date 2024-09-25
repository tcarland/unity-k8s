Unity Catalog on K8s
=====================

While the Unity Catalog project is working on a Container build, there 
are currently some issues with the build process from that repository. 

Wanting to build out a deployment for testing Unity on Kubernetes, this 
repository was created to track the manifests and a *workable* container 
build for Unity Catalog.


## Deployment

The namespace is not created via the manifests as the deployment needs
a database (MySQL or Postgres) configured via the *ConfigMap* template.
The deployment of this database is not currently covered by this repo and 
there is not a strict requirement that said database lives in the 
UnityCatalog's namespace. Currently, the setup defaults to using a mysql
instance as the backing database.

Run the setup script
```sh
export UNITY_MYSQL_HOST="mysql-service.unity.svc.cluster.local:3306"
export UNITY_MYSQL_DB="ucdb"
export S3_ACCESS_KEY="myaccesskey"
export S3_SECRET_KEY="mysecretkey"
./bin/unity-k8s-setup.sh
```

Deploy the manifests
```sh
kubectl create ns unity
kustomize build manifests/ | k apply -f -
```