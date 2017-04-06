"""
Test pages that should lead to errors.
"""

import requests


def test_repositories_without_arguments(base_url):
    """
    Get /repositories without mentioning a repo name. Bug #140.
    """
    response = requests.get(base_url + '/repositories')
    assert response.status_code == 404


def test_repos_of_unexisting_language(base_url):
    """
    Get repos of unexisting language. Bug #79.
    """
    response = requests.get(base_url + '/languages/moshe')
    assert response.status_code == 404


def test_search_github_without_giving_a_repo_name(base_url):
    """
    Bug #145.
    """
    resp = requests.get(base_url + '/?query=&type=github')
    assert resp.status_code == 200
