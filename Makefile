#####################
### General Settings
#####################

# Define the root directory
ROOT_DIR ?= $(shell pwd)

# Use Bash as default shell
SHELL := sh
# Set bash strict mode and enable warnings
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
# Making steps silent - don't print all the commands to stdout
.SILENT:

TF_BIN := tofu
WORKING_PATH :=

.PHONY: help
help:
	$(info Creates a local cluster using Kind (Kubernetes in Docker))
	$(info Usage: make <target>)
	$(info )
	$(info Available targets:)
	$(info - create-cluster-ambient:  creates the cluster with Istio Ambient mode enabled)
	$(info - destroy-cluster-ambient: deletes the cluster with Istio Ambient mode enabled)
	$(info )
	$(info - create-cluster-sidecar:  creates the cluster with Istio Sidecar mode enabled)
	$(info - destroy-cluster-sidecar: deletes the cluster with Istio Sidecar mode enabled)

.PHONY: create-cluster-ambient
create-cluster-ambient: export WORKING_PATH=$(ROOT_DIR)/examples/vind-with-istio-ambient
create-cluster-ambient: init
create-cluster-ambient: apply
create-cluster-ambient: ## Creates a local cluster with Istio Ambient mode enabled
	@echo "Created the cluster with Istio Ambient mode"

.PHONY: destroy-cluster-ambient
destroy-cluster-ambient: export WORKING_PATH=$(ROOT_DIR)/examples/vind-with-istio-ambient
destroy-cluster-ambient: destroy
destroy-cluster-ambient: ## Destroys a previously created local cluster with Istio Ambient mode enabled
	@echo "Destroyed the cluster with Istio Ambient mode"

.PHONY: create-cluster-sidecar
create-cluster-sidecar: export WORKING_PATH=$(ROOT_DIR)/examples/vind-with-istio-legacy
create-cluster-sidecar: init
create-cluster-sidecar: apply
create-cluster-sidecar: ## Creates a local cluster with Istio Sidecar mode enabled
	@echo "Created the cluster with Istio Sidecar mode"

.PHONY: destroy-cluster-sidecar
destroy-cluster-sidecar: export WORKING_PATH=$(ROOT_DIR)/examples/vind-with-istio-legacy
destroy-cluster-sidecar: destroy
destroy-cluster-sidecar: ## Destroys a previously created local cluster with Istio Sidecar mode enabled
	@echo "Destroyed the cluster with Istio Sidecar mode"

.PHONY: fmt
fmt: ## Performs auto-formatting of the code
	$(TF_BIN) fmt -recursive

.PHONY: lint
lint: ## Performs linting
	tflint --init
	tflint --recursive \
			--config="$(ROOT_DIR)/.tflint.hcl" \
			--minimum-failure-severity=warning

.PHONY: docs
docs: ## Generates documentation for all terraform modules
	@echo "## Generating documentation for all terraform modules"
	@for dir in $(shell find $(ROOT_DIR) -name '*.tf' -exec dirname {} \; | sort -u); do \
		terraform-docs -c "$(ROOT_DIR)/.tfdocs.yaml" "$$dir"; \
	done

init: ## Initializes the working directory
	cd $(WORKING_PATH)
	$(TF_BIN) init -upgrade -reconfigure
	$(TF_BIN) validate
	cd -

apply: ## Applies the terraform/tofu configuration
	cd $(WORKING_PATH)
	$(TF_BIN) apply -auto-approve
	cd -

destroy: ## Destroys the cluster and removes the config file
	cd $(WORKING_PATH)
	$(TF_BIN) destroy -auto-approve
	rm -f kindconfig || echo "File not found, skipping"
	cd -

