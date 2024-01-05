#!@@GENTOO_PREFIX@@/bin/bash
#

_do() {
	(( $# > 0 )) || return 1
	set -- sudo -u @@PORTAGE_USER@@ "$@"
	echo -e "\x1b[1;32m>>>\x1b[0m" "$@" >&2
	"$@"
}

echo -e "\x1b[1;32mRun\x1b[4;32m" "$@" "\x1b[0m\x1b[1;32mas @@PORTAGE_USER@@ user...\x1b[0m" >&2

# change to the project dir
_do cd "$(dirname "$(realpath "$0")")"

# source env
. ./env.sh

if (( $# > 0 )); then
	_do "$@"
fi
