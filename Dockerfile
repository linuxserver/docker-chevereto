FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CHEVERETO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    composer && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    curl \
    php8 \
    php8-ctype \
    php8-curl \
    php8-exif \
    php8-fileinfo \
    php8-gd \
    php8-json \
    php8-mbstring \
    php8-pdo \
    php8-pdo_mysql \
    php8-phar \
    php8-session \
    php8-xml \
    php8-zip && \
  echo "**** install chevereto-free ****" && \
  mkdir -p /app/www/public && \
  if [ -z ${CHEVERETO_RELEASE+x} ]; then \
    CHEVERETO_RELEASE=$(curl -sX GET "https://api.github.com/repos/rodber/chevereto-free/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/chevereto.tar.gz -L \
    "https://github.com/rodber/chevereto-free/archive/${CHEVERETO_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/chevereto.tar.gz -C \
    /app/www/public/ --strip-components=1 && \
  cd /app/www/public && \
  composer install && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /root/.composer \
    /tmp/*

# copy local files
COPY root/ /

EXPOSE 80 443

VOLUME /config
