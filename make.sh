#!/usr/bin/env bash
#

set -e

_do() {
	set -- "$@"
	echo ">>>" "$@" >&2
	"$@"
}

_do cd "$(dirname "$(realpath "$0")")"

PREFIX="$1"
PORTAGE_USER="${2:-portage}"
if [[ -z $PREFIX ]]; then
	echo "Please specify a prefix path!" >&2
	exit 1
elif [[ ! $PREFIX =~ ^/ ]]; then
	echo "The specified prefix path must be an absolute one!" >&2
	exit 1
fi

_do mkdir -p ./dist
_do rm -f ./dist/*
_do cp ./src/* ./dist/

if sed --version &>/dev/null; then
	# GNU version
	_do sed -Ei "s:@@PORTAGE_USER@@:${PORTAGE_USER}:g" ./dist/do-as-portage.sh
	_do sed -Ei "s:@@GENTOO_PREFIX@@:${PREFIX}:g" ./dist/*
else
	# FreeBSD version
	_do sed -Ei '' "s:@@PORTAGE_USER@@:${PORTAGE_USER}:g" ./dist/do-as-portage.sh
	_do sed -Ei '' "s:@@GENTOO_PREFIX@@:${PREFIX}:g" ./dist/*
fi

_do ln -sf ./dist/sync-repo.sh ./sync-repo
_do ln -sf ./dist/update-pub-keys.sh ./update-pub-keys
