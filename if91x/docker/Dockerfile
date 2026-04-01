FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Build dependencies for Buildroot
RUN apt-get update && apt-get install -y \
    bc \
    bison \
    build-essential \
    cpio \
    curl \
    file \
    flex \
    git \
    libncurses-dev \
    libssl-dev \
    locales \
    python3 \
    python3-setuptools \
    rsync \
    unzip \
    wget \
    cmake \
    pkg-config \
    python3-pip \
    zlib1g-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# repo tool
RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
    && chmod a+x /usr/local/bin/repo

# Build user (buildroot refuses to run as root)
RUN useradd -m -u 1001 -s /bin/bash builder
USER builder
WORKDIR /home/builder

# Git config (required by repo)
RUN git config --global user.email "builder@docker" \
    && git config --global user.name "Docker Builder" \
    && git config --global color.ui false

# Create dl cache dir (can be mounted from host for speed)
RUN mkdir -p /home/builder/.br2_dl_dir

# repo init + sync — all public repos, no credentials needed
RUN repo init \
        -u https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git \
        -b if91x-mfg \
        -m carbon_13.0.57.22_if91x_devel.xml \
        --depth=1 \
    && repo sync -j8

# Default: build the mfg image
CMD ["bash", "-c", "cd som-external && make carbon_am62x_if91x_mfg"]
