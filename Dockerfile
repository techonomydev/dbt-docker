FROM python:3.10-slim-bullseye as python-base

# python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt install git -y

# `builder-base` stage is used to build deps + create our virtual environment
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for building python deps
        build-essential

WORKDIR $PYSETUP_PATH

RUN python -m venv .venv

ARG DBT_CORE_VERSION
ARG ADAPTER_PACKAGE

RUN echo "The variables are \
DBT_CORE_VERSION=${DBT_CORE_VERSION}, \
ADAPTER_PACKAGE=${ADAPTER_PACKAGE}"

# Installs DBT
RUN if [ -z "${DBT_CORE_VERSION}" ] ; \
    then echo "DBT_CORE_VERSION must be specified"; exit 1; \
    fi
RUN pip install "dbt-core==${DBT_CORE_VERSION}"

# Installs an DBT-Adapter package if desired
RUN if [ -z "${ADAPTER_PACKAGE}" ] ; \
    then echo "No adapter package specified, continuing"; \
    else pip install ${ADAPTER_PACKAGE} ; \
    fi

FROM python-base as image

ENV DBT_PROFILES_DIR="/dbt-profile-dir/"

WORKDIR /dbt/

COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
