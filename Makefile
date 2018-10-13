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

MASTER_COUNT := 5
AGENT_COUNT := 10

.PHONY: test
test: shellcheck ## Runs all the tests.

.PHONY: shellcheck
shellcheck: ## Run shellcheck on all scripts in the repository.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name configs-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh

TERRAFORM_FLAGS = -var "client_id=$(CLIENT_ID)"  \
		-var "client_secret=$(CLIENT_SECRET)"  \
		-var "tenant_id=$(TENANT_ID)"  \
		-var "subscription_id=$(SUBSCRIPTION_ID)"  \
		-var "prefix=$(PREFIX)" \
		-var "location=$(LOCATION)" \
		-var "master_count=$(MASTER_COUNT)" \
		-var "agent_count="$(AGENT_COUNT)

MESOS_TFDIR=$(CURDIR)/mesos/terraform
.PHONY: mesos-init
mesos-init:
	@:$(call check_defined, CLIENT_ID, Azure Client ID)
	@:$(call check_defined, CLIENT_SECRET, Azure Client Secret)
	@:$(call check_defined, TENANT_ID, Azure Tenant ID)
	@:$(call check_defined, SUBSCRIPTION_ID, Azure Subscription ID)
	cd $(MESOS_TFDIR) && terraform init \
		$(TERRAFORM_FLAGS)

.PHONY: mesos-apply
mesos-apply: mesos-init ## Run terraform apply for mesos.
	cd $(MESOS_TFDIR) && terraform apply \
		$(TERRAFORM_FLAGS)

.PHONY: mesos-destroy
mesos-destroy: mesos-init ## Run terraform destroy for mesos.
	cd $(MESOS_TFDIR) && terraform destroy \
		$(TERRAFORM_FLAGS)

NOMAD_TFDIR=$(CURDIR)/nomad/terraform
.PHONY: nomad-init
nomad-init:
	@:$(call check_defined, CLIENT_ID, Azure Client ID)
	@:$(call check_defined, CLIENT_SECRET, Azure Client Secret)
	@:$(call check_defined, TENANT_ID, Azure Tenant ID)
	@:$(call check_defined, SUBSCRIPTION_ID, Azure Subscription ID)
	cd $(NOMAD_TFDIR) && terraform init \
		$(TERRAFORM_FLAGS)

.PHONY: nomad-apply
nomad-apply: nomad-init ## Run terraform apply for nomad.
	cd $(NOMAD_TFDIR) && terraform apply \
		$(TERRAFORM_FLAGS)

.PHONY: nomad-destroy
nomad-destroy: nomad-init ## Run terraform destroy for nomad.
	cd $(NOMAD_TFDIR) && terraform destroy \
		$(TERRAFORM_FLAGS)

TMPDIR:=$(CURDIR)/_tmp

.PHONY: update
update: update-terraform ## Run all update targets.

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
