ARG K_VERSION
ARG LLVM_VERSION


ARG K_VERSION
FROM runtimeverificationinc/kframework-k:ubuntu-jammy-${K_VERSION}

ARG LLVM_VERSION

RUN    apt-get update                  \
    && apt-get upgrade --yes           \
    && apt-get install --yes           \
            clang-${LLVM_VERSION}      \
            cmake                      \
            curl                       \
            debhelper                  \
            libboost-test-dev          \
            libcrypto++-dev            \
            libsecp256k1-dev           \
            libssl-dev                 \
            libyaml-dev                \
            llvm-${LLVM_VERSION}-dev   \
            llvm-${LLVM_VERSION}-tools \
            maven                      \
            python3                    \
            python3-pip

ARG USER=user
ARG GROUP
ARG USER_ID
ARG GROUP_ID
RUN groupadd -g ${GROUP_ID} ${GROUP} && useradd -m -u ${USER_ID} -s /bin/sh -g ${GROUP} ${USER}

USER ${USER}:${GROUP}
RUN mkdir /home/${USER}/workspace
WORKDIR /home/${USER}/workspace

ENV PATH=/home/${USER}/.local/bin:${PATH}
COPY --from=builder /workspace/firtool-1.71.0 /opt/firtool
ENV PATH="/opt/firtool/bin:${PATH}"

RUN    curl -sSL https://install.python-poetry.org | python3 - --version 1.8.3 \
    && poetry --version