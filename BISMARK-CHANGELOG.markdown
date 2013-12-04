Release Information
===================

 - Release name:   Lancre 2013.12
 - Release status: Stable Release
 - Release date:   04 December 2013

Changes since 'Quirm' 2012.04 release
=====================================

added
-----

- packages/bismark-cron
    - Manages the router's crontab on behalf of packages, so they don't need to
      manually manipulate the crontab.

- packages/bismark-health
    - Sends router health information (e.g., CPU, flash, and memory utilization)
      to Georgia Tech once hour.

- packages/bismark-opkg-keys
    - Contains certifcates used to verify the software updates that routers
      automatically download from https://downloads.projectbismark.net.

- packages/bismark-registration
    - Directs new BISmark users to register their router at
      https://register.projectbismark.net. This feature helps us track the
      location, ISP, and contact information for each router.

- packages/luci-app-bismark-packages and
  packages/luci-app-bismark-experiments-manager
    - Extracted from https://github.com/projectbismark/luci-bismark

changed
-------

- upstream: OpenWrt 'Attitude Adjustment' 12.09
  - This release, codenamed 'Lancre', is based on the OpenWrt
    <http://openwrt.org> 'Attitude Adjustment' 12.09 release.

- kernel patched with web10g support. web100 no longer works on lancre.

- base distribution
  - opkg-bismark is now compiled with OpenSSL support so that it may verify
    package signatures.
  - bismark-mgmt has been simplified to reduce its attack surface. Among other
    simplications, routers can no longer automatically open remote SSL tunnels.
  - bismark-mgmt contains new functions for acquiring exclusive access to the
    uplink for performing active measurements. (Note that this lock only
    prevents other BISmark utilities from using the uplink; it does not impact
    end user performance at all.)

- packages/bismark-active-tmpfs
  - Now acquires an exclusive lock on the uplink before performing measurements.

related projects
----------------

- packages/pakistan-censorship-testing
    - Lancre is compatible with pakistan-censorship-testing, a utility which
      aims to observe censorship of Web sites in Pakistan.

- packages/bismark-censorscope
    - Lancre is compatible with Censorscope, a software platform for writing and
      running networking experiments that measure Internet censorship.


Changes since 'Klatch' 2011.09 release
======================================

added
-----

- kernel patched with web100 2.5.27 patchset
    - The Qurim kernel is patched with the web100 patch <http://www.web100.org>
      to collect TCP connection statistics.

- packages/bismark-updater
    - Automatically upgrades specified packages on BISmark routers.
      bismark-updater allows for expression of per-device package upgrades.
      Packages with names ending with '-tmpfs' are installed on /tmp, and so
      can be installed/updated frequently.

- packages/bismark-experiments-manager and
  packages/luci-app-bismark-experiments-manager
    - Automatically downloads lists of "experiments", which are collections of
      packages. The user can then enable experiments using a LuCI panel, which
      installs the packages with each experiment.
      Packages with names ending with '-tmpfs' are installed on /tmp, and so
      can be installed/updated frequently.

- packages/bismark-data-uploader
    - Monitors a specified directory and transfers files copied into this
      directory (typically measurement logs, etc.) to a data collection server
      via HTTP.

- packages/bismark-lua
    - A set of Lua libraries used in a number of the packages identified above.
      Provides utilities such as a Lua interface to opkg, a set library, and
      some helper/utility libraries for tables, strings, and unix paths.

- packages/bismark-netexp and
  packages/bismark-extras
    - Metapackages to pull in a bunch of network measurement tools and other
      useful tools, respectively.

- packages/dropbear-bismark
    - A fork of OpenWrt's dropbear that is patched to allow the path of the
      `authorized_keys` file to be specified via the -D command line switch.
      This is used by bismark-mgmt.

- packages/opkg-bismark
    - A fork of OpenWrt's opkg that is patched to allow the use of libcurl and
      libopenssl for downloading packages. This enables the use of TLS-secured
      package repositories in opkg.conf
      (i.e. https://downloads.projectbismark.net).

changed
-------

- upstream: OpenWrt 'Backfire' 10.03.1
    - This release, codenamed 'Quirm', is based on the OpenWrt
      <http://openwrt.org> 'Backfire' 10.03.1 release. This is an older and
      more stable version of OpenWrt than used for the previous BISmark
      release, 'Klatch'. BISmark is based on this earlier OpenWrt release for
      stability and starting from a defined and well-tested release.

    - Many packages are affected by this change of upstream release. While some
      packages have been upgraded due to OpenWrt backporting, others (e.g.
      openssl) have reverted to earlier versions that may cause unexpected
      behavior in packages that depend on them. Be mindful of these changes
      when porting Klatch packages to Quirm. The full list of packages and
      versions may be obtained from the build or from the OpenWRT page.

- base distribution
    - dnsmasq is configured to resolve `myrouter.projectbismark.net` to the
      router's LAN address, to make it easier to access the router's
      configuration application.
    - Hardware reset button (on bottom of router) and wifi toggle button (on
      front of router) are now supported. Holding the reset button for
      5 seconds will now erase the JFFS overlay and reboot the router with only
      the base squashfs filesystem, resetting the router to a freshly flashed
      state.
    - LuCI theme changed to be more visually appealing and use the BISmark
      graphic identity.
    - Hostname is now set to the BISmark device ID (e.g. OW012345689AB).
    - Firmware image filenames now contain 'bismark' and the name of the
      bismark release to differentiate BISmark images from vanilla OpenWrt
      images
      (e.g. `openwrt-bismark_quirm-ar71xx-wndr3700v2-squashfs-factory.img`).

- kernel: Linux 2.6.32
    - The kernel has been downgraded from 2.6.39 to 2.6.32.

- packages/bismark-active(-tmpfs)
    - bismark-active has a -tmpfs variant, 'bismark-active-tmpfs' that is
      selected by default in Qurim. bismark-active-tmpfs is installed on the
      /tmp tmpfs (ram disk). A fresh, up-to-date copy is downloaded every time
      the router is booted.
    - Active measurements now include a latency test to candidate measurement
      servers once every 24h.

- packages/bismark-mgmt
    - bismark-mgmt now runs a separate dropbear (sshd) instance on a separate
      port (2222) that only accepts public key authentication using the bismark
      remote access key (specified in a separate `authorized_keys` file). This
      allows users to control dropbear as they wish without unintentionally
      disabling remote access capabilities.

- packages/bismark-chrome
    - bismark-chrome-new was renamed to bismark-chrome.
    - Minor changes, such as updating the contributor list, etc.
    - 'View collected data' link now links directly to the device-specific page
      on networkdashboard.org.

related projects
----------------

- packages/bismark-passive
    - Quirm is compatible with bismark-passive, an optional and non-standard
      package that performs passive traffic analysis on consenting volunteers.
      After explicitly opting in and providing informed consent, volunteers can
      enable bismark-passive using the BISmark Experiments panel in LuCI.

- packages/bismark-passive-ucap
    - Quirm is compatible with uCap (bismark-passive-ucap), an optional and
      non-standard package that allows consenting volunteers to monitor and
      control traffic on their home network. After explicitly opting in and
      providing informed consent, volunteers can enable bismark-passive-ucap
      using the BISmark Experiments panel in LuCI.
