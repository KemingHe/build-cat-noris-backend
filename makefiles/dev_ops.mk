# ./makefiles/dev_ops.mk
#
# Commands for run, build, and deploy

include ./lint_test.mk

.PHONY: test
.PHONY: build_local run_local push_gcloud
.PHONY: build_gcloud deploy_gcloud deploy_buildless_gcloud

ROOT_DIR = .
GCONFIG = config.yaml

LOCAL_PORT = 5000
EXPOSED_PORT = 5000

GCLOUD_P = gcr.io
PROJ_P = proj-cat-noris
IMG_N = cat-noris-backend
IMG_T = 0.1.0

FULL_NAMETAG = $(GCLOUD_P)/$(PROJ_P)/$(IMG_N):$(IMG_T)

SERVICE_N = cat-noris-backend-service
PLATFORM_T = managed
REGION_N = us-central1
AUTH_STATUS = --no-allow-unauthenticated
MAX_INST = 10

build_local: test
	set -e; \
	echo -e "Building Docker image locally...\n"; \
	docker build \
		--build-arg EXPOSED_PORT=$(EXPOSED_PORT) \
		--tag $(FULL_NAMETAG) \
		$(ROOT_DIR); \
	echo -e "Image $(FULL_NAMETAG) exposing port $(EXPOSED_PORT) build success.\n"

run_local: build_local
	set -e; \
	echo -e "Creating new image instance and running  locally...\n"; \
	docker run --publish $(LOCAL_PORT):$(EXPOSED_PORT) $(FULL_NAMETAG); \
	echo -e "Image $(FULL_NAMETAG) running on localhost:$(LOCAL_PORT).\n"

push_gcloud: build_local
	set -e; \
	echo -e "Pushing locally built Docker image to GCP...\n"; \
	docker push $(FULL_NAMETAG); \
	echo -e "Image $(FULL_NAMETAG) exposing port $(EXPOSED_PORT) push to cloud success.\n"

build_gcloud: test
	set -e; \
	echo -e "Uploading local files to GCP and starting Cloud Build...\n"; \
	gcloud builds submit $(ROOT_DIR) --tag $(FULL_NAMETAG) --config=$(GCONFIG) --async; \
	echo -e "Image $(FULL_NAMETAG) exposing port $(EXPOSED_PORT) cloud build success.\n"

define DEPLOY_COMMANDS
	set -e; \
	echo -e "Deploying new instance from Cloud Container Registry to Cloud Run...\n"; \
	gcloud run deploy $(SERVICE_N) \
		--image $(FULL_NAMETAG) \
		--platform $(PLATFORM_T) \
		--region $(REGION_N) \
		$(AUTH_STATUS) \
		--max-instances=$(MAX_INST); \
	echo -e "Image $(FULL_NAMETAG) exposing port $(EXPOSED_PORT) cloud deploy success,\n"; \
	echo -e "server can only be accessed through Pub/Sub due to $(AUTH_STATUS).\n"
endef

export DEPLOY_COMMANDS

deploy_gcloud: build_gcloud
	@bash -c "$$DEPLOY_COMMANDS"

deploy_buildless_gcloud: 
	@bash -c "$$DEPLOY_COMMANDS"

