import time
import urllib

import pytest
from selenium import webdriver


class Driver(webdriver.Firefox):
    """
    Extended Firefox driver.
    """

    def wait_for(self, function, timeout=10):
        """
        Wait for something to happen. When timeout expires assert.
        """

        for attempt in range(timeout):
            if function():
                break
            time.sleep(1)
        else:
            assert function()

    def assert_in_current_title(self, title):
        """
        Wait for the page title, making sure we are on the right page.
        """
        self.wait_for(lambda: title in self.title)

    def assert_current_url(self, url):
        """
        Waits for the given URL to load. Raise if different URL found after
        timeout.
        """
        self.wait_for(
            lambda: urllib.parse.unquote(self.current_url).strip('/') == url
        )


@pytest.fixture(scope='session')
def driver():
    driver = Driver()
    yield driver
    driver.quit()
