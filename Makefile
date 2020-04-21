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
	source .circleci/project_environment.sh; \
	for i in "linting" "building" ; do \
		echo $i ; \
		sudo circleci build -c .circleci/process.yml -e PROJECT_MAIN_VERSION="$PROJECT_MAIN_VERSION" -e PROJECT_SUB_VERSION="$PROJECT_SUB_VERSION" -e DOCKER_USER="$DOCKER_USER" -e DOCKER_PASS="$DOCKER_PASS" -e CIRCLE_BUILD_NUM="$CIRCLE_BUILD_NUM" -e CIRCLE_PROJECT_REPONAME="$CIRCLE_PROJECT_REPONAME"  --job $$i ; \
	done
	rm .circleci/process.yml

all:
	install test-install test-lint test-circleci-validate test-circleci-run
