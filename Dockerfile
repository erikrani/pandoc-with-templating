FROM pandoc/core:2.9 as pandoc-builder
FROM python:3.7-alpine as base

FROM base as builder
RUN mkdir /install
WORKDIR /install
RUN apk add --no-cache git &&
    git clone --branch 1.0.0 https://github.com/githubERIK/pandoc-mustache &&
    cd pandoc-mustache &&
    python setup.py sdist &&
    cd dist &&
    pip install pandoc-mustache-1.0.0.tar.gz pandoc-include==0.6.3 --install-option="--prefix=/install"

FROM base
COPY --from=builder /install /usr/local
COPY --from=pandoc-builder /usr/bin/pandoc* /usr/bin/
COPY --from=pandoc-builder /usr/local/bin/docker-entrypoint.sh /usr/local/bin
RUN apk add --no-cache \
    gmp \
    libffi \
    lua5.3 \
    lua5.3-lpeg

WORKDIR /data
ENTRYPOINT ["docker-entrypoint.sh"]
