################################################################################
#
# Infineon infhosted backports (IF91x hosted mode)
#
# Pre-built kernel modules and load script from TI-AM62x_03182026.zip
# (delivered via email 2026-03-18 by Infineon).
# compat.ko backported from v6.1.110-betelgeuse-infhost (Infineon tree).
#
################################################################################

SUMMIT_INFHOSTED_BACKPORTS_VERSION = local
SUMMIT_INFHOSTED_BACKPORTS_SITE = $(SUMMIT_INFHOSTED_BACKPORTS_PKGDIR)/files
SUMMIT_INFHOSTED_BACKPORTS_SITE_METHOD = local
SUMMIT_INFHOSTED_BACKPORTS_LICENSE = Infineon

define SUMMIT_INFHOSTED_BACKPORTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 644 $(@D)/compat.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/updates/compat/compat.ko
	$(INSTALL) -D -m 644 $(@D)/cfg80211.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/updates/net/wireless/cfg80211.ko
	$(INSTALL) -D -m 644 $(@D)/infutil.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/updates/drivers/net/wireless/infineon/infutil.ko
	$(INSTALL) -D -m 644 $(@D)/infhosted.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/updates/drivers/net/wireless/infineon/infhosted.ko
	$(INSTALL) -D -m 755 $(@D)/load-infhosted.sh \
		$(TARGET_DIR)/usr/sbin/load-infhosted.sh
	$(INSTALL) -D -m 644 $(@D)/infhosted-blacklist.conf \
		$(TARGET_DIR)/etc/modprobe.d/infhosted-blacklist.conf
endef

$(eval $(generic-package))
