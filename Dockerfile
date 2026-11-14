FROM ubuntu:26.04

# Match host UID/GID so files written to the mount aren't owned by root
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Base tooling: Claude Code needs curl/git/ripgrep; the rest is for C++/Python work
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git ripgrep less procps sudo \
        build-essential cmake gdb \
        python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu images ship a default 'ubuntu' user at UID 1000; remove it to free the UID
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupdel ubuntu 2>/dev/null || true \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# All Claude Code config + credentials live here; compose mounts a named volume on it.
# Absolute path on purpose (a "~" path can be mis-resolved).
ENV CLAUDE_CONFIG_DIR=/home/${USERNAME}/.claude-config
RUN mkdir -p ${CLAUDE_CONFIG_DIR} /workspace \
    && chown -R ${USER_UID}:${USER_GID} ${CLAUDE_CONFIG_DIR} /workspace

USER ${USERNAME}

# Official native installer; drops the binary in ~/.local/bin
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

WORKDIR /workspace
CMD ["sleep", "infinity"]
