NETWORK_SUPPORT_MENU:=Network Support

define KernelPackage/tcp-estats-nl
  SUBMENU:=$(NETWORK_SUPPORT_MENU)
  TITLE:=Web10g module
  DEPENDS:=
  KCONFIG:=CONFIG_TCP_ESTATS=y \
	   CONFIG_TCP_ESTATS_NETLINK
  FILES:=$(LINUX_DIR)/net/ipv4/tcp_estats_nl.ko
  #AUTOLOAD:=$(call AutoLoad,40,tcp_estats_nl)
endef

define KernelPackage/tcp-estats-nl/description
 Kernel module for Web10g
endef

$(eval $(call KernelPackage,tcp-estats-nl))



