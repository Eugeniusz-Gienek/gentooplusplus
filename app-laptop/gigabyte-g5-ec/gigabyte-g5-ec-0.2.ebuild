# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="HWMON driver exposing fan tachometers on Gigabyte G5 KD laptop (0x5570 sensor)"

HOMEPAGE="https://github.com/Eugeniusz-Gienek/gigabyte-g5-ec"
SRC_URI="https://github.com/Eugeniusz-Gienek/gigabyte-g5-ec/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="dist-kernel lm-sensors-conf"

RDEPEND="
	dist-kernel? ( virtual/dist-kernel:= )
	lm-sensors-conf? ( sys-apps/lm-sensors )
"

CONFIG_CHECK="HWMON"

src_compile() {
	local modlist=( gigabyte_g5_ec=extra )
	local modargs=( KDIR="${KV_OUT_DIR}" )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	insinto /etc/modules-load.d
	newins "${FILESDIR}"/modules-load.conf gigabyte-g5-ec.conf

	if use lm-sensors-conf; then
		insinto /etc/sensors.d
		newins "${FILESDIR}"/sensors.conf gigabyte-g5-ec.conf
	fi

	dodoc README.md
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	elog "This driver matches Gigabyte G5 KD via DMI (Clevo-type). On other"
	elog "models with a compatible ITE EC layout, load with force=1 to"
	elog "bypass the match:"
	elog "    modprobe gigabyte_g5_ec force=1"
	elog
	elog "Reported RPM assumes a tachometer divisor of 2156220, which is the"
	elog "ITE convention but might be different on your hw. Adjust live via:"
	elog "    /sys/module/gigabyte_g5_ec/parameters/tach_div"

	if ! use dist-kernel; then
		elog
		elog "Rebuilding after a kernel upgrade with: emerge @module-rebuild"
	fi
}
