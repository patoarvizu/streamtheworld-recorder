FROM golang:1.13 as builder

ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY streamtheworld.go streamtheworld.go
COPY podcast/podcast.go podcast/podcast.go

RUN CGO_ENABLED=0 GOOS=linux GOARM=$(if [ "$TARGETVARIANT" = "v7" ]; then echo "7"; fi) GOARCH=$TARGETARCH GO111MODULE=on go build -a -o stwr streamtheworld.go
RUN CGO_ENABLED=0 GOOS=linux GOARM=$(if [ "$TARGETVARIANT" = "v7" ]; then echo "7"; fi) GOARCH=$TARGETARCH GO111MODULE=on go build -a -o podcast podcast/podcast.go

FROM alpine:3.13.0

RUN apk -U add mplayer

WORKDIR /

COPY --from=builder /workspace/stwr .
COPY --from=builder /workspace/podcast .

ENTRYPOINT ["/stwr"]