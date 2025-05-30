EAPI=7

CRATES="
aho-corasick-0.6.10
ansi_term-0.11.0
argon2rs-0.2.5
arrayvec-0.4.10
atk-sys-0.7.0
atty-0.2.11
autocfg-0.1.2
backtrace-0.3.14
backtrace-sys-0.1.28
bitflags-1.0.4
blake2-rfc-0.2.18
build-version-0.1.1
byteorder-1.3.1
cairo-rs-0.5.0
cairo-sys-rs-0.7.0
cc-1.0.31
cfg-if-0.1.7
clap-2.32.0
cloudabi-0.0.3
constant_time_eq-0.1.3
dirs-1.0.5
env_logger-0.5.13
failure-0.1.5
failure_derive-0.1.5
fragile-0.3.0
fuchsia-cprng-0.1.1
gdk-0.9.0
gdk-pixbuf-0.5.0
gdk-pixbuf-sys-0.7.0
gdk-sys-0.7.0
gio-0.5.1
gio-sys-0.7.0
glib-0.6.1
glib-sys-0.7.0
gobject-sys-0.7.0
gtk-0.5.0
gtk-sys-0.7.0
htmlescape-0.3.1
humantime-1.2.0
itoa-0.4.3
lazy_static-1.3.0
libc-0.2.50
log-0.4.6
memchr-2.2.0
neovim-lib-0.5.4
nodrop-0.1.13
num-traits-0.1.43
num-traits-0.2.6
pango-0.5.0
pango-sys-0.7.0
pangocairo-0.6.0
pangocairo-sys-0.8.0
percent-encoding-1.0.1
phf-0.7.24
phf_codegen-0.7.24
phf_generator-0.7.24
phf_shared-0.7.24
pkg-config-0.3.14
proc-macro2-0.4.27
quick-error-1.2.2
quote-0.6.11
rand-0.6.5
rand_chacha-0.1.1
rand_core-0.3.1
rand_core-0.4.0
rand_hc-0.1.0
rand_isaac-0.1.1
rand_jitter-0.1.3
rand_os-0.1.3
rand_pcg-0.1.2
rand_xorshift-0.1.1
rdrand-0.4.0
redox_syscall-0.1.51
redox_termios-0.1.1
redox_users-0.3.0
regex-1.1.2
regex-syntax-0.6.5
rmp-0.8.7
rmpv-0.4.0
rustc-demangle-0.1.13
ryu-0.2.7
scoped_threadpool-0.1.9
serde-1.0.89
serde_bytes-0.10.5
serde_derive-1.0.89
serde_json-1.0.39
siphasher-0.2.3
strsim-0.7.0
syn-0.15.29
synstructure-0.10.1
termcolor-1.0.4
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
toml-0.4.10
ucd-util-0.1.3
unicode-segmentation-1.2.1
unicode-width-0.1.5
unicode-xid-0.1.0
unix-daemonize-0.1.2
unix_socket-0.5.0
utf8-ranges-1.0.2
vec_map-0.8.1
winapi-0.3.6
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.2
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.1
winres-0.1.8
"

inherit cargo xdg

DESCRIPTION="NeoVIM GTK frontend"
HOMEPAGE="https://github.com/daa84/neovim-gtk"

SRC_URI="
	https://github.com/daa84/${PN}/archive/v${PV}.tar.gz -> ${PN}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="Apache-2.0 BSD-2 Boost-1.0 CC0-1.0 GPL-3 ISC LGPL-3 LGPL-3+ MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="
	>=app-editors/neovim-0.2.2
	x11-libs/gtk+:3
"

src_install() {
	cargo_src_install
	emake install-resources DESTDIR="${ED}" PREFIX="/usr"
	einstalldocs
}
