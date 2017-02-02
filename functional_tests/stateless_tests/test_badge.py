"""
Make sure badges are served.
"""

import requests


def test_badge(base_url):
    response = requests.get(base_url + '/badge/Nagasaki45/krihelinator')
    assert response.status_code == 200


def test_non_existing_github_repo(base_url):
    response = requests.get(base_url + '/badge/no-such/repo')
    assert response.status_code == 404
