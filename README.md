# What is this?

This repo is a tool intended for Airflow developers who prefer using virtualenv to docker.  It makes it easy to change your configuration from one executor or backend to another.

It's assumed that you already have the database backends running in your host machine.

If you just want to change one aspect of your configuration:

```bash
# change database backend
use-mysql
use-postgres
use-sqlite
use-mssql

# change dags folder
use-example-dag
use-dag

# change executor
use-local-executor
use-kubernetes-executor
use-sequential-executor
use-celery-executor
```

To change more than one attribute in one line, you can use the `aenv` command. For example, if you want to use kubernetes executor with mysql backend and only example_bash_operator.py, you can enter this:

```bash
aenv --kubernetes --mysql --example-dag example_bash_operator.py
```

This is helpful when you want to use the same configuration in multiple terminal windows.

To print your configuration:

```bash
# print relevant airflow env vars
echo-airflow-env
```

# Why?

As an Airflow developer, I frequently need to switch database backends and executors. I strongly prefer working in a virtualenv over docker because of the speed, lighter resource footprint, and better debugging. And I found these utilities very helpful for this kind of workflow.

The lower-level helpers like `use-mysql` and `use-sqlite` are great when you just want to change one aspect of your setup.  For setting up the same configuration in multiple terminal sessions, that's why the `aenv` wrapper exists.

# Installation

Add `aenv.sh` to your shell profile, e.g.:

```shell
source ~/code/aenv/aenv.sh
```

If your airflow repo is not located at `~/code/airflow`, set this var before sourcing `aenv.sh`:

```bash
export AIRFLOW_ROOT_DIR=/path/to/airflow-repo  # only need to set if different from ~/code/airflow
```

# Using k8s executor and KPO

To use k8s executor locally with a virtualenv scheduler, you need to coordinate a few things.  You need to to get your dags in the image (ideally without rebuilding) and you need to get your logs out of the container.  To do this you create hostpath persistent volumes, and we provide helper functions for this.

> **Note:** By default, the helpers will mount `~/airflow/logs` as the logs dir and `$AIRFLOW_ROOT_DIR/airflow/example_dags` as the dags folder.  But you can change this by setting variables `AIRFLOW_HOST_PATH_DAGS` and `AIRFLOW_HOST_PATH_DAGS` prior to sourcing `aenv.sh`.

To create the volumes and volume claims:

```bash
# create shared volumes for k8s executor and KPO
create-dags-volume
create-logs-volume

# you'll need to delete them and recreate if you want to change
delete-dags-volume
delete-logs-volume
```

The included `pod_template.yaml` references the PVCs so that you can share logs and dags between your k8s pods and your host.  Your environment will be configured to use this template file when you switch to kubernetes executor.  This lets you access your k8s task logs from your webserver (running on host in virtualenv).  And it lets you change dag code without rebuilding your image.

Other k8s helpers:

```bash
# switch the default image used for k8s executor
use-image  # default: `use-image local latest`

# remove up leftover pods
delete-pods-errored
delete-pods-completed
```

# Docker images

Default assumption is that you want to use docker image `local:latest`.

You can change this with env vars or with helper `use-image some-image some-tag` or just set the normal env vars.

# MSSQL

On a mac, it's easy enough to get mysql, postgres and sqlite installed and leave them running in the background on the host.

But to run MSSQL you need to run it in docker.  Included here is a function to spin up an instance for you:

```bash
# spins up a mssql container with port 1433 and admin password `$MSSQL_DEV_PASSWORD` (default: Abc123456)
# also uses a docker volume for persistent
start-mssql  
```
