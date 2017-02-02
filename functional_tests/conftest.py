import os

import pytest


@pytest.fixture(scope='session')
def base_url():
    default = 'http://localhost:4000'
    return os.environ.get('BASE_URL', default)
