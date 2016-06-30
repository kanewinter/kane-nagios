makefile_dir 	:= $(abspath $(shell pwd))
SHELL := /bin/bash

docker_group	:= bcvtools
docker_image 	:= bcv-nagios
docker_ver   	:= 1.0.46
docker_tag   	:= docker.comcast.net/$(docker_group)/$(docker_image):$(docker_ver)
docker_src 		:= /src

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
	make bumpversion-patch
	make docker-build
	make docker-push

bumpversion-patch:
	@docker run --rm -v $(makefile_dir):/dist \
	docker.comcast.net/bcvtools/bumpversion:1.0.1 \
	make bumpversion-patch --no-print-directory

bumpversion-major:
	@docker run --rm -v $(makefile_dir):/dist \
		docker.comcast.net/bcvtools/bumpversion:1.0.1 \
		make bumpversion-major --no-print-directory

rancher-upgrade:
	docker run --rm \
		-e "RANCHER_ACCESS_KEY=$(RANCHER_ACCESS_KEY)" \
		-e "RANCHER_SECRET_KEY=$(RANCHER_SECRET_KEY)" \
		-v $(makefile_dir):/dist \
		docker.comcast.net/bcvtools/rancher-cli:1.0.5 rancher-upgrade.bash

rancher-rm:
	docker run --rm \
		-e "RANCHER_ACCESS_KEY=$(RANCHER_ACCESS_KEY)" \
		-e "RANCHER_SECRET_KEY=$(RANCHER_SECRET_KEY)" \
		-v $(makefile_dir):/dist \
		docker.comcast.net/bcvtools/rancher-cli:1.0.4 rancher-rm.bash

