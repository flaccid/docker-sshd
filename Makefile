DOCKER_REGISTRY = index.docker.io
IMAGE_NAME = sshd
IMAGE_VERSION = latest
IMAGE_ORG = flaccid
IMAGE_TAG = $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)
KUBE_NAMESPACE = default

WORKING_DIR := $(shell pwd)

.DEFAULT_GOAL := help

.PHONY: build

docker-release:: docker-build docker-push ## Builds and pushes the docker image to the registry

docker-push:: ## Pushes the docker image to the registry
		@docker push $(IMAGE_TAG)

docker-push-ubuntu:: ## Pushes the docker image to the registry (ubuntu version)
		@docker push $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu
		@docker tag $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu-22.04
		@docker push $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu-22.04

docker-build:: ## builds the docker image locally
		@docker build  \
			--pull \
			-t $(IMAGE_TAG) \
				$(WORKING_DIR)

docker-build-ubuntu:: ## builds the docker image locally (ubuntu version)
		@docker build  \
			--pull \
			-f Dockerfile.ubuntu \
			-t $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu \
				$(WORKING_DIR)

docker-build-ubuntu-clean:: ## builds the docker image locally (ubuntu version, clean)
		@docker build  \
			--no-cache \
			--pull \
			-f Dockerfile.ubuntu \
			-t $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu \
				$(WORKING_DIR)

docker-build-clean:: ## cleanly builds the docker image locally
		@docker build  \
			--no-cache \
			--pull \
			-t $(IMAGE_TAG) \
				$(WORKING_DIR)

docker-run:: ## Runs the docker image
		docker run \
			--name sshd \
			-it \
			--rm \
			-p 2222:22 \
			-e SSH_USER=flaccid \
			-e SSH_PUBLIC_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDgQz9uYuTgbe9PflQ2/ctB0xtaVScpHzmR2Fp8wmyEhTB0ACb1hC876lrXaMN6qvyPbXFQALeV9IL6ZAmxep9FiMoxJJIlZ3JeDFyRX9IOE9KU7E6UIgsC+9aEMkeuha6LpoT59q1vsdi0a8OhdQWFPohCAb0QKu7APCU/6Cs1jw== flaccid@lister.dev.xhost.net.au-2011-11-13' \
				$(IMAGE_TAG)

docker-run-ubuntu:: ## Runs the docker image (ubuntu version)
		docker run \
			--name sshd \
			--rm \
			-it \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu

docker-run-ubuntu-detached:: ## Runs the docker image (ubuntu version, detached)
		docker run \
			--name sshd \
			--rm \
			-itd \
				$(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu

docker-exec-shell:: ## Executes a shell in running container
		@docker exec \
			-it \
				sshd /bin/bash

docker-run-shell:: ## Runs the docker image with bash as entrypoint
		@docker run \
			-it \
			--entrypoint /bin/bash \
				$(IMAGE_TAG)

docker-rm:: ## Removes the running docker container
		@docker rm -f sshd

docker-rmi:: ## Removes the container image
		@docker rmi -f $(IMAGE_TAG)

docker-rmi-ubuntu:: ## Removes the container image (ubuntu version)
		@docker rmi -f $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):ubuntu

docker-test:: ## tests the runtime of the docker image in a basic sense
		@docker run $(IMAGE_TAG) sshd --version

helm-install:: ## installs using helm from chart in repo
		@helm install \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				sshd charts/sshd

helm-upgrade:: ## upgrades deployed helm release
		@helm upgrade \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				sshd charts/sshd

helm-uninstall:: ## deletes and purges deployed helm release
		@helm uninstall \
			--namespace $(KUBE_NAMESPACE) \
				sshd

helm-reinstall:: helm-uninstall helm-install ## Uninstalls the helm release, then installs it again

helm-render:: ## prints out the rendered chart
		@helm install \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
			--dry-run \
			--debug \
				sshd charts/sshd

helm-validate:: ## runs a lint on the helm chart
		@helm lint \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				charts/sshd

helm-package:: ## packages the helm chart into an archive
		@helm package charts/sshd

helm-index:: ## creates/updates the helm repo index file
		@helm repo index --url https://flaccid.github.io/container-sshd/ .

helm-flush:: ## removes local helm packages and index file
		@rm -f ./pritunl-*.tgz
		@rm -f index.yaml

# A help target including self-documenting targets (see the awk statement)
define HELP_TEXT
Usage: make [TARGET]... [MAKEVAR1=SOMETHING]...

Available targets:
endef
export HELP_TEXT
help: ## This help target
	@cat .banner
	@echo
	@echo "$$HELP_TEXT"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
		{printf "\033[36m%-30s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)