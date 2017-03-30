# Welcome to the Krihelinator functional tests project

This project is a set of functional tests for the Krihelinator, writen with python3.6, selenium (using the Firefox driver), requests, and pytest.
Although it currently reside in the same repo, this project doesn't share dependencies with the rest of the Krihelinator code.

## Getting started

```bash
python3.6 -m venv env  # Using virtual env is highly recommended
source env/bin/activate
pip install -r requirements.text
# Make sure that selenium dependencies are install properly!!!
```

## Running the tests

```bash
# Locally
pytest
# Or against production with
BASE_URL='http://www.krihelinator.xyz' pytest
```
