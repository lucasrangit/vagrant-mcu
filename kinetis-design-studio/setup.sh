#!/usr/bin/env bash
#
# Setup Kinetis Design Studio
#
set -x
set -e

function md5check() {
	if [[ "$(md5sum "${1}" | awk '{ print $1 }')" != "${2}" ]]; then
		return 0
	fi

	return 1
}

INSTALLER="kinetis-design-studio_3.2.0-1_amd64.deb"
INSTALLER_URL="https://freescaleesd.flexnetoperations.com/337170/737/9802737/kinetis-design-studio_3.2.0-1_amd64.deb"
INSTALLER_MD5="725c367fbc40b7d5b4285290eef5f3db"

DATA_DIR="/vagrant_data"

WORKSPACE_PATH="/home/vagrant/workspace"

if [[ ! -d "${DATA_DIR}" ]]; then
	echo "No data directory" >&2
	exit 1
fi

#
# Install KDS
#

wget --quiet --continue --output-document="${DATA_DIR}/${INSTALLER}" "${INSTALLER_URL}"

if md5check "${DATA_DIR}/${INSTALLER}" "${INSTALLER_MD5}"; then
	echo "${INSTALLER} checksum mismatch" >&2
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

#
# Install KSDK
#

#SDK="SDK_2.1_MKL27Z256xxx4"
SDK="SDK_2.2.1_FRDM-KL27Z"

SDK_FILE="${SDK}.tar.gz"
SDK_URL="https://mcuxpresso.nxp.com/en/download?hash=a3b2581033aca15492983bd67221acee&uvid=63133&agree=true&auto=1&dl=1&js=1"
SDK_MD5="df7045fd0a7f694ced73826beeb10d91"
SDK_PATH="/opt/Freescale/${SDK}"

wget --quiet --continue --output-document="${DATA_DIR}/${SDK_FILE}" "${SDK_URL}"

if md5check "${DATA_DIR}/${SDK_FILE}" "${SDK_MD5}"; then
	echo "${SDK_FILE} checksum mismatch" >&2
	exit 1
fi

mkdir "${SDK_PATH}"
tar -xa --directory "${SDK_PATH}" -f "${DATA_DIR}/${SDK_FILE}"
# make read/write by user so that demo projects can be built (they cannot be copied due to linked resources)
chown -R vagrant. "${SDK_PATH}"

#
# Import demo project(s)
#

DEMO="bubble"
DEMO_FILE="${DEMO}.zip"
DEMO_URL="https://mcuxpresso.nxp.com/en/download?hash=ce7b48a4b898e8f45cafe9979e5befe5&uvid=None&agree=true&pg=download&auto=1&dl=1&js=1"

wget --quiet --continue --output-document="${DATA_DIR}/${DEMO}" "${DEMO_URL}"

# Extract but don't overwrite existing files
unzip -n -d "/vagrant" "${DATA_DIR}/${DEMO_FILE}"

if [[ ! -d "${WORKSPACE_PATH}" ]]; then
	mkdir "${WORKSPACE_PATH}"
fi

# FIXME -import doesn't provide a "don't copy into workspace" option, which is required to import demo projects from the SDK because of linked resources.
#       alternatively, download the sample project from the SDK builder web app.
# FIXME -import/-importAll doesn't find the debug/launch configurations. you have to create a new debug configuration and set the machine name (e.g. MKL27Z64xxx4) manually.
sudo -u vagrant /opt/Freescale/KDS_v3/eclipse/kinetis-design-studio -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import "/vagrant/${DEMO}" -data "${WORKSPACE_PATH}"

exit 0

