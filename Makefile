SHELL:=/bin/bash

install:
	python3 -m venv .venv_build
	. .venv_build/bin/activate; \
	pip install --upgrade pip; \
	pip install -r requirements/build.txt; \
	deactivate

test-install:
	. .venv_build/bin/activate; \
	pip install -r requirements/test.txt; \
	deactivate
	wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.17.5/hadolint-Linux-x86_64 && \
	chmod +x /bin/hadolint

test-lint:
	hadolint --ignore DL3013 Dockerfile
	. .venv_build/bin/activate; \
	pylint --disable=R,C,W1203 app.py; \
	deactivate
test-circleci-validate:
	circleci config process .circleci/config.yml

test-circleci-run:
	circleci config process .circleci/config.yml > .circleci/process.yml
	for i in "linting" "building" ; do \
		echo $i ; \
		sudo circleci build -c .circleci/process.yml -e PROJECT_MAIN_VERSION="0" -e PROJECT_SUB_VERSION=1 -e DOCKER_USER=derneuburgerdocker -e DOCKER_PASS= -e 8db952bd-4060-4f0b-9273-fe2eae8d7b93 CIRCLE_BUILD_NUM=12345 -e CIRCLE_PROJECT_REPONAME=CI-CD_sandbox  --job $$i ; \
	done
	rm .circleci/process.yml

all:
	install test-install test-lint test-circleci-validate test-circleci-run
