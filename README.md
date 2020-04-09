# The Krihelinator

:warning: **This project reached its end-of-life! The info here is only for documentation. The project was shut down on April 2020. On July 2020 the [krihelinator.xyz](https://krihelinator.xyz) domain will stop working and this page will only be available on [nagasaki45.github.io/krihelinator](https://nagasaki45.github.io/krihelinator).**

## About

> *"Trendiness of open source software should be assessed by contribution rate, not by stars"*
>
> \- Meir Kriheli

This project proposes an alternative to github's [trending page](http://github.com/trending), by exposing projects with high contribution rate, instead of daily stars.
The krihelimeter of each repository is calculated using the commits, pull requests, and issues of that project, from the past week (based on github's pulse page).

<table align="center">
    <tr>
        <td>Krihelimeter =&nbsp;</td>
        <td>20</td>
        <td>&nbsp;* authors +</td>
    </tr>
    <tr>
        <td></td>
        <td>8</td>
        <td>&nbsp;* merged and proposed pull requests +</td>
    </tr>
    <tr>
        <td></td>
        <td>8</td>
        <td>&nbsp;* new and closed issues +</td>
    </tr>
    <tr>
        <td></td>
        <td>1</td>
        <td>&nbsp;* commits</td>
    </tr>
</table>

During the development of this project I found out that people use github as a backup service, automating hundreds of commits per week.
Therefor, to filter these projects out, only projects with more than one author enters the Krihelinator DB.

Drop me a line at <a href="mailto:nagasaki45@gmail.com">nagasaki45@gmail.com</a> if you do somethig interesting with this project. Will be happy to hear about it and might be able to help.

## About the shutdown

- On January 2019 github changed the way repo's pulse page is loading. Instead of having the entire HTML available at once, some info was fetched in subsequent calls. Specifically, the number of commits and authors were missing from the pulse page. This broke the calculation of the krihelimeter. Note that although the krihelimeter calculation was now different than the one intended, the information presented on the krihelinator was still relevant because it affected all projects / languages in the same way.
- By the end of March 2020 github started to block scrapers like the krihelinator, returning HTTP error code 429 (Too Many Requests).
- On early April 2020 I've decided to shutdown the project. The [krihelinator.xyz](https://krihelinator.xyz) domain now points to a page saying that the project is down. Links to badges return an end-of-life (EOL) badge.
- On July 2020 the domain shut down. The end-of-life remained available on [nagasaki45.github.io/krihelinator](https://nagasaki45.github.io/krihelinator).

## Similar projects

- [GitHut](http://githut.info/) and [GitHut 2](https://madnight.github.io/githut/)
- [IsItMaintained](http://isitmaintained.com/)
- [GitHub profiler](http://www.datasciencecentral.com/profiles/blogs/github-profiler-a-tool-for-repository-evaluation)
