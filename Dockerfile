FROM alpine
MAINTAINER izikaj@gmail.com

RUN apk update && apk upgrade --available \
    && apk update && apk add --no-cache crystal openssl gmp yaml \
    && apk add --no-cache --virtual .build shards gcc g++ make openssl-dev gmp-dev yaml-dev zlib-dev \
    && mkdir -p /app \
    && cd / \
    && git clone https://github.com/kostya/myhtml.git myhtml \
    && cd /myhtml \
    && make

WORKDIR /app

COPY . ./

RUN shards update \
    && rm -rf bin/vat_ever \
    && mkdir -p bin \
    && crystal build src/vat_ever.cr -o bin/vat_ever --release --no-debug --stats --progress \
    && apk del .build \
    && rm -rf .shards lib dev spec shard* sentry* vat_ever*


EXPOSE 3000
CMD ["bin/vat_ever"]
