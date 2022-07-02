#!/bin/bash

source "$(pwd)/env.sh"

[ -d $ROOTFS_FOLDER ] && rm -r $ROOTFS_FOLDER
[ -d $BUILD_FOLDER ] && rm -r $BUILD_FOLDER
[ -d $BIN_FOLDER ] && rm -r $BIN_FOLDER
