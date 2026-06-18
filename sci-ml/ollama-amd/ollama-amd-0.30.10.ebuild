# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#inherit systemd
inherit unpacker

DESCRIPTION="Ollama - get up and running with large language models - additional amd package"
HOMEPAGE="https://ollama.com/"
LICENSE="MIT"
SLOT="0"

#IUSE="+systemd"
IUSE=""

BEPEND="virtual/pkgconfig"

# BDEPEND="app-arch/zstd"
BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="\
    acct-user/genai\
    acct-group/genai\
"

DEPEND="\
    ${RDEPEND}\
    dev-vcs/git\
    net-misc/curl\
    net-misc/wget\
    sci-ml/ollama\
"

DISTUTILS_IN_SOURCE_BUILD=

INSTALL_DIR="/usr"

MY_PV="${PV//_}"
MY_PN="ollama"
MY_P=${MY_PN}-${MY_PV}
KEYWORDS="~amd64"
SRC_URI="https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-${ARCH}-rocm.tar.zst -> ${P}.gh.tar.zst"
S="${WORKDIR}/"




src_unpack() {
	die() { eerror "$*" 1>&2 ; exit 1; }
	pwd
	if [[ -n ${A} ]]; then
		echo "Unpacking...."
		#unpack ${A} || die "Unpack failed!"
		unpacker ${A} || die "Unpack failed!"
		echo "Unpacking finished."
	fi
}
#/var/tmp/portage/sci-ml/ollama-amd-0.13.0/image/usr/lib/ollama/rocm/libggml-hip.so

src_prepare() {
    default
}

src_install() {
    die() { echo "$*" 1>&2 ; exit 1; }
    mkdir -p "${D}${INSTALL_DIR}"
    cp -R -f "${WORKDIR}/." "${D}${INSTALL_DIR}" || die "Install failed!"
    chown -R genai:genai "${D}${INSTALL_DIR}"
    cd "${D}"
    _patchelf_paths=(
        "lib",
        "lib/llvm",
        "lib/llvm/bin",
        "lib/ollama",
        "lib/ollama/rocm",
        "lib/ollama/cuda_v12",
        "lib/ollama/cuda_v13",
        "/opt/rocm-6.3.3",
        "/opt/rocm-6.3.3/lib",
        "/opt/rocm-6.3.3/lib/llvm",
        "/opt/rocm-6.3.3/lib/llvm/bin",
    )
    for _index in "${!_patchelf_paths[@]}"
    do
        _patchelf_paths[${_index}]="${INSTALL_DIR}/${_patchelf_paths[${_index}]}"
    done
    patchelf --set-rpath "$(IFS=":"; echo "${_patchelf_paths[*]}:\$ORIGIN")" "./usr/lib/ollama/rocm/libggml-hip.so" || die
    #if use systemd; then
    #    systemd_newunit "${FILESDIR}"/ollama.service ollama.service
    #fi
}
