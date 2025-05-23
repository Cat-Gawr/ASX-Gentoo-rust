EAPI=6

CRATES="
atk-sys-0.3.3
bitflags-0.4.0
bitflags-0.5.0
c_vec-1.2.0
cairo-rs-0.1.2
cairo-sys-rs-0.3.3
dbus-0.5.2
error-chain-0.7.2
gdk-0.5.2
gdk-pixbuf-0.1.2
gdk-pixbuf-sys-0.3.3
gdk-sys-0.3.3
gio-0.1.2
gio-sys-0.3.3
glib-0.1.2
glib-sys-0.3.3
gobject-sys-0.3.3
gtk-0.1.2
gtk-sys-0.3.3
libc-0.2.21
metadeps-1.1.1
nodrop-0.1.9
num-traits-0.1.37
odds-0.2.25
pango-0.1.2
pango-sys-0.3.3
pkg-config-0.3.9
quickersort-2.2.0
systemd-manager-1.0.0
toml-0.2.1
unreachable-0.1.1
void-1.0.2
winapi-0.2.8
"

inherit cargo

DESCRIPTION="A GTK3 GUI for managing systemd services on Linux"
HOMEPAGE="https://github.com/mmstick/systemd-manager"
#SRC_URI="https://github.com/mmstick/systemd-manager/releases/${P}.tar.gz
#$(cargo_crate_uris ${CRATES})"

SRC_URI="$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="MIT" # Update to proper Gentoo format
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""
