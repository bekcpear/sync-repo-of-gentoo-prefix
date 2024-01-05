#!@@GENTOO_PREFIX@@/bin/bash
#

set -e

source ./env.sh

if [[ "${1}" != "updateList" ]]; then
	source "${PUBKEYS_LISTFILE}"
	colorM="\x1b[35m"
	colorU="\x1b[36m"
	colorX="\x1b[1m"
	colorE="\x1b[0m"
	KEYSTA=1
	KEYORD=1
	KEYNUM=${#KEYIDS[@]}
	TMSG=""
	UPMSGS=""
	if [[ ${1} -gt ${KEYORD} && ${1} -lt ${KEYNUM} ]]; then
		KEYSTA=${1}
		echo "Start from index ${KEYSTA}:"
	fi
	pkill dirmngr || true
	set +e
	EXECERR=0
	for keyid in ${KEYIDS[@]}; do
		if [ ${KEYORD} -ge ${KEYSTA} ];then
			echo -e "${colorU}[${KEYORD}/${KEYNUM}]Updating key: ${keyid} ...${colorE}"
			echo -e "${colorX}  > gpg --keyserver hkps://keys.gentoo.org --recv-keys ${keyid}${colorE}"
			TMSG="$(gpg --keyserver hkps://keys.gentoo.org --recv-keys ${keyid} 2>/dev/stdout)"
			[ $? -ne 0 ] && EXECERR=${?}
			printf "${TMSG}\n"
			[ ${EXECERR} -ne 0 ] && break
			if [[ ! "${TMSG}" =~ .*"not changed".*  ]]; then
				UPMSGS="${UPMSGS}${TMSG}\n${colorM}------${colorE}\n"
			fi
		fi
		eval "KEYORD=\$(( ${KEYORD} + 1 ))"
	done
	set -e
	echo ""
	echo -e "${colorM}Updated keys:${colorE}"
	if [[ "${UPMSGS}" == "" ]]; then
		echo "NONE."
	else
		printf "${UPMSGS%\\x1b*m------\\x1b\[0m\\n}"
		echo -e "${colorM}End.${colorE}"
	fi
	exit ${EXECERR}
fi

# update gpg keys list file
URL="https://qa-reports.gentoo.org/output/committing-devs.gpg"
GPGFILE="${PUBKEYS_LISTFILE%/*}/committing-devs"
trap 'rm -f ${GPGFILE%/*}/*_tmp' EXIT
SUFFIX=$(date +%Y%m%d_%H)
GPGFILE="${GPGFILE}_${SUFFIX}.gpg"
UPGRADE=0

if [ ! -e "${GPGFILE}" ]; then
	# remove outdated GPGFILE
	rm -f ${GPGFILE%_${SUFFIX}.gpg}_2*
	# get new GPGFILE
	wget "${URL}" -O "${GPGFILE}_tmp" && \
	mv "${GPGFILE}_tmp" "${GPGFILE}"
fi

mkdir -p "${PUBKEYS_LISTFILE%/*}"
PUBKEYS_LISTFILE="${PUBKEYS_LISTFILE}_${SUFFIX}"
if [[ ! -e "${PUBKEYS_LISTFILE}" ]]; then
	echo "#${SUFFIX/_/ }+ o'clock" | tee "${PUBKEYS_LISTFILE}_tmp" >/dev/null
	echo "KEYIDS=(" | tee -a "${PUBKEYS_LISTFILE}_tmp" >/dev/null
	gpg --show-keys "${GPGFILE}" 2>/dev/null | sed '/^pub/d;/^sub/d;/^uid.*/bs;/^\s\+Key\sfingerp.*/bs;d;:s;s/^uid\s\+\[\srevoked\]\s\(.*\)/#(REVOKED) \1/;s/^uid\s\+\[\sexpired\]\s\(.*\)/#(EXPIRED) \1/;s/^uid\s\+\(.*\)/#\1/;s/^uid\s\+.*\]\s\(.*\)/#\1/;s/^\s\+Key\sfin.*=\s\(.*\)/0x\1/;/^0x.*/s/\s//g' | tee -a "${PUBKEYS_LISTFILE}_tmp" >/dev/null
	echo ")" | tee -a "${PUBKEYS_LISTFILE}_tmp" >/dev/null
	PUBKEYS_LISTFILEL=${PUBKEYS_LISTFILE%%_*}
	if test -e "${PUBKEYS_LISTFILEL}"; then
		diff --color "${PUBKEYS_LISTFILEL}" "${PUBKEYS_LISTFILE}_tmp" || :
		while read -n 1 -rep 'continue or upgrade?[y/u/N] ' read_parm; do
			case ${read_parm} in
				[yY])
					mv "${PUBKEYS_LISTFILE}_tmp" "${PUBKEYS_LISTFILE}"
					break
					;;
				[uU])
					mv "${PUBKEYS_LISTFILE}_tmp" "${PUBKEYS_LISTFILE}"
					UPGRADE=1
					break
					;;
				*)
					if [[ "${read_parm}" == "" ]]; then
						echo
					fi
					echo "bye~" >&2
					exit 1
					;;
			esac
		done
		unlink ${PUBKEYS_LISTFILEL}
	else
		mv "${PUBKEYS_LISTFILE}_tmp" "${PUBKEYS_LISTFILE}"
	fi
	ln -s "${PUBKEYS_LISTFILE}" "${PUBKEYS_LISTFILEL}"
	PUBKEYS_LISTFILE="${PUBKEYS_LISTFILEL}"
fi
echo "LIST FILE: ${PUBKEYS_LISTFILE}"

if [[ ${UPGRADE} -eq 1 ]]; then
	eval "${0}"
fi
