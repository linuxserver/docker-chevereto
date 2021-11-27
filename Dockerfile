FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

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
    php8 \
    php8-ctype \
    php8-curl \
    php8-exif \
    php8-gd \
    php8-json \
    php8-mbstring \
    php8-pdo \
    php8-pdo_mysql \
    php8-zip \
    php8-session \
    php8-xml \
    php8-fileinfo && \
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
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

EXPOSE 80 443

VOLUME /config
