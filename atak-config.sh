#!/bin/bash

if [ $# -eq 0 ]
then
    echo "ERROR : No arguements supplied. Provide the plugin name !"
    exit 0
fi

plugin_name=$1
username="$(id -u -n)"
keyfile_name="my-release-key.jks"
keyfile_alias="my-alias"
keyfile_keypass="android"
keyfile_storepass="android"
keyfile_CN="Android Dev Docker"
keyfile_OU="DevOps"
keyfile_O="atak-civ-sdk-x.x.x.x"
keyfile_C="US"
keyfile_L="Ft. Belvoir"

echo "CONFIGURATION in atak-config.sh"
echo "$plugin_name"
echo "$username"

# https://docs.oracle.com/en/java/javase/17/docs/specs/man/keytool.html
# NOTE : use `android´ for your password, type the cert info (just hit enter), enventually type yes
if [ ! -e "${keyfile_name}" ]
then
    echo "${keyfile_name} does not exist!"
    keytool -genkey -v -keystore ${keyfile_name} -keyalg RSA -keysize 2048 -validity 10000 -alias ${keyfile_alias} -keypass ${keyfile_keypass} -storepass ${keyfile_storepass} -dname "CN=$keyfile_CN, OU=$keyfile_OU, O=$keyfile_O, C=$keyfile_C, L=$keyfile_L"
else
    echo "${keyfile_name} exist!"
fi

# symboly link keyfile and properties in the plugin
if [ ! -e "/home/$username/atak-civ/plugins/${plugin_name}/app/$keyfile_name" ]
then 
    echo "Symbolic Link for $keyfile_name does not exist!"
    ln -s /home/$username/atak-civ/my-release-key.jks /home/$username/atak-civ/plugins/${plugin_name}/app/${keyfile_name}
else
    echo "Symbolic Link for $keyfile_name exist!"
    rm -r "/home/$username/atak-civ/plugins/$plugin_name/app/$keyfile_name"
    ln -s /home/$username/atak-civ/my-release-key.jks /home/$username/atak-civ/plugins/${plugin_name}/app/${keyfile_name}
fi

if [ ! -e "/home/$username/atak-civ/plugins/${plugin_name}/local.properties" ]
then
    echo "Symbolic Link for local.properties does not exist!"
    ln -s /home/$username/atak-civ/local.properties /home/$username/atak-civ/plugins/${plugin_name}/local.properties
else
    echo "Symbolic Link for local.properties exist!"
    rm -r "/home/$username/atak-civ/plugins/$plugin_name/local.properties"
    ln -s /home/$username/atak-civ/local.properties /home/$username/atak-civ/plugins/${plugin_name}/local.properties
fi
