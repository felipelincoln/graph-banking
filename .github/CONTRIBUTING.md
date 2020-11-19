# Contributing

Make sure to have [docker-compose](https://docs.docker.com/compose/) installed.

## Running the application locally
Enter the development container:

```shell
git clone https://github.com/felipelincoln/graph-banking.git
cd graph-banking/
docker-compose run --service-ports --rm web /bin/sh
```

Create the database, run migrations and start the server:

```shell
mix ecto.setup
mix phx.server
```

Alternatively (when the database is already created), you can fast start the services:

```shell
docker-compose up
```

## Test pipeline
Good practice to run before making commits. It will mirror our [GitHub action](https://github.com/felipelincoln/graph-banking/blob/master/.github/workflows/test.yml).  
Run the following inside the container:

```shell
mix ci
```

This will run:

```shell
mix format --check-formatted --dry-run
mix credo --strict
mix coveralls
```

## Building documentation
Run whenever your changes may cause [documentation](https://felipelincoln.github.io/graph-banking) changes.  
Run the following inside the container:

```shell
mix docs
```
