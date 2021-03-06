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

test-lint-dockerfiles:
	hadolint --ignore DL3013 Dockerfile
test-lint-pythonfiles:
	. .venv_build/bin/activate; \
	pylint --disable=R,C,W1203 app.py; \
	deactivate
test-circleci-validate:
	circleci config process .circleci/config.yml

test-circleci-run:
	circleci config process .circleci/config.yml > .circleci/process.yml
	source .circleci/project_environment.sh; \
  if [ -z $$JOBNAMES ]; then \
		echo "inside"; \
		JOBNAMES=( "linting-files-1" "linting-files-2/check" "linting-files-3/markdown_lint" "building" "testing"); \
	fi; \
	echo $$JOBNAMES; \
	for i in $${JOBNAMES[@]}; do \
		sudo circleci build -c .circleci/process.yml -e PROJECT_MAIN_VERSION=$$PROJECT_MAIN_VERSION -e PROJECT_SUB_VERSION=$$PROJECT_SUB_VERSION -e DOCKER_USER=$$DOCKER_USER -e DOCKER_PASS=$$DOCKER_PASS -e CIRCLE_BUILD_NUM=$$CIRCLE_BUILD_NUM -e DOCKER_IMAGE_NAME=$$DOCKER_IMAGE_NAME  --job $$i ; \
	done
	rm .circleci/process.yml

all:
	install test-install test-lint test-circleci-validate test-circleci-run
