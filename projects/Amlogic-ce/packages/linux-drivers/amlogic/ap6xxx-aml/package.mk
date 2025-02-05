# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="ap6xxx-aml"
PKG_VERSION="3d1057ac28b1cf41e63758e0304e62e6d945de85"
PKG_SHA256="a3dd88cbd1ef2a96d841440e6864283de18447928e821c9c9c17c0f483339c00"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/ap6xxx-aml"
PKG_URL="https://github.com/CoreELEC/ap6xxx-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="ap6xxx: Linux drivers for AP6xxx WLAN chips used in some devices based on Amlogic SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  echo
  echo "building ap6356s and others"
  make -C  $PKG_BUILD/bcmdhd.1.363.59.144.x.cn \
       PWD=$PKG_BUILD/bcmdhd.1.363.59.144.x.cn \
       KDIR=$(kernel_path) \
       ARCH=$TARGET_KERNEL_ARCH \
       CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
       CONFIG_BCMDHD_DISABLE_WOWLAN=y \
       dhd

  if [ "$DEVICE" = "Amlogic-ng" ]; then
    echo
    echo "building ap6275s"
    make -C  $PKG_BUILD/bcmdhd.100.10.545.x \
         PWD=$PKG_BUILD/bcmdhd.100.10.545.x \
         KDIR=$(kernel_path) \
         ARCH=$TARGET_KERNEL_ARCH \
         CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
         CONFIG_BCMDHD_DISABLE_WOWLAN=y \
         bcmdhd_sdio
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME

  find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' \
    -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;
}

post_install() {
  if [ "$PROJECT" = "Amlogic" ]; then
    rm $INSTALL/usr/lib/modprobe.d/dhd_sdio.conf
    rm $INSTALL/usr/lib/udev/rules.d/80-dhd_sdio.rules
  fi
}
