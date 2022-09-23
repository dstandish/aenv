# What the hell is this?

It's like, an immensely hackish version of breeze, for folks who want to avoid docker as much as possible.

Essentially it's just a way of modifying airflow environment variables to set up different configurations.

So for example if you want to use kubernetes executor with mysql backend and only example_bash_operator.py, you can enter this:

```bash
aenv --kubernetes --mysql --example-dag example_bash_operator.py
```

# Why?

For a while I was using lower-level helpers like `use-kubernetes-executor`, `use-mysql`, `use-example-dag` to accomplish the same thing.  But then I like to run scheduler in this pane, webserver in that pane, and I needed a way to set up the same configuration in both terminal sessions.  So I figured package them up in a utility so I can use a one-liner.

# Anything else?

Well, to use k8s executor locally with a virtualenv scheduler, you need to coordinate a few things.  You need to to get your dags in the image (ideally without rebuilding) and you need to get your logs out of the container.  To do this you create hostpath PVCs. In this repo we also include helpers to do this: `create-dags-volume` and `create-logs-volume`.

Read on for more details.

# Source `aenv.sh` into your shell

E.g. add this to `.zshrc`:

```shell
source ~/code/aenv/aenv.sh
```

# Create dags and logs volumes for k8s

```bash
create-dags-volume
create-logs-volume
```

# Settings

```bash
AIRFLOW_ROOT_DIR=$HOME/code/airflow
AIRFLOW_HOST_PATH_DAGS=$AIRFLOW_ROOT_DIR/airflow/example_dags
AIRFLOW_HOST_PATH_LOGS=$HOME/airflow/logs
```

You can override any of these by setting them before sourcing `aenv.sh`.

# Dependencies

## Database backends

Depending on which DB backend you want to use, it assumes they are configured with creds and locations as defined in `aenv.sh`.

## Docker images

Default assumption is that you want to use docker image local:latest.

You can change this with env vars or with helper `use-image some-image some-tag`.
