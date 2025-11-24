# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#inherit systemd

DESCRIPTION="Ollama - get up and running with large language models - additional amd package"
HOMEPAGE="https://ollama.com/"
LICENSE="MIT"
SLOT="0"

#IUSE="+systemd"
IUSE=""

BEPEND="virtual/pkgconfig"

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
SRC_URI="https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-${ARCH}-rocm.tgz -> ${P}.gh.tgz"
S="${WORKDIR}/"


src_prepare() {
    default
}

#/var/tmp/portage/sci-ml/ollama-amd-0.13.0/image/usr/lib/ollama/rocm/libggml-hip.so

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
