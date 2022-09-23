# Usage

Use kubernetes executor with mysql backend and only example_bash_operator.py

```bash
aenv --kubernetes --mysql --example-dag example_bash_operator.py
```

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
