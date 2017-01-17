import os
import time
import urllib

import pytest
from selenium import webdriver


class Driver(webdriver.Firefox):
    """
    Extended Firefox driver.
    """

    def assert_current_url(self, url, timeout=10):
        """
        Waits for the given URL to load. Raise if different URL found after
        timeout.
        """

        expected = urllib.parse.quote(url, safe='/=:?')
        for attempt in range(timeout):
            current_url = self.current_url.strip('/')
            if current_url == expected:
                break
            time.sleep(1)
        else:
            assert current_url == expected


@pytest.fixture(scope='session')
def driver():
    driver = Driver()
    yield driver
    driver.quit()


@pytest.fixture(scope='session')
def base_url():
    default = 'http://localhost:4000'
    return os.environ.get('BASE_URL', default)
