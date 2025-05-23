
EAPI=6

CRATES="
adler32-1.0.2
advapi32-sys-0.2.0
aho-corasick-0.6.4
ansi_term-0.11.0
arrayvec-0.4.7
atty-0.2.8
backtrace-0.3.6
backtrace-sys-0.1.16
base64-0.8.0
base64-0.9.0
bincode-0.8.0
bit-vec-0.4.4
bitflags-0.9.1
bitflags-1.0.1
bs58-0.2.0
build_const-0.2.1
byteorder-1.2.2
bytes-0.4.6
cc-1.0.10
cfg-if-0.1.2
chrono-0.4.2
clap-2.31.2
core-foundation-0.2.3
core-foundation-sys-0.2.3
crc-1.7.0
crossbeam-0.2.12
crossbeam-deque-0.3.0
crossbeam-epoch-0.4.1
crossbeam-utils-0.2.2
crossbeam-utils-0.3.2
cryptovec-0.4.4
dtoa-0.4.2
encoding_rs-0.7.2
env_logger-0.4.3
env_logger-0.5.8
errno-0.2.3
error-chain-0.11.0
filetime-0.2.0
flate2-1.0.1
fnv-1.0.6
foreign-types-0.3.2
foreign-types-shared-0.1.1
fs2-0.4.3
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.21
futures-cpupool-0.1.8
getch-0.2.0
globset-0.2.1
hex-0.3.2
httparse-1.2.4
humantime-1.1.1
hyper-0.11.25
hyper-tls-0.1.3
idna-0.1.4
ignore-0.3.1
iovec-0.1.2
isatty-0.1.7
itoa-0.3.4
itoa-0.4.1
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-0.2.11
lazy_static-1.0.0
lazycell-0.6.0
libc-0.2.40
libflate-0.1.14
line-0.1.1
line-0.1.1
log-0.3.9
log-0.4.1
matches-0.1.6
memchr-2.0.1
memmap-0.6.2
memoffset-0.2.1
mime-0.3.5
mime_guess-2.0.0-alpha.4
miniz-sys-0.1.10
mio-0.6.14
mio-uds-0.6.4
miow-0.2.1
native-tls-0.1.5
net2-0.2.32
nodrop-0.1.12
num-0.1.42
num-bigint-0.1.43
num-complex-0.1.43
num-integer-0.1.36
num-iter-0.1.35
num-rational-0.1.42
num-traits-0.1.43
num-traits-0.2.2
num_cpus-1.8.0
openssl-0.10.6
openssl-0.9.24
openssl-sys-0.9.28
pager-0.14.0
percent-encoding-1.0.1
phf-0.7.21
phf_codegen-0.7.21
phf_generator-0.7.21
phf_shared-0.7.21
pkg-config-0.3.9
proc-macro2-0.3.6
progrs-0.1.1
quick-error-1.2.1
quote-0.5.1
rand-0.3.22
rand-0.4.2
redox_syscall-0.1.37
redox_termios-0.1.1
regex-0.2.10
regex-syntax-0.5.5
relay-0.1.1
remove_dir_all-0.5.1
reqwest-0.8.5
rpassword-2.0.0
rustc-demangle-0.1.7
rustc-serialize-0.3.24
safemem-0.2.0
same-file-1.0.2
sanakirja-0.8.16
schannel-0.1.12
scoped-tls-0.1.1
scopeguard-0.3.3
security-framework-0.1.16
security-framework-sys-0.1.16
serde-1.0.41
serde_derive-1.0.41
serde_derive_internals-0.23.1
serde_json-1.0.15
serde_urlencoded-0.5.1
shell-escape-0.1.4
siphasher-0.2.2
slab-0.3.0
slab-0.4.0
smallvec-0.2.1
strsim-0.7.0
syn-0.13.1
take-0.1.0
tar-0.4.15
tempdir-0.3.7
term-0.5.1
termcolor-0.3.6
termion-1.5.1
termios-0.2.2
textwrap-0.9.0
thread_local-0.3.5
thrussh-0.19.5
thrussh-keys-0.9.5
thrussh-libsodium-0.1.3
time-0.1.39
tokio-0.1.5
tokio-core-0.1.17
tokio-executor-0.1.2
tokio-io-0.1.6
tokio-proto-0.1.1
tokio-reactor-0.1.1
tokio-service-0.1.0
tokio-tcp-0.1.0
tokio-threadpool-0.1.2
tokio-timer-0.2.1
tokio-tls-0.1.4
tokio-udp-0.1.0
tokio-uds-0.1.7
toml-0.4.6
ucd-util-0.1.1
unicase-1.4.2
unicase-2.1.0
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-width-0.1.4
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.0
username-0.2.0
utf8-ranges-1.0.0
utf8parse-0.1.0
uuid-0.5.1
vcpkg-0.2.3
vec_map-0.8.0
version_check-0.1.3
void-1.0.2
walkdir-2.1.4
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-0.1.6
ws2_32-sys-0.2.1
xattr-0.2.1
yasna-0.1.3
"

inherit cargo

DESCRIPTION="Distributed VCS based on a sound theory of patches."
HOMEPAGE="https://pijul.org/"
SRC_URI="https://pijul.org/releases/${P}.tar.gz
	$(cargo_crate_uris $CRATES)"
RESTRICT="mirror"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/libsodium"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/${PN}"

PATCHES=( "${FILESDIR}/pijul-fix-libpijul.patch" )

src_install() {
	export S="${WORKDIR}/${P}"
	cd "${S}"
	debug-print-function ${FUNCNAME} "$@"

	cargo install -j $(makeopts_jobs) --root="${D}/usr" $(usex debug --debug "") --path pijul \
		|| die "cargo install failed"
	rm -f "${D}/usr/.crates.toml"

	[ -d "${S}/man" ] && doman "${S}/man" || return 0
}
