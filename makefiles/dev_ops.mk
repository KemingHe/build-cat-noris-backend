# ./makefiles/dev_ops.mk
#
# Commands for run, build, and deploy
.PHONY: build_local run_local push_gcloud
.PHONY: build_gcloud deploy_gcloud

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
MAX_INST = 10

build_local:
	docker build --build-arg EXPOSED_PORT=$(EXPOSED_PORT) --tag $(FULL_NAMETAG) $(ROOT_DIR)

run_local:
	docker run --publish $(LOCAL_PORT):$(EXPOSED_PORT) $(FULL_NAMETAG)

push_gcloud:
	docker push $(FULL_NAMETAG)

build_gcloud:
	gcloud builds submit $(ROOT_DIR) --tag $(FULL_NAMETAG) --config=$(GCONFIG) --async

deploy_gcloud:
	gcloud run deploy $(SERVICE_N) \
		--image $(FULL_NAMETAG) \
		--platform $(PLATFORM_T) \
		--region $(REGION_N) \
		--no-allow-unauthenticated \
		--max-instances=$(MAX_INST)

