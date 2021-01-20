FROM golang:1.13 as builder

ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY streamtheworld.go streamtheworld.go

RUN CGO_ENABLED=0 GOOS=linux GOARM=$(if [ "$TARGETVARIANT" = "v7" ]; then echo "7"; fi) GOARCH=$TARGETARCH GO111MODULE=on go build -a -o stwr streamtheworld.go

FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get install mplayer -y

WORKDIR /

COPY --from=builder /workspace/stwr .

ENTRYPOINT ["/stwr"]