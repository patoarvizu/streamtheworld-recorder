FROM golang:1.21 as builder

ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY streamtheworld.go streamtheworld.go
COPY podcast/podcast.go podcast/podcast.go

RUN CGO_ENABLED=0 GOOS=linux GOARM=$(if [ "$TARGETVARIANT" = "v7" ]; then echo "7"; fi) GOARCH=$TARGETARCH GO111MODULE=on go build -o stwr streamtheworld.go
RUN CGO_ENABLED=0 GOOS=linux GOARM=$(if [ "$TARGETVARIANT" = "v7" ]; then echo "7"; fi) GOARCH=$TARGETARCH GO111MODULE=on go build -o podcast-feed podcast/podcast.go

FROM alpine:3.19.0

RUN apk -U add mplayer ffmpeg

WORKDIR /

COPY --from=builder /workspace/stwr .
COPY --from=builder /workspace/podcast-feed .

ENTRYPOINT ["/stwr"]