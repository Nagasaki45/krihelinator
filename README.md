# The Krihelinator

> *"Trendiness of OSS should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

[![Krihelimeter](http://krihelinator.xyz/badge/nagasaki45/krihelinator)](http://krihelinator.xyz)

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with highest "krihelimeter", instead of daily stars. The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (similarly to github's pulse page).

To start your app:

  * Create a `secrets` file, with your github token, like this: `GITHUB_TOKEN=<your github token>`.
  * Spin up the postgres DB with `docker-compose up -d`.
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Running without the pipeline in the background:

    NO_PIPELINE=1 iex -S mix
    # In production
    docker-compose run --rm -e NO_PIPELINE=1 web iex -S mix

## Scripts

If you messed things up there are several usefull scripts in `priv/scripts`:

    mix run priv/scripts/update_krihelimeter.exs
    mix run priv/scripts/update_description.exs
    mix run priv/scripts/delete_forks.exs
    mix run priv/scripts/delete_single_author_repos.exs
    mix run priv/scripts/delete_zero_commits_repos.exs

## Running in production

I use `docker` and `docker-compose` in production, so make sure you have them on your server.

    # Provisioning
    scp production/docker-compose.yml server.com:/path/to/project
    scp secrets server.com:/path/to/project

    # Get ready, locally
    docker build -t user/image .
    docker push user/image

    # Remotely
    ssh server.com
    cd /path/to/project
    docker-compose pull

    # Only on first run
    docker-compose run --rm web mix ecto.create

    # Spin up the new version
    docker-compose run --rm web mix ecto.migrate
    docker-compose run --rm web mix run priv/repo/update_krihelimeter.exs  # Optionally
    docker-compose up -d
