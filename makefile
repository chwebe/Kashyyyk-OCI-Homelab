#configuration

TF = docker compose run --rm terraform
.PHONY: init validate plan apply destroy

init:
	$(TF) init

validate:
	$(TF) validate

plan:
	$(TF) plan

apply:
	$(TF) apply