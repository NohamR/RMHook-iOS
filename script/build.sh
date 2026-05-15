#!/bin/bash

# Default to 3.25.0 if no argument is provided
VERSION=${1:-3.25.0}

if [ "$VERSION" == "3.17.0" ]; then
    MACRO="-DV3_17_0=1"
    QT_VERSION="6.5.3"
    TARGET="iphone:latest:14.0"
elif [ "$VERSION" == "3.25.0" ]; then
    MACRO="-DV3_25_0=1"
    QT_VERSION="6.8.2"
    TARGET="iphone:latest:16.0"
elif [ "$VERSION" == "3.26.0" ]; then
    MACRO="-DV3_26_0=1"
    QT_VERSION="6.8.2"
    TARGET="iphone:latest:17.0"
elif [ "$VERSION" == "3.27.0" ]; then
    MACRO="-DV3_27_0=1"
    QT_VERSION="6.10.0"
    TARGET="iphone:latest:17.0"
elif [ "$VERSION" == "3.27.1" ]; then
    MACRO="-DV3_27_1=1"
    QT_VERSION="6.10.0"
    TARGET="iphone:latest:17.0"
else
    echo "Error: Unknown version '$VERSION'. Supported versions are: 3.25.0, 3.17.0, 3.27.1"
    exit 1
fi

MODE=${2:-dev}

echo "Building for reMarkable version: $VERSION ($MACRO) in $MODE mode"

make clean

if [ "$MODE" == "release" ]; then
    # Modify control file to set the version to match the target app version
    sed -i '' "s/^Version: .*/Version: $VERSION/" control
    make package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 RM_VERSION_FLAG="$MACRO" QT_VERSION="$QT_VERSION" TARGET="$TARGET"
else
    make package THEOS_PACKAGE_SCHEME=rootless DEBUG=0 RM_VERSION_FLAG="$MACRO" QT_VERSION="$QT_VERSION" TARGET="$TARGET"
fi
