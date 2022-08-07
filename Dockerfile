FROM golang:alpine

WORKDIR /build

COPY go-web.go .

EXPOSE 8081

RUN go build go-web.go

RUN chmod +x /build/go-web

CMD ["/build/go-web"]
