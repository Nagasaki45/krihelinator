# The Krihelinator

> *"Trendiness of open source software should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

[![Krihelimeter](http://krihelinator.xyz/badge/Nagasaki45/krihelinator)](http://krihelinator.xyz)
[![Build Status](https://travis-ci.org/Nagasaki45/krihelinator.svg?branch=master)](https://travis-ci.org/Nagasaki45/krihelinator)

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with highest "krihelimeter", instead of daily stars. The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (similarly to github's pulse page).

## Development

Before starting, make sure PostgreSQL and Elixir are installed. Follow the [phoenix installation guide](http://www.phoenixframework.org/docs/installation) for more details. Note that you won't need node.js for this project.

To start your app:

  * Get a google [Application Default Credentials](https://developers.google.com/identity/protocols/application-default-credentials) json file by following instructions 1a - 1f under the title "How the Application Default Credentials work" in the link.
  * Rename and move the file you just downloaded to `priv/bigquery_private_key.json`.
  * Create the DB: `mix ecto.create`.
  * Migrate to the latest DB scheme: `mix ecto.migrate`.
  * Spin the server `mix phoenix.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Similar projects

- [GitHut](http://githut.info/) and [GitHut 2](https://madnight.github.io/githut/)
- [IsItMaintained](http://isitmaintained.com/)
- [GitHub profiler](http://www.datasciencecentral.com/profiles/blogs/github-profiler-a-tool-for-repository-evaluation)
