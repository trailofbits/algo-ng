.PHONY: deploy lightsail

BASE_DIR := base/

deploy:
	# terraform -chdir=$(BASE_DIR) init
	# terraform -chdir=$(BASE_DIR) validate
	terraform -chdir=$(BASE_DIR) apply

lightsail:
	$(MAKE) deploy BASE_DIR=base/lightsail/

