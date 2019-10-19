# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: default build test test_coverage lint bench setup

default: lint

# Build code with readonly to verify go.mod is up to date in CI.
build:
	go build -mod=readonly ./...

# Test code with race detector. Also tests benchmarks (but only for 1ns so they at least run once).
test:
	env "GORACE=halt_on_error=1" go test -v -benchtime 1ns -bench . -race ./...

# Test code with coverage.  Separate from 'test' since covermode=atomic is slow.
test_coverage:
	env "GORACE=halt_on_error=1" go test -v -benchtime 1ns -bench . -covermode=count -coverprofile=coverage.out ./...

# Lint code for static code checking. Uses golangci-lint.
lint:
	@golangci-lint run \
	--deadline 3m \
	--disable-all \
	--enable deadcode \
	--enable depguard \
	--enable dupl \
	--enable errcheck \
	--enable gochecknoinits \
	--enable goconst \
	--enable gocritic \
	--enable gocyclo \
	--enable gofmt \
	--enable goimports \
	--enable golint \
	--enable gosec \
	--enable gosimple \
	--enable govet \
	--enable ineffassign \
	--enable interfacer \
	--enable maligned \
	--enable megacheck \
	--enable misspell \
	--enable nakedret \
	--enable prealloc \
	--enable scopelint \
	--enable staticcheck \
	--enable structcheck \
	--enable stylecheck \
	--enable typecheck \
	--enable unconvert \
	--enable unparam \
	--enable unused \
	--enable varcheck

# Bench runs benchmarks. The ^$ means it runs no tests, only benchmarks.
bench:
	go test -v -benchmem -run=^$$ -bench=. ./...

setup:
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(go env GOPATH)/bin v1.21.0

# # The exact version of CI tools should be specified in your go.mod file and referenced inside your tools.go file
# setup:
# 	go install github.com/golangci/golangci-lint/cmd/golangci-lint
