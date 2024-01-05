#!@@GENTOO_PREFIX@@/bin/bash
#

set -e

cd "$(dirname "$(realpath "$0")")"
./do-as-portage.sh ./merge-prefix.sh
./do-as-portage.sh eix-sync -a
