"""
Basic tests check that all of the pages are there and presenting the basic
information properly.
"""

import random

import requests


def validate_page_contains_list_of_repositories(driver):
    list_element = driver.find_element_by_css_selector('.list-group')
    repos = list_element.find_elements_by_tag_name('li')
    assert len(repos) > 0
    assert len(repos) <= 50

    # Examine a random repo
    repo = random.choice(repos)
    title = repo.find_element_by_tag_name('h3').text
    assert '/' in title
    krihelimeter_badge = repo.find_element_by_tag_name('svg')
    assert 'Krihelimeter' in krihelimeter_badge.text


def test_homepage(driver, base_url):
    driver.get(base_url)

    # Basic page properties
    assert 'krihelinator' in driver.title.lower()
    quote = driver.find_element_by_tag_name('blockquote')
    assert 'Trendiness of open source software should be assessed by' in quote.text

    validate_page_contains_list_of_repositories(driver)


def test_languages(driver, base_url):
    driver.get(base_url + '/languages')

    # The languages table is shown
    table = driver.find_element_by_tag_name('table')

    # With correct headers
    thead = table.find_element_by_tag_name('thead')
    ths = thead.find_elements_by_tag_name('th')
    expecteds = ['#', 'Language', 'Krihelimeter', 'Select']
    for th, expected in zip(ths, expecteds):
        assert th.text == expected

    # Make sure JavaScript and Python are there
    table_text = table.text
    assert 'Python' in table_text
    assert 'JavaScript' in table_text


def test_about(driver, base_url):
    driver.get(base_url + '/about')

    # Inspect the text a bit
    text = driver.find_element_by_tag_name('main').text
    assert "alternative to github's trending" in text


def test_language(driver, base_url):
    driver.get(base_url + '/languages/Python')

    # The language name and summarized stats are there
    language = driver.find_element_by_css_selector('.header')
    language_name = language.find_element_by_tag_name('h1').text
    assert language_name == 'Python'
    language_stats = language.find_element_by_tag_name('h4').text
    assert 'Total Krihelimeter' in language_stats

    validate_page_contains_list_of_repositories(driver)


def test_language_that_requires_encoding(driver, base_url):
    """
    Make sure the language page and history page for languages like C#
    are working. Bug #165.
    """
    driver.get(base_url + '/languages')
    driver.find_element_by_link_text("C#").click()
    driver.assert_in_current_title("C#")

    # Get info to get the history page with requests.
    # We need the http code, which selenium won't give.
    button = driver.find_element_by_link_text("Show language history")
    history_page_url = button.get_attribute('href')
    resp = requests.get(history_page_url)
    assert resp.status_code == 200


def test_history(driver, base_url):
    pass  # TODO functional test of history page
