 install:
	python3 -m venv .venv_build
	pip install --upgrade pip &&\
	pip install -r requirements/build.txt

test-install:
	. .venv_build/bin/activate
	pip install -r requirements/test.txt
	wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.17.5/hadolint-Linux-x86_64 && \
	chmod +x /bin/hadolint

test-lint:
	hadolint --ignore DL3013 Dockerfile
	pylint --disable=R,C,W1203 app.py

test-circleci-validate:
	circleci config process .circleci/config.yml

test-circleci-run:
	circleci local execute -c .circleci/config.yml

all:
	install test-install test-lint test-circleci-validate test-circleci-run
