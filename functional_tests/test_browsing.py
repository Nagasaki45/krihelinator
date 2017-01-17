"""
Make sure that the site is browsable: clicking things leads to the right places.
"""


def go_to(driver, navbar_link):
    navbar = driver.find_element_by_tag_name('nav')
    navbar.find_element_by_link_text(navbar_link).click()
    import time
    time.sleep(1)


def test_browsing(driver, base_url):
    driver.get(base_url)

    go_to(driver, 'About')
    driver.assert_current_url(base_url + '/about')
    go_to(driver, 'Repositories')
    driver.assert_current_url(base_url)
    go_to(driver, 'Languages')
    driver.assert_current_url(base_url + '/languages')

    # From the languages page select a language and proceed to the history
    # page
    tbody = driver.find_element_by_tag_name('tbody')
    language = tbody.find_element_by_tag_name('tr')  # The 1st lang
    language_name = language.find_elements_by_tag_name('td')[1].text
    language.find_element_by_tag_name('input').click()

    # Selenium doesn't know how to click on things that were manipulated
    # using JS. The solution: click using JS script.
    button = driver.find_element_by_css_selector('button.btn-primary')
    driver.execute_script('arguments[0].click();', button)

    url_params = f'languages=["{language_name}"]'
    driver.assert_current_url(base_url + '/languages/history?' + url_params)

    # Going back to languages to select one
    go_to(driver, 'Languages')
    language_name = 'Python'
    driver.assert_current_url(base_url + '/languages')
    tbody = driver.find_element_by_tag_name('tbody')
    tbody.find_element_by_link_text(language_name).click()
    driver.assert_current_url(f'{base_url}/repositories/{language_name}')

    # Click on the "show history" button
    driver.find_element_by_link_text('Show language history').click()
    url_params = f'languages=["{language_name}"]'
    driver.assert_current_url(base_url + '/languages/history?' + url_params)
