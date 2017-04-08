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

## Production

Deployment is managed by [edeliver](https://github.com/boldpoker/edeliver).

```bash
mix edeliver build release
mix edeliver deploy release to production
```

On the server, the process is monitored by systemd.
First, `scp` the `krihelinator.service` to `/etc/systemd/system/`, start, and enable to service.
Later, after each deployment:

``` bash
ssh ubuntu@krihelinator.xyz sudo systemctl restart krihelinator.service
```

To see the logs:

```bash
ssh -t ubuntu@krihelinator.xyz journalctl -u krihelinator.service
```

Find more info about using systemd in these [blog post](https://mfeckie.github.io/Phoenix-In-Production-With-Systemd/) and [forum thread](https://elixirforum.com/t/elixir-apps-as-systemd-services/2400).

Lastly, I used [this](https://gist.github.com/kentbrew/776580) incredibly stupid solution to redirect communication on port 80 to port 4000, where the server is listening.

## Similar projects

- [GitHut](http://githut.info/) and [GitHut 2](https://madnight.github.io/githut/)
- [IsItMaintained](http://isitmaintained.com/)
- [GitHub profiler](http://www.datasciencecentral.com/profiles/blogs/github-profiler-a-tool-for-repository-evaluation)
