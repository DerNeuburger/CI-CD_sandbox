setup:
	python3 -m venv ~/.CI-CD_sandbox

install:
	pip install --upgrade pip &&\
	pip install -r requirements.txt

lint:
	hadolint --ignore DL3013 Dockerfile
	pylint --disable=R,C,W1203 app.py

all:
	install lint
