#configuration

TF = docker compose run --rm terraform
.PHONY: init validate plan apply destroy

init:
	$(TF) init

initup:
	$(TF) init -upgrade

validate:
	$(TF) validate

plan:
	$(TF) plan

apply:
	$(TF) apply

version:
	$(TF) version