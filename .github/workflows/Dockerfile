ARG K_VERSION=7.1.323
FROM runtimeverificationinc/kframework-k:ubuntu-noble-${K_VERSION}

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# LLVM/Java 由匹配版本的 K 包提供，避免额外混入旧 LLVM。
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        build-essential ca-certificates cmake curl git \
        bison flex pkg-config libjsoncpp-dev \
        python3 python3-pip python3-venv \
        verilator iverilog \
    && rm -rf /var/lib/apt/lists/*

ARG CIRCT_VERSION=1.71.0
RUN curl --fail --location --retry 3 \
        "https://github.com/llvm/circt/releases/download/firtool-${CIRCT_VERSION}/circt-full-static-linux-x64.tar.gz" \
        --output /tmp/circt.tar.gz \
    && mkdir -p /opt/circt \
    && tar -xzf /tmp/circt.tar.gz -C /opt/circt --strip-components=1 \
    && rm /tmp/circt.tar.gz \
    && test -x /opt/circt/bin/arcilator

ARG POETRY_VERSION=2.4.1
RUN python3 -m venv /opt/poetry \
    && /opt/poetry/bin/pip install --no-cache-dir "poetry==${POETRY_VERSION}"

ARG USER_ID=1001
ARG GROUP_ID=1001
# Ubuntu 基础镜像可能已有相同 GID；不重复创建组。
RUN if ! getent group "${GROUP_ID}" >/dev/null; then groupadd --gid "${GROUP_ID}" github-user; fi \
    && useradd --non-unique --uid "${USER_ID}" --gid "${GROUP_ID}" \
        --create-home --shell /bin/bash github-user

ENV PATH="/opt/poetry/bin:/opt/circt/bin:${PATH}" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    PYTHONUNBUFFERED=1

USER github-user
WORKDIR /workspace
