################################################################################
#
# IF91x Manufacturing Tools
#
# Pre-built binaries from TI-AM62x_03182026.zip
# (delivered via email 2026-03-18 by Infineon).
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
