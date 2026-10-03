# ------------------------------------------------------------
# 変数
# ------------------------------------------------------------
MODULE  ?= github.com/fukazawasoftwaredevelopment/build-your-own-database-from-scratch-in-go
IMAGE   ?= byodb
COMPOSE := docker compose
RUN     := $(COMPOSE) run --rm app

.DEFAULT_GOAL := help

# ------------------------------------------------------------
# ヘルプ
# ------------------------------------------------------------
.PHONY: help
help: ## ターゲット一覧を表示
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------
# Docker
# ------------------------------------------------------------
.PHONY: docker-build
docker-build: ## 開発用イメージをビルド
	$(COMPOSE) build

.PHONY: shell
shell: ## 開発コンテナのシェルに入る
	$(RUN) bash

.PHONY: down
down: ## コンテナを停止・削除
	$(COMPOSE) down

.PHONY: clean
clean: ## コンテナ・ボリューム・成果物を削除
	$(COMPOSE) down -v --remove-orphans
	rm -rf bin coverage.out

# ------------------------------------------------------------
# Go (コンテナ内で実行)
# ------------------------------------------------------------
.PHONY: init
init: ## go.mod を作成 (MODULE=... で変更可)
	$(RUN) go mod init $(MODULE)

.PHONY: tidy
tidy: ## go mod tidy
	$(RUN) go mod tidy

.PHONY: run
run: ## アプリを実行
	$(RUN) go run .

.PHONY: build
build: ## バイナリを bin/ にビルド
	$(RUN) go build -o bin/app .

.PHONY: test
test: ## テストを実行
	$(RUN) go test -race ./...

.PHONY: cover
cover: ## カバレッジ付きでテストを実行
	$(RUN) sh -c 'go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out'

.PHONY: bench
bench: ## ベンチマークを実行
	$(RUN) go test -run=^$$ -bench=. -benchmem ./...

.PHONY: fmt
fmt: ## コードを整形
	$(RUN) gofmt -s -w .

.PHONY: vet
vet: ## go vet で静的解析
	$(RUN) go vet ./...

.PHONY: check
check: fmt vet test ## fmt + vet + test

# ------------------------------------------------------------
# 本番イメージ
# ------------------------------------------------------------
.PHONY: image
image: ## 本番用 (distroless) イメージをビルド
	docker build --target runtime -t $(IMAGE):latest .
