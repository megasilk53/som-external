################################################################################
#
# IF91x Manufacturing Tools
#
# Pre-built binaries (itool, ChipLoad).
# Place the actual binaries from the Infineon package drop into
# if91x/package/mfg-if91x/files/ before building.
#
################################################################################

MFG_IF91X_VERSION = local
MFG_IF91X_SITE = $(MFG_IF91X_PKGDIR)/files
MFG_IF91X_SITE_METHOD = local
MFG_IF91X_LICENSE = Infineon

define MFG_IF91X_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/itool $(TARGET_DIR)/usr/bin/itool
	$(INSTALL) -D -m 755 $(@D)/ChipLoad $(TARGET_DIR)/usr/bin/ChipLoad
endef

$(eval $(generic-package))
