#Push to DockerHubMost vars can be ovewritten with ENV vars (like Jenkins)
BUILD_DATE ?= $(strip $(shell date -u +"%Y-%m-%dT%H:%M:%SZ"))
VENDOR ?= ecliptik
PROJECT_NAME ?= gill-hicks
DOCKER_IMAGE ?= $(VENDOR)/${PROJECT_NAME}
ENVIRONMENT ?= development
GIT_TAG ?= $(strip $(shell git rev-parse --abbrev-ref HEAD | sed -e "s/\//_/g"))
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
GIT_URL ?= $(strip $(shell git config --get remote.origin.url))

#Application Configuration
#These values are set in .secret when secret is run, should be set as environment variables with production values.
MYSQL_HOST ?= locahlost
MYSQL_USER ?= mysql
MYSQL_PASSWORD ?= temp123
MYSQL_DATABASE ?= hardware

#List of macros
default: build
build: docker_build output
push: docker_push
secret: create_secret update_secret
deploy: secret build docker_push kube_deploy output

#Set DOCKER_TAG
DOCKER_TAG ?= $(GIT_TAG)-$(GIT_COMMIT)

#Create k8s secret from RDS environment variables
define SECRET
apiVersion: v1
kind: Secret
metadata:
  name: hardware
  namespace: default
stringData:
  MYSQL_HOST: $(MYSQL_HOST)
  MYSQL_USER: $(MYSQL_USER)
  MYSQL_PASSWORD: $(MYSQL_PASSWORD)
  MYSQL_DATABASE: $(MYSQL_DATABASE)
endef
export SECRET

create_secret:
	@echo "$$SECRET" > .secret

update_secret:
	kubectl apply -f .secret --validate=false --force=true

docker_build:
	# Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

kube_deploy:
	# Update container tag and deploy application
	sed -i.bak -e "s/DOCKER_TAG/$(DOCKER_TAG)/g" ./kubernetes/manifest.yaml
	kubectl apply -f ./kubernetes/manifest.yaml

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)
