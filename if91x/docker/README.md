# IF91x Manufacturing Image — Docker Build

Reproducible build of the `carbon_am62x_if91x_mfg` image in Docker. All repos are public — no credentials required.

## Manifest

```
https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git
Branch: if91x-mfg
File:   carbon_13.0.57.22_if91x_devel.xml
```

## Build

```
docker build -t if91x-mfg-repo:1.0 .
docker run --name if91x-build \
    -v ~/.br2_dl_dir:/home/builder/.br2_dl_dir \
    if91x-mfg-repo:1.0
```

The `-v` mount shares the host's Buildroot download cache for faster builds. Omit it for a fully isolated build (will download everything from scratch).

## Interactive

```
docker run -it \
    -v ~/.br2_dl_dir:/home/builder/.br2_dl_dir \
    if91x-mfg-repo:1.0 bash
```

Then:

```
cd som-external && make carbon_am62x_if91x_mfg
```

## Extract Build Artifacts

```
docker cp if91x-build:/home/builder/output/carbon_am62x_if91x_mfg/images/ ./images/
```

## Without Docker

```
repo init -u https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages.git \
    -b if91x-mfg -m carbon_13.0.57.22_if91x_devel.xml --depth=1
repo sync -j8
cd som-external && make carbon_am62x_if91x_mfg
```

## Rebuilding Docker Images

When rebuilding docker images, run the build from a directory under `~/projects/temp/`
so that the resulting images are automatically purged after 90 days:

```
mkdir -p ~/projects/temp/IF91x_docker_build && cd ~/projects/temp/IF91x_docker_build
cp -r /path/to/som-external/if91x/docker/* .
docker build -t if91x-mfg-repo:1.0 .
```

## Authors

Erik Strack & Claude (Anthropic Claude Code)
