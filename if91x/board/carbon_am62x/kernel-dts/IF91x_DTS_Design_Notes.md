# Carbon AM62x IF91x Device Tree Overlay

## Overview

There are two overlays for the IF91x, used with the `carbon_am62x_if91x_mfg` buildroot defconfig:

- **`m2-sdio-if91x`** — for the IF91x M.2 module plugged directly into the Carbon's M.2 slot
- **`m2-sdio-if91x-dvk`** — for the IF91x DVK board connected via micro-coaxial cable assembly

Select with `set-mode m2-sdio-if91x` or `set-mode m2-sdio-if91x-dvk`.

## Two overlays: M.2 vs DVK

Different carrier boards wire different M.2 pins to the IF91x MCU's internal regulator:

- **Ezurio IF91x M.2 module**: W_DISABLE2# (pin 54 / BT_REG_ON) drives the internal regulator. W_DISABLE1# (pin 56 / WL_REG_ON) is not connected on the module.
- **IF91x DVK board**: W_DISABLE1# (pin 56 / WL_REG_ON) drives the internal regulator. W_DISABLE2# is not used.

The IF91x is a programmable MCU that loads its application from NVRAM at power-on — unlike a normal radio with masked ROM startup. Whichever pin drives the regulator, the MCU needs ~1s to boot before it is ready for SDIO communication. 250ms is insufficient.

### m2-sdio-if91x (direct M.2 slot)

```
vcc_wifi_m2 (M2_POWER_EN, always-on)
  → reg_bt_en_m2 (W_DISABLE2#, 1s startup)
    → sdhci1 vmmc-supply
```

W_DISABLE1# is forced LOW via GPIO hog. This ensures that if a DVK user accidentally selects this overlay, the DVK's MCU will not boot and SDIO enumeration will fail immediately — prompting them to use the correct DVK overlay. SDIO runs at DDR50 (UHS).

### m2-sdio-if91x-dvk (micro-coaxial cable assembly)

```
vcc_wifi_m2 (M2_POWER_EN, always-on)
  → reg_wifi_en_m2 (W_DISABLE1#, 1s startup)
    → sdhci1 vmmc-supply
```

The DVK connects to the Carbon via a cable assembly.

W_DISABLE2# is forced LOW via GPIO hog. This ensures that if an M.2 card user accidentally selects this overlay, the M.2 card's MCU will not boot and SDIO enumeration will fail immediately.

### Hardware verification results

| Overlay | DVK (cable assembly) | M.2 card (direct slot) |
|---------|-------------------|----------------------|
| m2-sdio-if91x-dvk | HS, enumerates ✓ | Fails (W_DISABLE2# LOW) ✓ |
| m2-sdio-if91x | Fails (W_DISABLE1# LOW) ✓ | DDR50, enumerates, wlan0 created ✓ |

## Comparison with m2-ifx-sdio (LWB/IF5xx) overlay

The IF91x overlays differ from the standard IFX/LWB overlay (`k3-am625-carbon-m2-ifx-sdio.dtso`) in several key ways:

### W_DISABLE signals

On LWB/IF5xx radios, W_DISABLE1# is driven by the MMC controller via `reg_wifi_en_m2` as `vmmc-supply`, and W_DISABLE2# (BT_REG_ON) is driven by the Bluetooth driver via `shutdown-gpios` on the BT serdev node. The BT driver toggles BT_REG_ON as part of Bluetooth initialization.

On the IF91x, there is no Bluetooth driver — the infhosted driver handles all radio functionality in Hosted Mode. The W_DISABLE signals are modeled as `regulator-fixed` nodes so the MMC controller sequences them on slot power-on/off/reset.

### No WiFi compatible string

The IFX overlay specifies `compatible = "brcm,bcm4329-fmac"` on the `wifi@1` node, which causes the kernel to auto-probe the brcmfmac driver. The IF91x overlay omits the compatible string because the infhosted driver is manually loaded via `load-infhosted.sh` — there is no in-tree driver to auto-bind.

### No Bluetooth serdev node

The IFX overlay defines a full `brcm,bcm4329-bt` serdev child node on `mcu_uart0` with autobaud, shutdown-gpios, and wakeup-gpios. The IF91x overlay intentionally does NOT define a serdev node — `mcu_uart0` is enabled but left accessible to userspace. This is required so that the `ChipLoad` utility can program the IF91x module's MCU over UART from userspace, and for out-of-band WiFi network configuration in Hosted Mode.

### UART mapping

`mcu_uart0` (serial@4a00000) is aliased as `serial5` in `k3-am625-carbon-som.dtsi`, which maps to **`/dev/ttyS5`** on Linux (UART_B on the Carbon DVK). This is the peripheral UART used by `ChipLoad` and for out-of-band Hosted Mode configuration.

```
dmesg: 4a00000.serial: ttyS5 at MMIO 0x4a00000
DTS:   aliases { serial5 = &mcu_uart0; /* UART_B */ }
```

## Repository History

This IF91x content was moved to `megasilk53/som-external` (branch `if91x-mfg`, under `if91x/` subtree) so it could be fully and readily accessed by external parties (Infineon) on a private branch of the public Ezurio repo — no credentials required for `repo init/sync` or Docker builds.

Manifest: [`megasilk53/Summit-SOM-Buildroot-Release-Packages`](https://github.com/megasilk53/Summit-SOM-Buildroot-Release-Packages) branch `if91x-mfg`, file `carbon_13.0.57.22_if91x_devel.xml`.

Original development was on [`megasilk53/cp_linux-summit-radio-devel-external`](https://github.com/megasilk53/cp_linux-summit-radio-devel-external/tree/if91x-mfg) branch `if91x-mfg` (private, unmaintained). Future internal work should consider moving back to `summit-radio-devel-external`.

## Authors

Erik Strack & Claude (Anthropic Claude Code)
