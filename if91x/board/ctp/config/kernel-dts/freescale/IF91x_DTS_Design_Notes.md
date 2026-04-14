# CTP IF91x Device Tree Design Notes

## Overview

There are two DTS files for the IF91x, used with the `ctp_if91x_mfg` buildroot defconfig:

- **`imx8mp-ctp-sdio-if91x.dts`** — for the IF91x M.2 module plugged directly into the CTP's M.2 Key-E slot
- **`imx8mp-ctp-sdio-if91x-dvk.dts`** — for the IF91x DVK board connected via micro-coaxial cable assembly

Select with `set-radio-mode sdio-if91x` or `set-radio-mode sdio-if91x-dvk`.

Both include `imx8mp-ctp-sdio.dtsi`, which in turn includes `imx8mp-ctp.dtsi`.

## Two DTS files: M.2 vs DVK

Different carrier boards wire different M.2 W_DISABLE# pins to the IF91x MCU's
internal regulator:

- **IF91x M.2 module**: W_DISABLE2# (pin 54 / BT_REG_ON, GPIO3_IO22) drives the
  internal regulator. W_DISABLE1# (pin 56 / WL_REG_ON) is not connected on the module.
- **IF91x DVK board**: W_DISABLE1# (pin 56 / WL_REG_ON, GPIO2_IO06) drives the
  internal regulator. W_DISABLE2# is not used on the DVK.

The IF91x is a programmable MCU that loads its application from NVRAM at power-on —
unlike a normal radio with masked ROM startup. Whichever pin drives the regulator, the
MCU needs ~1 second to boot before it is ready for SDIO communication.

### imx8mp-ctp-sdio-if91x.dts (direct M.2 slot)

```
reg_usdhc1_vmmc (M2_3V3, GPIO1_IO11)
  → reg_m2_wdisable2 (W_DISABLE2#, GPIO3_IO22, 1s startup)
    → usdhc1 vmmc-supply
```

`reg_m2_wdisable1` has `regulator-always-on` removed so the pin stays LOW
(enable-active-high + disabled = LOW). This acts as a fail-safe: if a DVK user
accidentally selects this overlay, W_DISABLE1# stays LOW, the DVK's MCU will not boot,
and SDIO enumeration fails immediately.

### imx8mp-ctp-sdio-if91x-dvk.dts (micro-coaxial cable assembly)

```
reg_usdhc1_vmmc (M2_3V3, GPIO1_IO11)
  → reg_m2_wdisable1 (W_DISABLE1#, GPIO2_IO06, 1s startup)
    → usdhc1 vmmc-supply
```

`reg_m2_wdisable2` has `regulator-always-on` removed so the pin stays LOW. If an M.2
card user accidentally selects this overlay, W_DISABLE2# stays LOW, the M.2 module's
MCU will not boot, and SDIO enumeration fails immediately.

### Hardware verification results

| DTS | DVK (cable assembly) | M.2 card (direct slot) |
|-----|----------------------|------------------------|
| sdio-if91x-dvk | DDR50, enumerates ✓ | Fails (W_DISABLE2# LOW) ✓ |
| sdio-if91x | Fails (W_DISABLE1# LOW) ✓ | DDR50, enumerates ✓ |

## W_DISABLE GPIO Mapping

The W_DISABLE# signals route through the M.2 sideband level shifter (U4, LSF0204,
CTP schematic page 17):

| Signal | M.2 pin | CTP net | i.MX8MP pad | GPIO | Ball |
|--------|---------|---------|-------------|------|------|
| W_DISABLE1# (WL_REG_ON) | 56 | M2_WDISABLE1 via R401 0Ω | SD1_DATA4 | GPIO2_IO06 | U26 |
| W_DISABLE2# (BT_REG_ON) | 54 | M2_WDISABLE2 via R402 0Ω | SAI5_RXD1 | GPIO3_IO22 | AD16 |

GPIO authority: schematic (HW) → ball name → IMX8MPIEC.pdf ball map. DTS is
SW-written and not authoritative for GPIO assignments.

## Fail-Safe Design: Regulator Disable Instead of GPIO Hog

The unused W_DISABLE# pin is held LOW by disabling its `regulator-fixed` node (removing
`regulator-always-on`) rather than by a gpio-hog. This avoids a GPIO ownership conflict:
the `regulator-fixed` driver claims the GPIO when it probes, and a gpio-hog on the same
pin would conflict with it.

A disabled `regulator-fixed` with `enable-active-high` leaves the GPIO at its reset
state (LOW), which is the desired fail-safe output.

## Base DTSI Structure

`imx8mp-ctp-sdio.dtsi` defines both regulators as `regulator-always-on` with no
`vin-supply` or startup delay. The per-hardware DTS files override the active regulator
(add vin-supply + 1s startup, remove always-on) and disable the inactive one (remove
always-on only).

`pinctrl_m2_wdisable2` (SAI5_RXD1/GPIO3_IO22) is defined in `imx8mp-ctp.dtsi` alongside
`pinctrl_pcie_disable` (SD1_DATA4/GPIO2_IO06).

## Authors

Erik Strack & Claude (Anthropic Claude Code)
