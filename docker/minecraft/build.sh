#!/bin/sh
set -xe
readonly PACK_FILE=/pack/pack.toml
readonly OVERLAY_DIR=/pack/overlay

java -cp /opt/packwiz-installer.jar link.infra.packwiz.installer.DevMainKt \
    --no-gui \
    --side server \
    "file://$PACK_FILE"

_VERSIONS="$(awk -F '[ ="]+' '/[versions]/ && ($1 == "fabric" || $1 == "minecraft") {print $1"="$2}' "$PACK_FILE")"
_MINECRAFT_VERSION="$(echo "$_VERSIONS" | awk -F '=' '$1 == "minecraft" {print $2}')"
[ -z "$_MINECRAFT_VERSION" ] && (printf 'Failed to determine MC version\n'; exit 1)
_FABRIC_VERSION="$(echo "$_VERSIONS" | awk -F '=' '$1 == "fabric" {print $2}')"
[ -z "$_FABRIC_VERSION" ] && (printf 'Failed to determine loader version\n'; exit 1)

_REMAPPED_FOLDER_NAME="minecraft-$_MINECRAFT_VERSION-$_FABRIC_VERSION"
if [ ! -d ".fabric/remappedJars/$_REMAPPED_FOLDER_NAME" ]; then
    java -jar /opt/fabric-installer.jar \
        server -downloadMinecraft \
        -mcversion "$_MINECRAFT_VERSION" \
        -loader "$_FABRIC_VERSION"
fi

printf 'eula=true\n' > eula.txt

if [ -f "$OVERLAY_DIR/build.sh" ]; then
    # shellcheck disable=SC1091
    . "$OVERLAY_DIR/build.sh"
elif [ -d "$OVERLAY_DIR" ]; then
    cp -R "$OVERLAY_DIR"/. .;
fi

# cache all libraries by running mc up until the bootstrap stage
java -jar fabric-server-launch.jar \
    --nogui --initSettings
rm -rf logs

cp -R . /server/
