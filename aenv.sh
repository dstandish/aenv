# Two important variables that you can modify:
#     - AIRFLOW_ROOT_DIR: the folder where your airflow repo lives; defaults to ~/code/airflow.
#     - AIRFLOW_HOST_PATH_DAGS: defaults to airflow/example_dags
#     - AIRFLOW_HOST_PATH_LOGS: defaults to ~/airflow/logs


DEFAULT_AIRFLOW_ROOT_DIR="$HOME/code/airflow"
export AIRFLOW_ROOT_DIR="${AIRFLOW_ROOT_DIR:="$DEFAULT_AIRFLOW_ROOT_DIR"}"
DEFAULT_AIRFLOW_HOST_PATH_DAGS="$AIRFLOW_ROOT_DIR/airflow/example_dags"
export AIRFLOW_HOST_PATH_DAGS="${AIRFLOW_HOST_PATH_DAGS:="$DEFAULT_AIRFLOW_HOST_PATH_DAGS"}"
MSSQL_DEV_PASSWORD=Abc123456
AENV_DIR="$(dirname $0)"


export AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY="${AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY:=local}"
export AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG="${AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG:=latest}"

export AIRFLOW_HOST_PATH_LOGS="${AIRFLOW_HOST_PATH_LOGS:=$HOME/airflow/logs}"

mkdir -p "$AIRFLOW_HOST_PATH_LOGS"

export AIRFLOW__DEBUG__FAIL_FAST=True
export AIRFLOW__API__AUTH_BACKENDS='airflow.api.auth.backend.default'
export AIRFLOW__CORE__ENABLE_XCOM_PICKLING=False
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False
export AIRFLOW__WEBSERVER__EXPOSE_CONFIG=TRUE
export AIRFLOW__WEBSERVER__WORKERS=1



function use-mysql() {
  DB=${1:-testing}  
  export AIRFLOW__CORE__SQL_ALCHEMY_CONN=mysql+mysqldb://root@localhost/$DB
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  export AIRFLOW__CELERY__RESULT_BACKEND="db+$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  echo-db
}

function use-mariadb() {
  DB=${1:-testing}  
  export AIRFLOW__CORE__SQL_ALCHEMY_CONN=mariadb+mysqldb://root@127.0.0.1:3307/$DB
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  export AIRFLOW__CELERY__RESULT_BACKEND="db+$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  echo-db
}

function use-mssql() {
  DB=${1:-testing}  
  export AIRFLOW__CORE__SQL_ALCHEMY_CONN="mssql+pyodbc://sa:$MSSQL_DEV_PASSWORD@localhost:1433/$DB?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=No"
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  export AIRFLOW__CELERY__RESULT_BACKEND="db+$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  echo-db
}

echo-db() {
  echo "setting db to $AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
}

function use-postgres() {
  DB=${1:-testing}  
  export AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql://@localhost/$DB
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  export AIRFLOW__CELERY__RESULT_BACKEND="db+$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
  echo-db
}

function use-sqlite() {
  unset AIRFLOW__CORE__SQL_ALCHEMY_CONN
  unset AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
  unset AIRFLOW__CELERY__RESULT_BACKEND
}

use-airflow-schema() {
  export AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA='airflow'
}

unset-airflow-schema() {
  unset AIRFLOW__DATABASE__SQL_ALCHEMY_SCHEMA
}

use-celery-executor() {
  export AIRFLOW__CORE__EXECUTOR=CeleryExecutor
  echo "Using $AIRFLOW__CORE__EXECUTOR"
}

use-image() {
  export AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY="${1-"local"}"
  export AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG="${2-"latest"}"
  echo "Configured image $AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY:$AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG"
}

use-kubernetes-executor() {
  export AIRFLOW__KUBERNETES_EXECUTOR__IN_CLUSTER=False
  export AIRFLOW__CORE__EXECUTOR=KubernetesExecutor
  export AIRFLOW__KUBERNETES_EXECUTOR__POD_TEMPLATE_FILE="$AENV_DIR/pod_template.yaml"
  # export AIRFLOW__LOGGING__BASE_LOG_FOLDER="$AIRFLOW_HOST_PATH_LOGS"
  echo ""
  echo "using kubernetes executor"
  echo "    - template file: $AIRFLOW__KUBERNETES_EXECUTOR__POD_TEMPLATE_FILE"
  echo "    - image: $AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY:$AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG"
}

use-local-executor() {
  export AIRFLOW__CORE__EXECUTOR=LocalExecutor
  echo "Using $AIRFLOW__CORE__EXECUTOR"
}
use-sequential-executor() {
  export AIRFLOW__CORE__EXECUTOR=SequentialExecutor
  echo "Using $AIRFLOW__CORE__EXECUTOR"
}

echo-airflow-env() {
  ignore_val=(
    "AIRFLOW_CONN_SNOWFLAKE_DEFAULT"
    "AIRFLOW__API__AUTH_BACKENDS"
    "AIRFLOW__CELERY__RESULT_BACKEND"
    "AIRFLOW__CORE__ENABLE_XCOM_PICKLING"
    "AIRFLOW__CORE__FERNET_KEY"
    "AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS"
    "AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS"
    "AIRFLOW__CORE__LOAD_EXAMPLES"
    "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
    "AIRFLOW__DB__SQL_ALCHEMY_CONN"
    "AIRFLOW__DEBUG__FAIL_FAST"
    "AIRFLOW__WEBSERVER__EXPOSE_CONFIG"
    "AIRFLOW__WEBSERVER__WORKERS"
  )
  ignore_val_str=${(j:|:)ignore_val}
  echo "Current airflow env:"
  env \
    | grep AIR \
    | grep -v _tmp__ \
    | sort \
    | egrep -v $(echo $ignore_val_str) \
    | sed 's/^/    /'
}


use-dag() {
  export AIRFLOW__CORE__DAGS_FOLDER=$1
  echo "setting dags folder to $AIRFLOW__CORE__DAGS_FOLDER"
}

use-example-dag() {
  export AIRFLOW__CORE__DAGS_FOLDER=$AIRFLOW_ROOT_DIR/airflow/example_dags/$1
  echo "setting dags folder to $AIRFLOW__CORE__DAGS_FOLDER"
}


AENV_REPO_DIR="$(dirname $0)"

create-dags-volume() {
  # echo "$(envsubst )" | kubectl apply -f -
  echo "$(envsubst < "$AENV_REPO_DIR/volumes-dags.yaml")" | kubectl apply -f -
}

delete-dags-volume() {
  # echo "$(envsubst )" | kubectl apply -f -
  echo "$(envsubst < "$AENV_REPO_DIR/volumes-dags.yaml")" | kubectl delete -f -
}

create-logs-volume() {
  # echo "$(envsubst )" | kubectl apply -f -
  echo "$(envsubst < "$AENV_REPO_DIR/volumes-logs.yaml")" | kubectl apply -f -
}

delete-logs-volume() {
  # echo "$(envsubst )" | kubectl apply -f -
  echo "$(envsubst < "$AENV_REPO_DIR/volumes-logs.yaml")" | kubectl delete -f -
}

aenv() {
  POSITIONAL_ARGS=()
  venv_name="local"
  while [[ $# -gt 0 ]]; do
    case $1 in
      --mysql)
        use-mysql
        shift
        ;;
      --postgres)
        use-postgres
        shift
        ;;
      --sqlite)
        use-sqlite
        use-sequential-executor
        shift
        ;;
      --mssql)
        use-mssql
        shift
        ;;
      --example-dag)
        use-example-dag "$2"
        shift
        shift
        ;;
      --dag)
        use-dag "$2"
        shift
        shift
        ;;
      --local)
        use-local-executor
        shift
        ;;
      --kubernetes)
        use-kubernetes-executor
        shift
        ;;
      --sequential)
        use-sequential-executor
        shift
        ;;
      --celery)
        use-celery-executor
        shift
        ;;
      --venv)
        venv_name="$2"
        shift
        shift
        ;;
      -*|--*)
        echo "Unknown option $1"
        break
        ;;
      *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        echo "Unknown positional arg $1"
        shift
        ;;
    esac
  done
  echo "activating virtualenv $venv_name"
  workon "$venv_name"
  echo ""
  echo-airflow-env
}


alias delete-pods-errored="kgp | grep -v NAME | grep Error | cut -d ' '  -f1 | xargs -I {} kubectl delete pod {}"
alias delete-pods-completed="kgp | grep -v NAME | grep Completed | cut -d ' '  -f1 | xargs -I {} kubectl delete pod {}"
alias delete-pods-terminating="kgp | grep -v NAME | grep Terminating | cut -d ' '  -f1 | xargs -I {} kubectl delete pod {}"

alias echo-pods-errored="kgp | grep -v NAME | grep Error | cut -d ' '  -f1"
alias echo-pods-completed="kgp | grep -v NAME | grep Completed | cut -d ' '  -f1"
alias echo-pods-terminating="kgp | grep -v NAME | grep Terminating | cut -d ' '  -f1"



start-mssql() {
  docker run -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=$MSSQL_DEV_PASSWORD" \
    -p 1433:1433 \
    -v mssql:/var/opt/mssql/data mcr.microsoft.com/mssql/server:2017-latest
}
