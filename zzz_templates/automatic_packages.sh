#!/bin/bash
set +e 2>/dev/null

##################
# INIT VARIABLES #
##################

PACKAGES=${PACKAGES:-""}
PACKMANAGER="apk"

############################
# CHECK WHICH BASE IS USED #
############################

if [[ "$(apk -h 2>/dev/null)" ]]; then
# If apk based
PACKMANAGER="apk"
PACKAGES="apk add --no-cache $PACKAGES"
else
# If apt-get based
PACKMANAGER="apt"
PACKAGES="apt-get clean \
    && apt-get update \
    && apt-get install -y --no-install-recommends $PACKAGES"
fi

###################
# DEFINE PACKAGES #
###################

# ADD GENERAL ELEMENTS
######################

PACKAGES="$PACKAGES jq curl"

# FOR EACH SCRIPT, SELECT PACKAGES
##################################

for files in "/scripts" "/etc/cont-init.d" "/etc"; do
if ls $files/*smb* 1> /dev/null 2>&1; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES cifs-utils keyutils samba samba-client"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES cifs-utils keyutils samba smbclient"
fi

if ls $files/*vpn* 1> /dev/null 2>&1; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES coreutils openvpn"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES coreutils openvpn"
fi

if ls $files/*global_var* 1> /dev/null 2>&1; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES jq"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES jq"
fi

if ls $files/*yaml* 1> /dev/null 2>&1; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES yamllint"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES yamllint"
fi

if ls $files/*nginx* 1> /dev/null 2>&1; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES nginx"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES nginx"
fi

if [ $(grep -rnw "$files" -e 'git' &>/dev/null) ]; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES git"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES git"
fi

if [ $(grep -rnw "$files" -e 'sponge' &>/dev/null) ]; then
[ $PACKMANAGER = "apk" ] && PACKAGES="$PACKAGES moreutils"
[ $PACKMANAGER = "apt" ] && PACKAGES="$PACKAGES moreutils"
fi

####################
# INSTALL ELEMENTS #
####################

eval "$PACKAGES" 

##################
# INSTALL BASHIO #
##################

mkdir -p /tmp/bashio
curl -L -f -s "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" | tar -xzf - --strip 1 -C /tmp/bashio
mv /tmp/bashio/lib /usr/lib/bashio
ln -s /usr/lib/bashio/bashio /usr/bin/bashio
rm -rf /tmp/bashio
