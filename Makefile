# Verbose, notice, and spam log levels for Python's logging module.
#
# Author: Peter Odding <peter@peterodding.com>
# Last Change: July 26, 2016
# URL: https://verboselogs.readthedocs.io

WORKON_HOME ?= $(HOME)/.virtualenvs
VIRTUAL_ENV ?= $(WORKON_HOME)/verboselogs
PATH := $(VIRTUAL_ENV)/bin:$(PATH)
MAKE := $(MAKE) --no-print-directory
SHELL = bash

default:
	@echo 'Makefile for verboselogs'
	@echo
	@echo 'Usage:'
	@echo
	@echo '    make install   install the package in a virtual environment'
	@echo '    make reset     recreate the virtual environment'
	@echo '    make check     check coding style (PEP-8, PEP-257)'
	@echo '    make test      run the test suite'
	@echo '    make docs      update documentation using Sphinx'
	@echo '    make publish   publish changes to GitHub/PyPI'
	@echo '    make clean     cleanup all temporary files'
	@echo

install:
	@test -d "$(VIRTUAL_ENV)" || mkdir -p "$(VIRTUAL_ENV)"
	@test -x "$(VIRTUAL_ENV)/bin/python" || virtualenv --quiet "$(VIRTUAL_ENV)"
	@test -x "$(VIRTUAL_ENV)/bin/pip" || easy_install pip
	@test -x "$(VIRTUAL_ENV)/bin/pip-accel" || (pip install --quiet pip-accel && pip-accel install --quiet 'urllib3[secure]')
	@echo "Updating installation of verboselogs .." >&2
	@pip uninstall --yes verboselogs &>/dev/null || true
	@pip install --quiet --editable .

reset:
	$(MAKE) clean
	rm -Rf "$(VIRTUAL_ENV)"
	$(MAKE) install

check: install
	@scripts/check-code-style.sh

test: install
	@pip-accel install --quiet detox --requirement=requirements-tests.txt
	@py.test --cov
	@coverage html
	@detox

docs: install
	@pip-accel install --quiet sphinx
	@cd docs && sphinx-build -nb html -d build/doctrees . build/html

publish: install
	git push origin && git push --tags origin
	make clean
	pip-accel install --quiet twine wheel
	python setup.py sdist bdist_wheel
	twine upload dist/*
	make clean

clean:
	rm -Rf *.egg .cache .coverage .tox build dist docs/build htmlcov
	find -depth -type d -name __pycache__ -exec rm -Rf {} \;
	find -type f -name '*.pyc' -delete

.PHONY: default install reset check test docs publish clean
