.PHONY: init fmt validate lint scan test all

init:
	terraform init -backend=false

fmt:
	terraform fmt -recursive

validate: init
	terraform validate

lint:
	tflint --init && tflint

# Compliance scanners. Run after every small change and watch the failure count drop.
scan:
	checkov -d . --framework terraform --compact --quiet
	trivy config --severity HIGH,CRITICAL .

# Unit tests: plan only, mock provider, safe anywhere. Integration tests (tests/integration) create real
# resources and are run by the human only: terraform test -test-directory=tests/integration
test: init
	terraform test -test-directory=tests/unit

all: fmt validate lint test scan
