FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    bc bison bmap-tools build-essential cmake cpio curl dosfstools \
    e2fsprogs fdisk file flex git libncurses-dev libssl-dev locales \
    mtools pkg-config python3 python3-pip python3-setuptools rsync ssh \
    unzip wget zlib1g-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
    && chmod a+x /usr/local/bin/repo

RUN useradd -m -s /bin/bash builder
USER builder
WORKDIR /home/builder

RUN git config --global user.email "builder@docker" \
    && git config --global user.name "Docker Builder" \
    && git config --global color.ui false

RUN mkdir -p /home/builder/.br2_dl_dir

RUN repo init \
        -u https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git \
        -b if91x-mfg \
        -m ctp_if91x_13.0.0.135_devel.xml \
        --depth=1 \
    && repo sync -j8

CMD ["bash", "-c", "cd som-external && make ctp_if91x_mfg && cd /home/builder/output/ctp_if91x_mfg/images && bash mksdimg.sh sdcard.img"]
