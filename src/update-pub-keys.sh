#!@@GENTOO_PREFIX@@/bin/bash
#

set -e

cd "$(dirname "$(realpath "$0")")"

if [[ $1 == force ]];then
	./do-as-portage.sh ./gentooDevKeysUpdater.sh
else
	./do-as-portage.sh ./gentooDevKeysUpdater.sh updateList
fi
