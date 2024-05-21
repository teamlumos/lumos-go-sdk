COLOR_OK=\\x1b[0;32m
COLOR_NONE=\x1b[0m
COLOR_WARNING=\x1b[33;05m
COLOR_LUMOS=\x1B[34;01m
GOFMT := gofumpt
GOIMPORTS := goimports

help:
	@echo "$(COLOR_OK)Lumos SDK for Golang$(COLOR_NONE)"
	@echo ""
	@echo "$(COLOR_WARNING)Usage:$(COLOR_NONE)"
	@echo "$(COLOR_OK)  make [command]$(COLOR_NONE)"
	@echo ""
	@echo "$(COLOR_WARNING)Available commands:$(COLOR_NONE)"
	@echo "$(COLOR_OK)  build                   Generates files based around spec$(COLOR_NONE)"
	@echo "$(COLOR_OK)  pull-spec               Pull down the most recent released version of the spec$(COLOR_NONE)"


build:
	@echo "$(COLOR_LUMOS)Generating SDK Files...$(COLOR_NONE)"
	oapi-codegen -config cfg.yaml spec.json
	@echo "$(COLOR_OK)Running goimports and gofumpt on generated files...$(COLOR_NONE)"
	@make import
	@make fmt
	@echo "$(COLOR_LUMOS)Done!$(COLOR_NONE)"

pull-spec:
	@echo "$(COLOR_LUMOS)Pulling in latest spec...$(COLOR_NONE)"
	rm spec.json
	rm -rf spec-raw
	git clone https://github.com/teamlumos/lumos-openapi-spec spec-raw
	cp spec-raw/openapi.json spec.json
	rm -fr spec-raw

.PHONY: fmt
fmt: check-fmt # Format the code
	@$(GOFMT) -l -w $$(find . -name '*.go' |grep -v vendor) > /dev/null

check-fmt:
	@which $(GOFMT) > /dev/null || GO111MODULE=on go install mvdan.cc/gofumpt@v0.5.0

.PHONY: import
import: check-goimports
	@$(GOIMPORTS) -w $$(find . -path ./vendor -prune -o -name '*.go' -print) > /dev/null

check-goimports:
	@which $(GOIMPORTS) > /dev/null || GO111MODULE=on go install golang.org/x/tools/cmd/goimports@latest