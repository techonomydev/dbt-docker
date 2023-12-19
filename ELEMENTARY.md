# Elementary in the docker

This docker comes with elementary pre-installed.

However you still need to configure Elementary in your DBT project.

## Configuring Elementary in your DBT project

The main steps to configure Elementary in your DBT project are defined in the
[Elementary Quickstart page](https://docs.elementary-data.com/quickstart).

*An example of this can be found in the Ahoy-DBT project, most importantly the [db_project.yml](https://github.com/techonomydev/ahoy-dbt/blob/main/dbt_project.yml).

Two important steps in this process are:

1. Adding the dbt package to the `packages.yml file` in your DBT project.
    ([elementary docs](https://docs.elementary-data.com/quickstart#install-dbt-package))

    ```yaml
    packages:
    - package: elementary-data/elementary
        version: 0.7.5
    ```

2. Defining a separate schema for elementary models in your `dbt_project.yml` file.
    ([elementary docs](https://docs.elementary-data.com/quickstart#2-add-to-your-dbt-project-yml))

    ```yaml
    models:
        elementary:
            +schema: "elementary"
    ```

### For local testing

1. Creating an elementary profile in your `~/.dbt/profiles.yml` file.
    [Elementaries docs](dbt run-operation elementary.generate_elementary_cli_profile) suggest running
    `dbt run-operation elementary.generate_elementary_cli_profile`

    However I'd suggest a structure like this:

    ```yaml
    database-credentials: &database-credentials
        # You probably already have this configured

    your-profile:
        target: dev
        outputs:
            dev:
            schema: dev
            <<: *database-credentials
            prod:
            schema: prod
            <<: *database-credentials

    # This provides elementary access tot the live elements
    elementary:
        target: dev
        outputs:
            dev:
            schema: dev_elementary
            <<: *database-credentials
            prod:
            schema: prod_elementary
            <<: *database-credentials
    ```

    Do note that this elemenatary profile cannot be sparated between different projects.
    Therefore, I'd suggest only using it while setting up elementary in your project. And removing it afterwards.

2. Run `pipenv install elementary-data[your-database-adapter]` to install the CLI tool.

### For deployment with docker

The only thing that needs to be added to this docker specifically for elementary is the `elementary` profile in the `profiles.yml` file (as described in *For local testing* - step 1).

An example of this can be found at [Ahoy-DBT docker/profiles.yml](https://github.com/techonomydev/ahoy-dbt/blob/main/docker/profiles.yml).

## Using the Elementary Docker Commands

Since the Elementary CLI tool is installed in the docker, you can use the normal commands, like: `edr send-report` and `edr-monitor`. There is no state necessary within the docker (state is maintained within the `..._elementary` database schemas.)

What is necessary is to provide the right environment variables to the docker to ensure that elementary can send the notifications to slack. Elementary environment variables are structured in the form `EDR_<COMMAND>_<OPTION>`. Therefore we suggest setting the following environment variables in the docker:

* `EDR_SEND_REPORT_SLACK_CHANNEL_NAME=<your notification channel>`
* `EDR_MONITOR_SLACK_CHANNEL_NAME=<your notification channel>`
* `EDR_SEND_REPORT_TIMEZONE=Europe/Amsterdam`
* `EDR_MONITOR_TIMEZONE=Europe/Amsterdam`
* `EDR_SEND_REPORT_SLACK_TOKEN=<the slack token>`
* `EDR_MONITOR_SLACK_TOKEN=<the slack token>`

The slack token can be found in bitwarden under the name `Slack Elementary Bot User OAuth Token`.

A terraform example can be found [here](https://github.com/techonomydev/ahoy-infra/blob/65b2a1ae18b965783007b07e9ec9ec34e4227486/acis.tf#L268-L300).

## Hosting reports

### Using the `elementary-serve-from-azure` script
This script downloads an elementary report and serves the report in the same container. 


### Other methods
We haven't hosted Elementary reports using other methods, though writing to Azure blobs, GCP storage buckets

## Advanced features

For features that go beyond elementary's default configuration go to the [Elementary docs](https://docs.elementary-data.com/).

## ⚠️ Important notes ⚠️

Elementary will silently fail if áll models are automatically materialized as something else than a view. Instead this type of "auto-materialisation" can be set under `models:your_project:...` in the `dbt_project.yml` file. Like so:

```yaml
models:
  your_project:
    materialized: table
```
