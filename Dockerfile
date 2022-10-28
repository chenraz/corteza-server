# deploy stage
FROM ubuntu:22.04

RUN apt-get -y update \
 && apt-get -y install \
    ca-certificates \
    curl \
 && rm -rf /var/lib/apt/lists/*

ARG VERSION=2022.9
ARG SERVER_VERSION=${VERSION}
ARG CORTEZA_LOCALE_PATH=https://github.com/chenraz/corteza-locale/archive/refs/tags/tilnet.${VERSION}.tar.gz
ARG CORTEZA_EXT_PATH=https://github.com/chenraz/corteza-ext/archive/refs/tags/tilnet.${VERSION}.tar.gz
VOLUME /data

RUN mkdir -p /tmp/corteza/locale
RUN mkdir /tmp/corteza/ext
RUN mkdir /corteza-locale
RUN mkdir /corteza-ext

ADD $CORTEZA_LOCALE_PATH /tmp/corteza/locale
RUN tar -zxvf "/tmp/corteza/locale/$(basename $CORTEZA_LOCALE_PATH)" --strip-components=1 -C /corteza-locale/ 

ADD $CORTEZA_EXT_PATH /tmp/corteza/ext
RUN tar -zxvf "/tmp/corteza/ext/$(basename $CORTEZA_EXT_PATH)" --strip-components=1 -C /corteza-ext/ && \
    rm -rf "/tmp/corteza"    

WORKDIR /corteza

COPY . ./
COPY ./build/* ./bin/corteza-server

HEALTHCHECK --interval=30s --start-period=1m --timeout=30s --retries=3 \
    CMD curl --silent --fail --fail-early http://127.0.0.1:80/healthcheck || exit 1

ENV STORAGE_PATH "/data"
ENV CORREDOR_ADDR "corredor:80"
ENV HTTP_ADDR "0.0.0.0:80"
ENV HTTP_WEBAPP_ENABLED "false"
ENV PATH "/corteza/bin:${PATH}"
ENV LOCALE_PATH=/corteza-locale/src
ENV AUTH_ASSETS_PATH=""


EXPOSE 80

ENTRYPOINT ["./bin/corteza-server"]

CMD ["serve-api"]
