# syntax=docker/dockerfile:1

ARG GO_VERSION=1.27

# ------------------------------------------------------------
# dev: 開発用ステージ (ソースはボリュームマウントで共有)
# ------------------------------------------------------------
FROM golang:${GO_VERSION}-bookworm AS dev

WORKDIR /app

ENV GOFLAGS=-buildvcs=false

CMD ["go", "test", "./..."]

# ------------------------------------------------------------
# builder: 本番用バイナリのビルド
# ------------------------------------------------------------
FROM golang:${GO_VERSION}-bookworm AS builder

WORKDIR /src

ENV CGO_ENABLED=0

COPY go.mod go.sum* ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o /out/app .

# ------------------------------------------------------------
# runtime: 実行用の最小イメージ
# ------------------------------------------------------------
FROM gcr.io/distroless/static-debian12:nonroot AS runtime

WORKDIR /app
COPY --from=builder /out/app /app/app

USER nonroot:nonroot
ENTRYPOINT ["/app/app"]
