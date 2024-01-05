export GENTOO_PREFIX="/gp" # depends on a new Volume
# OR
#export GENTOO_PREFIX="/Users/<someone>/Gentoo"

export PATH="${GENTOO_PREFIX}/usr/local/sbin:${GENTOO_PREFIX}/usr/local/bin:${GENTOO_PREFIX}/usr/sbin:${GENTOO_PREFIX}/usr/bin:${GENTOO_PREFIX}/sbin:${GENTOO_PREFIX}/bin:${GENTOO_PREFIX}/opt/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin"

# the home for portage user
export HOME="${GENTOO_PREFIX}/home/portage"

export GENTOO_PREFIX_PATH="${GENTOO_PREFIX}/var/db/repos/prefix.d/prefix"
export GENTOO_PATH="${GENTOO_PREFIX}/var/db/repos/gentoo"

export PUBKEYS_LISTFILE="${HOME}/.gnupg/gentooDevKeysLists/list"
