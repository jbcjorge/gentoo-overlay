# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit golang-build golang-vcs-snapshot bash-completion-r1

EGO_PN="k8s.io/kops"
ARCHIVE_URI="https://github.com/kubernetes/kops/archive/${PV}.tar.gz -> kops-${PV}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="Kubernetes Operations (kops) - Production Grade K8s Installation, Upgrades, and Management"
HOMEPAGE="https://github.com/kubernetes/kops"
SRC_URI="${ARCHIVE_URI}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="dev-go/go-bindata"

RESTRICT="test"

src_prepare() {
	default
	sed -i -e 's/ -s -w/ -w/' -e 's#$(LOCAL)/go-bindata#go-bindata#' -e 's#kops-gobindata: gobindata-tool#kops-gobindata: #' src/${EGO_PN}/Makefile || die
}

src_compile() {
	export CGO_LDFLAGS="-fno-PIC "
	LDFLAGS="" GOPATH="${WORKDIR}/${P}" emake -j1 -C src/${EGO_PN} WHAT=cmd/${PN}
	bin/${PN} completion bash > ${PN}.bash
	bin/${PN} completion zsh > ${PN}.zsh
}

src_install() {
	dobin bin/${PN}

	newbashcomp ${PN}.bash ${PN}
	insinto /usr/share/zsh/site-functions
	newins ${PN}.zsh ${PN}
}
