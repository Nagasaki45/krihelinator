"""
Test pages that should lead to errors.
"""

import requests


def test_repositories_wihtout_arguments(base_url):
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
