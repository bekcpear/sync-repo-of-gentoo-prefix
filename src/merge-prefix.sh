#!@@GENTOO_PREFIX@@/bin/bash
#

_do() {
	set -- "$@"
	echo ">>>" "$@" >&2
	"$@"
}

set -e

source ./env.sh

update() {
	pushd "$1"
	trap 'popd' RETURN
	_do git reset --hard HEAD
	_do git clean -df
	_do git -c gc.autodetach=false gc --auto
	_do git fetch --depth 1
	_do git reset --merge origin/HEAD
}

verify() {
	pushd "$1"
	trap 'popd' RETURN
	local commit result ret=0
	commit=$(_do git rev-list HEAD)
	result=$(_do git verify-commit --raw "$commit" 2>&1) || ret=$?
	if [[ $ret != 0 ]]; then
		echo "Verification failed!" >&2
		_do git --no-pager log -1 --pretty=fuller "$commit"
		echo "${result}"
		if grep "\\[GNUPG:\\] EXPKEYSIG" <<< "$result"; then
			echo "... but expired keys are alright..."
		else
			return 1
		fi
	fi
}

# update gentoo
update "$GENTOO_PATH"
# verify gentoo
verify "$GENTOO_PATH"

# update metadata
for _xx in dtd glsa news xml-schema; do
	update "${GENTOO_PATH}/metadata/${_xx}"
	verify "${GENTOO_PATH}/metadata/${_xx}"
done

# update gentoo-prefix
update "$GENTOO_PREFIX_PATH"
# verify gentoo-prefix
verify "$GENTOO_PREFIX_PATH"

# sync prefix to ::gentoo
prefix2gentoo() {
	pushd "$GENTOO_PREFIX_PATH"
	trap 'popd' RETURN

	# reference:
	# https://github.com/gentoo/prefix/blob/master/scripts/rsync-generation/update-rsync-master.sh
	local entry
	for entry in scripts *-*/* ; do
		# copy it over
		[[ -e ${GENTOO_PATH}/${entry} ]] || mkdir -p "${GENTOO_PATH}"/${entry}
		_do rsync -v --delete -aC "${entry}/" "${GENTOO_PATH}/${entry}/"
	done

	# we excluded the eclasses above, because we "overlay" them from gx86
	# with the Prefix ones (inside the directory, so no --delete)
	_do rsync -v -aC eclass/ "${GENTOO_PATH}"/eclass/ || return 1

	# define repo_name, can't use gx86's name as we're different
	echo "gentoo_prefix" | _do tee "${GENTOO_PATH}"/profiles/repo_name
	# reset Prefix profiles to dev status
	_do sed -i -e '/prefix/s/exp/dev/' "${GENTOO_PATH}"/profiles/profiles.desc

	# generate the metadata
	_do egencache --update --jobs=10 \
		--repo=gentoo_prefix \
		--update-pkg-desc-index \
		--update-use-local-desc -v || return 5 
	#_do date -u | _do tee "${GENTOO_PATH}"/metadata/timestamp
	#_do date -u '+%s %c %Z' | _do tee "${GENTOO_PATH}"/metadata/timestamp.x
	_do date -R -u | _do tee "${GENTOO_PATH}/metadata/timestamp.chk"

	# add a "gentoo" alias for compatibility, bug #911543.
	_do sed -e '$arepo-name = gentoo_prefix\naliases = gentoo' \
	    -i "${GENTOO_PATH}"/metadata/layout.conf
}
prefix2gentoo
