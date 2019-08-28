#!/usr/bin/env bash
set -o errexit
set -o xtrace

PROJ_PATH="/vagrant"
WORKSPACE_PATH="/home/vagrant/workspace"
DATA_DIR="/vagrant_data"

function md5check() {
	if [[ "$(md5sum "${1}" | awk '{ print $1 }')" != "${2}" ]]; then
		return 1
	fi

	return 0
}

# $1 source URL
# $2 destination path
# $3 MD5 checksum
function wget_robust() {
	local src=$1
	local dst=$2
	local md5=$3
	local ret=0

	shift 3

	if [[ -e ${dst} ]]; then
		if ! md5check "${dst}" "${md5}"; then
			rm "${dst}"
		else
			return 0
		fi
	fi

	# retry 403 Forbidden (exit code 8) errors, which could be due to connection limits
	for i in $(seq 1 10); do
		wget --progress=dot:giga --show-progress --continue --retry-connrefused --tries=0 "$@" --output-document="${dst}" "${src}"
		ret=$?
		if [[ $ret -ne 8 ]]; then
			break
		fi
		sleep 60
	done

	if [[ $ret -eq 0 ]] && ! md5check "${dst}" "${md5}"; then
		echo "${dst} checksum mismatch" >&2
		return 1
	fi

	return $ret
}

#
# Setup Kinetis Design Studio
#

INSTALLER="kinetis-design-studio_3.2.0-1_amd64.deb"
INSTALLER_URL="https://freescaleesd.flexnetoperations.com/337170/737/9802737/kinetis-design-studio_3.2.0-1_amd64.deb"
INSTALLER_MD5="725c367fbc40b7d5b4285290eef5f3db"

if [[ ! -d "${DATA_DIR}" ]]; then
	echo "No data directory" >&2
	exit 1
fi

#
# Install IDE
#

if ! wget_robust "${INSTALLER_URL}" "${DATA_DIR}/${INSTALLER}" "${INSTALLER_MD5}"; then
	echo "Download failed" >&2
	exit 1
fi

# disable frontend in debconf, prevent interactive to access stdin
export DEBIAN_FRONTEND=noninteractive

# Eclipse dependency
apt-get install -y libgtk2.0-0
# arm-none-eabi-gcc dependency
apt-get install -y lib32z1 lib32ncurses5

dpkg -i "${DATA_DIR}/${INSTALLER}"

echo 'PATH="/opt/Freescale/KDS_v3/eclipse:$PATH"' >> "/home/vagrant/.profile"

sudo -u vagrant mkdir -p "${WORKSPACE_PATH}"

# Disable Welcome Page display
sudo -u vagrant mkdir -p ${WORKSPACE_PATH}/.metadata/.plugins/org.eclipse.core.runtime/.settings
sudo -u vagrant cat > ${WORKSPACE_PATH}/.metadata/.plugins/org.eclipse.core.runtime/.settings/com.crt.utils.prefs << EOF
eclipse.preferences.version=1
showWelcomeView=false
EOF

#
# Install SDK
#

SDK="SDK_2.2.1_FRDM-KL27Z"
#SDK="SDK_2.1_MKL27Z256xxx4"

SDK_FILE="${SDK}.tar.gz"
SDK_URL="https://community.nxp.com/servlet/JiveServlet/download/511082-1-453856/SDK_2.1_MKL27Z256xxx4.tar.gz"
SDK_MD5="0d8eb1ed081d09ffbc91b012429f16b5"
SDK_PATH="/opt/Freescale/${SDK}"

if ! wget_robust "${SDK_URL}" "${DATA_DIR}/${SDK_FILE}" "${SDK_MD5}" --user "${BITBUCKET_USER}" --password "${BITBUCKET_PASS}"; then
	echo "Download failed" >&2
	exit 1
fi

mkdir -p "${SDK_PATH}"
chown vagrant. "${SDK_PATH}"
sudo -u vagrant tar -xa --directory "${SDK_PATH}" -f "${DATA_DIR}/${SDK_FILE}"

#
# Import project
#

# FIXME -import/-importAll doesn't find the debug/launch configurations. you have to create a new debug configuration and set the machine name (e.g. MKL27Z64xxx4) manually.
sudo -u vagrant /opt/Freescale/KDS_v3/eclipse/kinetis-design-studio -nosplash --launcher.suppressErrors -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import "${PROJ_PATH}" -data "${WORKSPACE_PATH}"

exit 0
