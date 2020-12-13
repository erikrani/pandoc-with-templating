FROM pandoc/core:2.11.2 as pandoc-builder
FROM python:3.9.1-alpine3.12 as base

FROM base as builder
WORKDIR /tmp
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN apk add --no-cache git && \
    git -c advice.detachedHead=false clone --branch 2.0.0 https://github.com/githubERIK/pandoc-mustache && \
    cd pandoc-mustache && \
    pip install --upgrade --no-cache-dir pip wheel && \
    pip install --no-cache-dir pandoc-include==0.8.4 .

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
