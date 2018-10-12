# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

check_defined = \
				$(strip $(foreach 1,$1, \
				$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
				  $(if $(value $1),, \
				  $(error Undefined $1$(if $2, ($2))$(if $(value @), \
				  required by target `$@')))

CLIENT_ID := ${AZURE_CLIENT_ID}
CLIENT_SECRET := ${AZURE_CLIENT_SECRET}
TENANT_ID := ${AZURE_TENANT_ID}
SUBSCRIPTION_ID := ${AZURE_SUBSCRIPTION_ID}

PREFIX := jessfraz
LOCATION := West US 2

.PHONY: test
test: shellcheck ## Runs all the tests.

.PHONY: shellcheck
shellcheck: ## Run shellcheck on all scripts in the repository.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name configs-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh

.PHONY: image
image: az-apply-0 ## Build the packer image.
	@:$(call check_defined, CLIENT_ID, Azure Client ID)
	@:$(call check_defined, CLIENT_SECRET, Azure Client Secret)
	@:$(call check_defined, TENANT_ID, Azure Tenant ID)
	@:$(call check_defined, SUBSCRIPTION_ID, Azure Subscription ID)
	packer build \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)" \
		$(CURDIR)/packer.json

AZURE_TFDIR0=$(CURDIR)/0-terraform
.PHONY: az-init-0
az-init-0:
	@:$(call check_defined, CLIENT_ID, Azure Client ID)
	@:$(call check_defined, CLIENT_SECRET, Azure Client Secret)
	@:$(call check_defined, TENANT_ID, Azure Tenant ID)
	@:$(call check_defined, SUBSCRIPTION_ID, Azure Subscription ID)
	@cd $(AZURE_TFDIR0) && terraform init \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)"

.PHONY: az-apply-0
az-apply-0: az-init-0
	@cd $(AZURE_TFDIR0) && terraform apply \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)"

AZURE_TFDIR1=$(CURDIR)/1-terraform
.PHONY: az-init-1
az-init-1:
	@:$(call check_defined, CLIENT_ID, Azure Client ID)
	@:$(call check_defined, CLIENT_SECRET, Azure Client Secret)
	@:$(call check_defined, TENANT_ID, Azure Tenant ID)
	@:$(call check_defined, SUBSCRIPTION_ID, Azure Subscription ID)
	@cd $(AZURE_TFDIR1) && terraform init \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)"

.PHONY: az-apply
az-apply: az-init-1 ## Run terraform apply for Azure.
	@cd $(AZURE_TFDIR1) && terraform apply \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)"

.PHONY: az-destroy
az-destroy: az-init-1 ## Run terraform destroy for Azure.
	@cd $(AZURE_TFDIR1) && terraform destroy \
		-var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)"

TMPDIR:=$(CURDIR)/_tmp

.PHONY: update
update: update-packer update-terraform ## Run all update targets.

PACKER_BINARY:=$(shell which packer || echo "/usr/local/bin/packer")
TMP_PACKER_BINARY:=/tmp/packer
.PHONY: update-packer
update-packer: ## Update packer binary locally from the docker container.
	@echo "Updating packer binary..."
	$(shell docker run --rm --entrypoint bash r.j3ss.co/packer -c "cd \$\$$(dirname \$\$$(which packer)) && tar -Pc packer" | tar -xvC $(dir $(TMP_PACKER_BINARY)) > /dev/null)
	sudo mv $(TMP_PACKER_BINARY) $(PACKER_BINARY)
	sudo chmod +x $(PACKER_BINARY)
	@echo "Update packer binary: $(PACKER_BINARY)"
	@packer version

TERRAFORM_BINARY:=$(shell which terraform || echo "/usr/local/bin/terraform")
TMP_TERRAFORM_BINARY:=/tmp/terraform
.PHONY: update-terraform
update-terraform: ## Update terraform binary locally from the docker container.
	@echo "Updating terraform binary..."
	$(shell docker run --rm --entrypoint bash r.j3ss.co/terraform -c "cd \$\$$(dirname \$\$$(which terraform)) && tar -Pc terraform" | tar -xvC $(dir $(TMP_TERRAFORM_BINARY)) > /dev/null)
	sudo mv $(TMP_TERRAFORM_BINARY) $(TERRAFORM_BINARY)
	sudo chmod +x $(TERRAFORM_BINARY)
	@echo "Update terraform binary: $(TERRAFORM_BINARY)"
	@terraform version

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
