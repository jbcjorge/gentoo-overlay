# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1 rpm

MY_P="${PN}-${PV%.*}-${PV##*.}"
DESCRIPTION="Brother scanner driver"
HOMEPAGE="https://www.brother.com/"
SRC_URI="
	amd64? ( https://download.brother.com/welcome/dlf104036/${MY_P}.x86_64.rpm )
	x86? ( https://download.brother.com/welcome/dlf104035/${MY_P}.i386.rpm )"
S="${WORKDIR}/opt/brother/scanner/${PN}"

LICENSE="Brother"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="zeroconf"
RESTRICT="strip"

RDEPEND="media-gfx/sane-backends
	sys-libs/glibc
	virtual/libusb:0
	zeroconf? ( net-dns/avahi )"

QA_PREBUILT="opt/brother/*"

src_install() {
	local dest=/opt/brother/scanner/${PN}
	local lib=$(get_libdir)

	insinto /etc${dest}
	doins brscan5.ini brsanenetdevice.cfg
	doins -r models
	dosym -r {/etc,}${dest}/brscan5.ini
	dosym -r {/etc,}${dest}/brsanenetdevice.cfg
	dosym -r {/etc,}${dest}/models

	exeinto ${dest}
	doexe brsaneconfig5
	dosym -r {${dest},/usr/bin}/brsaneconfig5

	if use zeroconf; then
		doexe brscan_cnetconfig
		# Don't install brscan_gnetconfig because it depends on gtk+:2
	fi

	into ${dest}
	dolib.so "${S}"/libsane-brother5.so.1.0.7
	dosym -r {${dest}/${lib},/usr/${lib}/sane}/libsane-brother5.so.1.0.7

	insinto /etc/sane.d/dll.d
	newins - ${PN} <<< "brother5"

	local DOC_CONTENTS="If want to use a remote scanner over the network,
		you will have to add it with \"brsaneconfig5\"."
	use zeroconf || DOC_CONTENTS+="\\n\\nNote that querying the network
		(\"brsaneconfig5 -q\") will not work unless you emerge ${PN} with
		the zeroconf flag enabled."

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
