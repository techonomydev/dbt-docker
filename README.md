# DBT Runner Docker Serverless

This repository generates a set of docker images 
that can be used to run DBT.

If a necessary version of dbt-core or a dbt-adapter is not available,
it can be added to the matrix strategy in the continuous deployment (cd) workflow.

## Alternatives

We also have a server-based version called
[dbt-runner](https://github.com/techonomydev/dbt-runner-docker).
This provides API endpoints to interact with docker.

## Building for production

To use this docker for your actual environment apply the following steps:

- Add the `profiles.yml` file with the database configuration to `/dbt-profiles-dir/`
  - Try to keep secrets out of the docker-image and use environment variables instead.
    They can be used in DBT config files with jinja templating like so `"{{ env_var('YOUR_ENV_VARIABLE') }}"`

- Add all relevant DBT project files to `/dbt/`

### TIPS & Common Errors

- When getting **invalid credentials errors** for bigquery:
  Check if the json secrets has properly escaped newlines in the `private_key` property.
  If these newlines if you see a new line instead of `\n` in the yaml menu of the live view 
  you'll need to escape the newline slashes like so `\\n`.
- For better monitoring it is useful to include
  [dbt-run-monitoring](https://github.com/techonomydev/dbt-run-monitoring)
  as a dbt package to your project.

## Accessing the image from other repositories during CD

By default, only users of this repo have access to this image. 
To give other repositories access to this image you can do so by
giving that repository read access 
[here](https://github.com/orgs/techonomydev/packages/container/dbt-runner/settings)

## Development

- To trigger the Continuous Deployment you must add a version tag e.g. `v1.0.0`
