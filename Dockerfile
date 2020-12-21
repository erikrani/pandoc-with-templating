FROM pandoc/core:2.11.2 as pandoc-builder
FROM python:3.9.1-alpine3.12 as base

FROM base as builder
WORKDIR /tmp
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN apk add --no-cache git && \
    pip install --no-cache-dir --upgrade pip wheel && \
    pip install --no-cache-dir \
        git+https://github.com/githubERIK/pandoc-mustache.git@2.0.0 \
        pandoc-include==0.8.4

FROM base
WORKDIR /data
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=builder /opt/venv /opt/venv
COPY --from=pandoc-builder /usr/local/bin /usr/local/bin

RUN apk add --no-cache \
    gmp \
    libffi \
    lua5.3 \
    lua5.3-lpeg
ENTRYPOINT ["/usr/local/bin/pandoc"]
