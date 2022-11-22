set -x #echo on
docker build ../ \
  --build-arg "ADAPTER_PACKAGE=dbt-postgres==1.3.1" \
  --build-arg "DBT_CORE_VERSION=1.3.1" \
  -t "dbt-runner-serverless\
:build-1.0.0\
-dbt-1.3.1\
-dbt-postgres-1.3.1"
