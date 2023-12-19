FROM python:3.10-slim-bullseye AS python-base

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
FROM python-base AS builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for building python deps
        build-essential

WORKDIR $PYSETUP_PATH

RUN python -m venv .venv

ARG DBT_PACKAGE
ARG ELEMENTARY_PACKAGE

RUN echo "The variables are \
DBT_PACKAGE=${DBT_PACKAGE}, \
ELEMENTARY_PACKAGE=${ELEMENTARY_PACKAGE}"

# Installs DBT
RUN if [ -z "${DBT_PACKAGE}" ] ; \
    then echo "DBT_PACKAGE must be specified"; exit 1; \
    fi
RUN pip install ${DBT_PACKAGE}

# Installs Elementary
RUN if [ -z "${ELEMENTARY_PACKAGE}" ] ; \
    then echo "ELEMENTARY_PACKAGE must be specified"; exit 1; \
    else pip install ${ELEMENTARY_PACKAGE} ; \
    fi


FROM mcr.microsoft.com/azure-cli:2.55.0 AS elementary-report-server

RUN apk update && apk upgrade
RUN apk add --no-cache python3

RUN pip install azure-storage-blob azure-identity flask flask-caching waitress

# Include elementary serve script in image
COPY scripts/elementary_serve_report.py /usr/bin/elementary-serve-from-azure
RUN chmod +x /usr/bin/elementary-serve-from-azure


FROM python-base AS image

ENV DBT_PROFILES_DIR="/dbt-profile-dir/"

WORKDIR /dbt/

COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
