EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} pypy )

inherit check-reqs estack flag-o-matic llvm multiprocessing multilib-build python-any-r1 rust-toolchain toolchain-funcs git-r3

SLOT="beta"
MY_P="rust-beta"
EGIT_REPO_URI="https://github.com/rust-lang/rust.git"
EGIT_BRANCH="beta"

EGIT_CHECKOUT_DIR="${MY_P}-src"
KEYWORDS=""

CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu
CHOST_arm64=aarch64-unknown-linux-gnu
CHOST_arm=armv7-unknown-linux-gnu

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"

RESTRICT="network-sandbox"

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC Sparc SystemZ WebAssembly X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=${ALL_LLVM_TARGETS[@]/%/?}

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

IUSE="clippy cpu_flags_x86_sse2 debug doc libressl rls rustfmt system-llvm wasm sanitize miri zsh-completion ${ALL_LLVM_TARGETS[*]}"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.

# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 9.
# 3. Specify LLVM_MAX_SLOT, e.g. 8.
LLVM_DEPEND="
	|| (
		sys-devel/llvm:9[llvm_targets_WebAssembly?]
		wasm? ( >=sys-devel/lld-9 )
	)
	(
		sys-devel/llvm:8[llvm_targets_WebAssembly?]
		wasm? ( >=sys-devel/lld-8 )
	)
	<sys-devel/llvm-10:=
"
LLVM_MAX_SLOT=9

COMMON_DEPEND="
	sys-libs/zlib
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	net-libs/libssh2
	net-libs/http-parser:=
	net-misc/curl[ssl]
	system-llvm? (
		${LLVM_DEPEND}
	)
"

DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	|| (
		>=sys-devel/gcc-4.7
		>=sys-devel/clang-3.5
	)
	dev-util/cmake
"

RDEPEND="${COMMON_DEPEND}
	>=app-eselect/eselect-rust-20190311
	!dev-util/cargo
	rustfmt? ( !dev-util/rustfmt )
"

REQUIRED_USE="|| ( ${ALL_LLVM_TARGETS[*]} )
	wasm? ( llvm_targets_WebAssembly )
	x86? ( cpu_flags_x86_sse2 )
	?? ( system-llvm sanitize )
"

#PATCHES=( )

S="${WORKDIR}/${MY_P}-src"

toml_usex() {
	usex "$1" true false
}

pre_build_checks() {
	CHECKREQS_DISK_BUILD="7G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="10G"
	fi
	eshopts_pop
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	unset SUDO_USER

	pre_build_checks
	python-any-r1_pkg_setup
	if use system-llvm; then
		EGIT_SUBMODULES=( "*" "-src/llvm-project" )
		llvm_pkg_setup
	fi
}

src_prepare() {
	local rust_stage0_root="${WORKDIR}"/rust-stage0

	default
}

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	local rust_target="" rust_targets="" arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_targets="${rust_targets},\"$(rust_abi $(get_abi_CHOST ${v##*.}))\""
	done
	if use wasm; then
		rust_targets="${rust_targets},\"wasm32-unknown-unknown\""
	fi
	rust_targets="${rust_targets#,}"

	local extended="true" tools="\"cargo\","
	if use clippy; then
		tools="\"clippy\",$tools"
	fi
	if use rls; then
		tools="\"rls\",\"analysis\",\"src\",$tools"
	fi
	if use rustfmt; then
		tools="\"rustfmt\",$tools"
	fi
	if use miri; then
		tools="\"miri\",$tools"
	fi

	local rust_stage0_root="${WORKDIR}"/rust-stage0

	rust_target="$(rust_abi)"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		targets = "${LLVM_TARGETS// /;}"
		experimental-targets = ""
		link-shared = $(toml_usex system-llvm)
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = false
		sanitizers = $(toml_usex sanitize)
		extended = ${extended}
		tools = [${tools}]
		verbose = 2
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)/${P}"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		optimize = $(toml_usex !debug)
		debuginfo-level = $(usex debug 2 0)
		debug-assertions = $(toml_usex debug)
		default-linker = "$(tc-getCC)"
		rpath = false
		ignore-git = false
		lld = $(usex system-llvm false $(toml_usex wasm))
		llvm-tools = $(usex system-llvm false true)
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "$(tc-getBUILD_CC)"
			cxx = "$(tc-getBUILD_CXX)"
			linker = "$(tc-getCC)"
			ar = "$(tc-getAR)"
		EOF
		if use system-llvm; then
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/llvm-config"
			EOF
		fi
	done

	if use wasm; then
		cat <<- EOF >> "${S}"/config.toml
			[target.wasm32-unknown-unknown]
			linker = "$(usex system-llvm lld rust-lld)"
		EOF
	fi
}

src_compile() {
	env $(cat "${S}"/config.env)\
		"${EPYTHON}" ./x.py build -vv --config="${S}"/config.toml -j$(makeopts_jobs) || die
}

src_install() {
	local rust_target abi_libdir

	env DESTDIR="${D}" "${EPYTHON}" ./x.py install -vv -j$(makeopts_jobs) --config="${S}"/config.toml || die

	mv "${ED}/usr/bin/rustc" "${ED}/usr/bin/rustc-${PV}" || die
	mv "${ED}/usr/bin/rustdoc" "${ED}/usr/bin/rustdoc-${PV}" || die
	mv "${ED}/usr/bin/rust-gdb" "${ED}/usr/bin/rust-gdb-${PV}" || die
	mv "${ED}/usr/bin/rust-gdbgui" "${ED}/usr/bin/rust-gdbgui-${PV}" || die
	mv "${ED}/usr/bin/rust-lldb" "${ED}/usr/bin/rust-lldb-${PV}" || die
	mv "${ED}/usr/bin/cargo" "${ED}/usr/bin/cargo-${PV}" || die
	if use clippy; then
		mv "${ED}/usr/bin/clippy-driver" "${ED}/usr/bin/clippy-driver-${PV}" || die
		mv "${ED}/usr/bin/cargo-clippy" "${ED}/usr/bin/cargo-clippy-${PV}" || die
	fi
	if use rls; then
		mv "${ED}/usr/bin/rls" "${ED}/usr/bin/rls-${PV}" || die
	fi
	if use rustfmt; then
		mv "${ED}/usr/bin/rustfmt" "${ED}/usr/bin/rustfmt-${PV}" || die
		mv "${ED}/usr/bin/cargo-fmt" "${ED}/usr/bin/cargo-fmt-${PV}" || die
	fi
	if use miri; then
		mv "${ED}/usr/bin/miri" "${ED}/usr/bin/miri-${PV}" || die
		mv "${ED}/usr/bin/cargo-miri" "${ED}/usr/bin/cargo-miri-${PV}" || die
	fi
	if ! use zsh-completion; then
		rm "${ED}/usr/share/zsh/site-functions/_cargo" # fix https://bugs.gentoo.org/675026
	fi

	# Copy shared library versions of standard libraries for all targets
	# into the system's abi-dependent lib directories because the rust
	# installer only does so for the native ABI.
	for v in $(multilib_get_enabled_abi_pairs); do
		if [ ${v##*.} = ${DEFAULT_ABI} ]; then
			continue
		fi
		abi_libdir=$(get_abi_LIBDIR ${v##*.})
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		mkdir -p "${ED}/usr/${abi_libdir}/${P}"
		cp "${ED}/usr/$(get_libdir)/${P}/rustlib/${rust_target}/lib"/*.so \
		   "${ED}/usr/${abi_libdir}/${P}" || die
	done

	dodoc COPYRIGHT

	cat <<-EOF > "${T}"/50${P}
		LDPATH="${EPREFIX}/usr/$(get_libdir)/${P}"
		MANPATH="${EPREFIX}/usr/share/${P}/man"
	EOF
	if use rls; then
		cat <<-EOF >> "${T}"/50${P}
		RUST_SRC_PATH="${EPREFIX}/usr/$(get_libdir)/${P}/rustlib/src/rust/src/"
		EOF
	fi
	doenvd "${T}"/50${P}

	# note: eselect-rust adds EROOT to all paths below
	cat <<-EOF > "${T}/provider-${P}"
		/usr/bin/rustdoc
		/usr/bin/rust-gdb
		/usr/bin/rust-gdbgui
		/usr/bin/rust-lldb
	EOF
	echo /usr/bin/cargo >> "${T}/provider-${P}"
	if use clippy; then
		echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
		echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi
	if use rls; then
		echo /usr/bin/rls >> "${T}/provider-${P}"
	fi
	if use rustfmt; then
		echo /usr/bin/rustfmt >> "${T}/provider-${P}"
		echo /usr/bin/cargo-fmt >> "${T}/provider-${P}"
	fi
	if use miri; then
		echo /usr/bin/miri >> "${T}/provider-${P}"
		echo /usr/bin/cargo-miri >> "${T}/provider-${P}"
	fi
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB and LLDB,"
	elog "for your convenience it is installed under /usr/bin/rust-{gdb,lldb}-${PV}."

	ewarn "cargo is now installed from dev-lang/rust{,-bin} instead of dev-util/cargo."
	ewarn "This might have resulted in a dangling symlink for /usr/bin/cargo on some"
	ewarn "systems. This can be resolved by calling 'sudo eselect rust set ${P}'."

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-vim to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust cleanup
}
