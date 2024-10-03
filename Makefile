.PHONY: build-plugin

build-plugin:
    go build -o bin/kubectl-dynamic-memory cmd/kubectl-plugins/dynamic-memory/main.go

install-plugin: build-plugin
    mv bin/kubectl-dynamic-memory /usr/local/bin/