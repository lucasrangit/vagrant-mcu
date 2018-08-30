#!/usr/bin/env bash
#
# Setup MCUXpresso
#
set -x
set -e

INSTALLER="mcuxpressoide-10.2.1_795.x86_64.deb.bin"
INSTALLER_URL="https://freescaleesd.flexnetoperations.com/337170/267/13140267/mcuxpressoide-10.2.1_795.x86_64.deb.bin"

DATA_DIR="/vagrant_data"

if [[ ! -d "${DATA_DIR}" ]]; then
	echo "No data directory" >&2
	exit 1
fi

wget --quiet --continue --output-document="${DATA_DIR}/${INSTALLER}" "${INSTALLER_URL}"

if [[ ! -e "${DATA_DIR}/${INSTALLER}" ]]; then
	echo "${INSTALLER} not found" >&2
	exit 1
fi

chmod +x "${DATA_DIR}/${INSTALLER}"

# don't prompt for license
dpkg-divert --add --rename --divert /bin/whiptail.orig /bin/whiptail
ln -s /bin/true /bin/whiptail

"${DATA_DIR}/${INSTALLER}" --noprogress

# revert diversion
rm /bin/whiptail
dpkg-divert --remove --rename /bin/whiptail

echo 'PATH="/usr/local/mcuxpressoide/ide:$PATH"' >> "/home/vagrant/.profile"

WORKSPACE_PATH="/home/vagrant/workspace"

if [[ ! -d "${WORKSPACE_PATH}" ]]; then
	sudo -u vagrant mkdir "${WORKSPACE_PATH}"
fi

# Disable Welcome Page display
sudo -u vagrant mkdir -p ${WORKSPACE_PATH}/.metadata/.plugins/org.eclipse.core.runtime/.settings
sudo -u vagrant cat > ${WORKSPACE_PATH}/.metadata/.plugins/org.eclipse.core.runtime/.settings/com.crt.utils.prefs << EOF
eclipse.preferences.version=1
showWelcomeView=false
EOF

#
# Install SDK
#

# NB: go to https://mcuxpresso.nxp.com and download the SDK archive manually
SDK="FRDM-K22F-OM13588-2.4.1"
SDK_FILE="${SDK}.zip"
SDK_PATH="/home/vagrant/mcuxpresso/01/SDKPackages"

if [[ -e ${DATA_DIR}/${SDK} ]]; then
	sudo -u vagrant mkdir -p ${SDK_PATH}
	sudo -u vagrant cp ${DATA_DIR}/${SDK_FILE} ${SDK_PATH}
fi

# TODO build sample project
#/usr/local/mcuxpressoide/ide/mcuxpressoide -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data /vagrant/workspace
#sudo -u vagrant /usr/local/mcuxpressoide/ide/mcuxpressoide -nosplash --launcher.suppressErrors -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import "/home/vagrant/mcuxpresso/01/SDKPackages/${SDK}/boards/frdmk22f/demo_apps/hello_world/" -data "${WORKSPACE_PATH}"

exit 0

