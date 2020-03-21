#
# Makefile
APP_NAME=hello

include .env

all: clean run

run: all_checks start

clean: stop

#==========================================================================
# Development Environtmen creating
env:
	pyenv install -s 3.6.0
	pyenv virtualenv 3.6.0 ${APP_NAME}

#==========================================================================
# Run/Stop app in docker containers
start: build
	docker-compose up -d 

requirements:
	pip install -r ${APP_NAME}/requirements.txt
	touch $@

#build app's docker image
build: 
	docker-compose build
	docker network create dev || echo "Network 'dev' already exists"

stop:
	docker-compose down


#==========================================================================
# Test and verify quality of the app
unittest: requirements
	python -m unittest discover ${TEST_DIR}

coverage: requirements
	python -m coverage run --source ${APP_NAME} --branch -m unittest discover -v 
	python -m coverage report -m
	python -m coverage html

lint: requirements
	python -m pylint ${APP_NAME}

security:
	python -m bandit ${APP_NAME}

all_checks: lint security unittest coverage

docker-all_checks: start
	docker exec -it ${APP_NAME} make all_checks

