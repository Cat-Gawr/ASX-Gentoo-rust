EAPI=7

inherit multilib-build

DESCRIPTION="Virtual for Rust language compiler"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS=""

BDEPEND=""
RDEPEND="|| ( =dev-lang/rust-${PVR}*[${MULTILIB_USEDEP}] =dev-lang/rust-bin-${PV}*[${MULTILIB_USEDEP}] )"
