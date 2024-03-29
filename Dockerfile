FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CHEVERETO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --update --no-cache \
    curl \
    composer \
    php7 \
    php7-ctype \
    php7-curl \
    php7-exif \
    php7-gd \
    php7-json \
    php7-mbstring \
    php7-pdo \
    php7-pdo_mysql \
    php7-zip \
    php7-session \
    php7-xml \
    php7-fileinfo && \
  echo "**** install chevereto-free ****" && \
  mkdir -p /app/chevereto && \
  if [ -z ${CHEVERETO_RELEASE+x} ]; then \
    CHEVERETO_RELEASE=$(curl -sX GET "https://api.github.com/repos/rodber/chevereto-free/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/chevereto.tar.gz -L \
    "https://github.com/rodber/chevereto-free/archive/${CHEVERETO_RELEASE}.tar.gz" && \
  tar xf \
  /tmp/chevereto.tar.gz -C \
    /app/chevereto/ --strip-components=1 && \
  cd /app/chevereto && \
  composer install && \
  echo "**** cleanup ****" && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

EXPOSE 80 443

VOLUME /config
