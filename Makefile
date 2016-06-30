makefile_dir 	:= $(abspath $(shell pwd))
SHELL := /bin/bash

docker_group	:= 
docker_image 	:= nagios
docker_ver   	:= 1.0.1
docker_tag   	:= $(docker_group)/$(docker_image):$(docker_ver)
docker_src 	:= /src

.PHONY: list docker-build docker-run docker-push

list:
	@grep '^[^#[:space:]].*:' Makefile | grep -v ':=' | grep -v '^\.' | sed 's/:.*//g' | sed 's/://g' | sort

docker-tag:
	@echo $(docker_tag)

docker-build:
	docker build --tag $(docker_tag) .

docker-build-clean:
	docker build --no-cache --force-rm --tag $(docker_tag) .

docker-bash:
	@test "$(ntid)" = '' && ntid=$(USER); \
	test "$(pw)" = '' && read -p "NTID Password: " -s pw; \
	docker run -e "OS_USERNAME=$$ntid" -e "OS_PASSWORD=$$pw" -it --rm $(docker_tag)

list_guest:
	@test "$(ntid)" = '' && ntid=$(USER); \
	test "$(pw)" = '' && read -p "NTID Password: " -s pw; \
	docker run -e "OS_USERNAME=$$ntid" -e "OS_PASSWORD=$$pw" -it --rm $(docker_tag) list_guest

docker-dev:
	@read -p "NTID Password: " -sr pw; \
	docker run -e "OS_USERNAME=$(USER)" -e "OS_PASSWORD=$$pw" -it -v $(makefile_dir):$(docker_src) --rm $(docker_tag)

docker-push:
	docker push $(docker_tag)

publish:
	make docker-build
	make docker-push
