# Force an amd64 build as arm does not work with some if the older python
# and packages
FROM --platform=linux/amd64 debian:buster-slim

ARG USER=uv
ARG USER_HOME=/home/${USER}

# Create a non-root user and group
RUN groupadd --system ${USER} \
    && useradd --system --gid ${USER} -m -d ${USER_HOME} --shell /bin/bash ${USER}

RUN chown -R ${USER}:${USER} ${USER_HOME}

# Set shell environment for user's homedir
ENV HOME=${USER_HOME}

# Working directory to copy files over
WORKDIR ${USER_HOME}

# Install needed tools and libraries (needed for building python)
# See https://github.com/pyenv/pyenv/blob/master/Dockerfile
RUN apt update \
    && apt install -y \
    --no-install-recommends \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \
    git \
    curl \
    ca-certificates \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ${USER_HOME}/.cache

# Install the tools as non-root user
USER ${USER}

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

# Download the uv installer
ADD --chown=${USER}:${USER} https://astral.sh/uv/install.sh ./uv-installer.sh

# Run the installer
RUN sh ./uv-installer.sh && rm ./uv-installer.sh

# Configure pyenv
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:${PATH}"
RUN eval "$(pyenv init -)"

# Configure uv
ENV UV_COMPILE_BYTECODE=1
# Copy from the cache instead of linking since we are using a mounted volume
ENV UV_LINK_MODE=copy

# Install python 3.8 and 3.9
RUN uv python install 3.8.11
RUN uv python install 3.9.22

# Install python 3.7
# Use uv to install 3.8 and 3.9, but 3.7.5 isn't available on uv
# This is to demonstrate how we can handle older python versions that are
# not supported by uv.
RUN pyenv install 3.7.5

# Make 3.7 the default python version
# uv should discover this version through the shim.
RUN pyenv global 3.7.5

# Shell prompt
COPY --chown=${USER}:${USER} .bashrc .

# Run a shell for interactive mode
CMD ["/bin/bash"]