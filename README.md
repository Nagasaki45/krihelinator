# The Krihelinator

> *"Trendiness of open source software should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

[![Krihelimeter](http://krihelinator.xyz/badge/Nagasaki45/krihelinator)](http://krihelinator.xyz)

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with highest "krihelimeter", instead of daily stars. The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (similarly to github's pulse page).

## Development

The only dependencies are docker and docker-compose. To start your app:

  * Get a google [Application Default Credentials](https://developers.google.com/identity/protocols/application-default-credentials) json file by following instructions 1a - 1f under the title "How the Application Default Credentials work" in the link.
  * Name the file you just downloaded `bigquery_private_key.json` and put it in the project root directory.
  * Build the docker image: `docker-compose build`.
  * Create the DB: `docker-compose run --rm web mix ecto.create`.
  * Migrate to the latest DB scheme: `docker-compose run --rm web mix ecto.migrate`.
  * Spin up everything `docker-compose up -d`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Makefile

Some tasks are automated in the `Makefile`. During development `docker-compose run --rm web <whatever>` is used a lot! However, I prefer not to automate these one-liners unless they are used by other tasks.

## Scripts

If you messed things up there are several useful scripts in `priv/scripts` with relatively self explanatory names. Run them with `docker-compose run --rm web mix run path/to/script.exs`.
