# The Krihelinator

> *"Trendiness of open source software should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

[![Krihelimeter](http://krihelinator.xyz/badge/Nagasaki45/krihelinator)](http://krihelinator.xyz)
[![Build Status](https://travis-ci.org/Nagasaki45/krihelinator.svg?branch=master)](https://travis-ci.org/Nagasaki45/krihelinator)

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with highest "krihelimeter", instead of daily stars. The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (similarly to github's pulse page).

## Development

Before starting make sure that docker and docker-compose are properly installed.

To start your app:

  * `mkdir secrets`.
  * Get a google [Application Default Credentials](https://developers.google.com/identity/protocols/application-default-credentials) json file by following instructions 1a - 1f under the title "How the Application Default Credentials work" in the link.
  * Rename and move the file you just downloaded to `secrets/bigquery_private_key.json`.
  * Build: `docker-compose build`.
  * Create the DB: `docker-compose run www mix ecto.create`.
  * Migrate to the latest DB scheme: `docker-compose run www mix ecto.migrate`.
  * Spin the server `docker-compose up`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

To deploy run `./bin/deploy`.

To see the logs:

```bash
ssh krihelinator.xyz "cd krihelinator && docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs www""
```

## Similar projects

- [GitHut](http://githut.info/) and [GitHut 2](https://madnight.github.io/githut/)
- [IsItMaintained](http://isitmaintained.com/)
- [GitHub profiler](http://www.datasciencecentral.com/profiles/blogs/github-profiler-a-tool-for-repository-evaluation)
