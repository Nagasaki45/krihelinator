# The Krihelinator

> *"Trendiness of OSS should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with highest "krihelimeter", instead of daily stars. The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (similarly to github's pulse page).

To start your app:

  * Create a `secrets` file, with your github token, like this: `GITHUB_TOKEN=<your github token>`.
  * Spin up the postgres DB with `docker-compose up -d`.
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Scripts

If you messed up the krihelimeter or the repos descriptions (both are saved in the DB), you can run the following to fix them:

    mix run priv/repo/update_krihelimeter.exs
    mix run priv/repo/update_description.exs

## Running in production

I use `docker` and `docker-compose` in production, so make sure you have them on your server.

    # Provisioning
    scp production/docker-compose.yml server.com:/path/to/project
    scp secrets server.com:/path/to/project

    # Get ready, locally
    docker build -t user/image .
    push user/image

    # Remotely
    ssh server.com
    cd /path/to/project
    docker-compose pull

    # Only on first run
    docker-compose run --rm web mix ecto.create

    # Spin up the new version
    docker-compose run --rm web mix ecto.migrate
    docker-compose run --rm web mix run priv/repo/update_krihelimeter.exs  # Optionally
    docker-compose run --rm web mix phoenix.server
