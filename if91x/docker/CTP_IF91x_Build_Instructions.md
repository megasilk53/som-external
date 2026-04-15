# CTP IF91x Manufacturing Image — Build Instructions

Build instructions for the `ctp_if91x_mfg` image for the Infineon IF91x radio on the
Ezurio Summit i.MX8M Plus CTP (Common Test Platform). All repositories are public — no
credentials required.

## Manifest

All source is fetched via Google `repo` tool using this manifest:

```
URL:    https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git
Branch: if91x-mfg
File:   ctp_if91x_13.0.0.135_devel.xml
```

Source repositories referenced by the manifest:
- `megasilk53/som-external` branch `ctp-if91x-mfg` — SOM BSP + IF91x packages under `if91x/` subtree
- `Ezurio/wb-buildroot` tag `LRD-REL-13.0.0.135` — Buildroot
- `Ezurio/u-boot-som` tag `LRD-REL-13.0.57.22` — U-Boot (pinned: CTP support first landed in 13.0.57.x)
- `Ezurio/lrd-userspace-examples` tag `LRD-REL-13.0.0.135`
- `Ezurio/wb-kernel` tag `LRD-REL-13.0.0.135`

## Infineon Binary Stubs

The repository contains stub placeholder files for Infineon-supplied binaries:

- `som-external/if91x/package/summit-infhosted-backports/files/` — `compat.ko`, `cfg80211.ko`, `infutil.ko`, `infhosted.ko`
- `som-external/if91x/package/mfg-if91x/files/` — `ChipLoad`, `itool`

The image will build and boot with the stubs in place, and the SDIO bus scan will work
normally. Replace the stubs with the real binaries from Infineon if actual driver and
manufacturing utility functionality is required.

## Option A: Build Without Docker (Native Linux)

### Prerequisites

Ubuntu 22.04 host with the following packages:

```
sudo apt-get install -y bc bison build-essential cmake cpio curl file flex git \
    libncurses-dev libssl-dev locales pkg-config python3 python3-pip \
    python3-setuptools rsync unzip wget zlib1g-dev
sudo locale-gen en_US.UTF-8
```

Install the `repo` tool:

```
sudo curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo
```

### Fetch Source

```
mkdir ctp-if91x-build && cd ctp-if91x-build
repo init -u https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git \
    -b if91x-mfg -m ctp_if91x_13.0.0.135_devel.xml --depth=1
repo sync -j8
```

### Build

```
cd som-external
make ctp_if91x_mfg
```

Build output will be in `output/ctp_if91x_mfg/images/`:
- `ctp_if91x_mfg.swu` — firmware update image (use with `fw_update` on a running board)
- `sdcard.img.xz` — compressed SD card image for initial programming
- `ctp_if91x_mfg-summit-0.13.0.0.tar.bz2` — release archive (includes `mksdcard.sh`)

### Troubleshooting

If the parallel build fails, retry from within the output directory without parallelism:

```
cd output/ctp_if91x_mfg
make
```

This runs packages sequentially and will show the actual error clearly.

## Option B: Build With Docker

### Prerequisites

Docker installed on the host. No other dependencies required — everything is installed
inside the container.

### Dockerfile

A `Dockerfile` is provided in this directory (`if91x/docker/Dockerfile`). It performs
`repo init` and `repo sync` during `docker build` so the resulting image contains the
full source tree.

### Build the Docker Image

From the directory containing the `Dockerfile`:

```
docker build -t ctp-if91x-mfg:1.0 .
```

This step fetches source (~10–20 min).

### Run the Build

```
docker run --name ctp-if91x-build \
    -v ~/.br2_dl_dir:/home/builder/.br2_dl_dir \
    ctp-if91x-mfg:1.0
```

The `-v` mount shares the host's Buildroot download cache for faster builds. Omit it
for a fully isolated build (will download everything from scratch).

### Interactive Build

```
docker run -it \
    -v ~/.br2_dl_dir:/home/builder/.br2_dl_dir \
    ctp-if91x-mfg:1.0 bash
```

Then inside the container:

```
cd som-external && make ctp_if91x_mfg
```

### Extract Build Artifacts

```
docker cp ctp-if91x-build:/home/builder/output/ctp_if91x_mfg/images/ ./images/
```

Key artifacts:
- `images/sdcard.img.xz` — write to SD card with `bmaptool` or `dd`
- `images/ctp_if91x_mfg.swu` — OTA update

### Write SD Card

```
xzcat images/sdcard.img.xz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

Or with `bmaptool` (faster, uses `sdcard.img.bmap`):

```
sudo bmaptool copy images/sdcard.img.xz /dev/sdX
```

## Selecting the IF91x Radio Mode After Boot

After writing and booting the SD card, select the overlay matching your hardware:

| Hardware | Command |
|----------|---------|
| IF91x M.2 module in CTP slot | `set-radio-mode sdio-if91x` |
| IF91x DVK board via cable assembly | `set-radio-mode sdio-if91x-dvk` |

The command sets `conf` in the U-Boot environment and triggers a reboot. After reboot,
verify with:

```
fw_printenv conf
dmesg | grep -E 'mmc0|usdhc'
```

Expected on success (M.2 direct):

```
conf=conf-imx8mp-ctp-sdio-if91x.dtb
[    1.3x] mmc0: new ultra high speed DDR50 SDIO card at address 0001
```

## Loading the IF91x Driver

Once the SDIO card is enumerated, load the Infineon Hosted Mode driver:

```
load-infhosted.sh
```

This script loads `compat.ko`, `cfg80211.ko`, `infutil.ko`, and `infhosted.ko` in order.
With the stub binaries in place the script will be present but the modules will not
function — replace the stubs with the real Infineon NCP driver binaries first.

## Authors

Erik Strack & Claude (Anthropic Claude Code)
