# ./Makefile
#
# Main Makefile for project.

include makefiles/dev_ops.mk makefiles/lint_test.mk

SHELL = /bin/bash

.DEFAULT_GOAL := all
.PHONY: all
all:
	set -e; \
	make lint; \
	make test; \
	make build; \
	make run

