# ./Makefile
#
# Main Makefile for backend project.

include makefiles/dev_ops.mk 

SHELL = /bin/bash

.DEFAULT_GOAL := all

.PHONY: all local cloud

cloud: deploy_gcloud

local: run_local

all: local cloud

