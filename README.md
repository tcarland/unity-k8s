Unity Catalog on K8s
=====================

While the Unity Catalog project is working on a Container build, there 
are currently some issues with the build process from that repository. 

Wanting to build out a deployment for testing Unity on Kubernetes, this 
repository was created to track the manifests and a *workable* container 
build for Unity Catalog.


## Deployment

The namespace is not created via the manifests as *Unity* needs
a database (MySQL or Postgres) configured. The deployment of this 
database is not currently covered by this repository and 
there is not a strict requirement that said database lives in the 
UnityCatalog's namespace. Currently, the setup defaults to using a mysql
instance as the backing database.

Create an environment configuration
```sh
cp env/env.template env/dev.env
```

Update the env config accordingly and run the setup script
```sh
source env/dev.env
./bin/unity-k8s-setup.sh
```

Deploy the manifests
```sh
kubectl create ns unity
kustomize build manifests/ | k apply -f -
```