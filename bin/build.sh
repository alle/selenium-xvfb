#!/bin/bash

set -e

while getopts v: option
do
  case $option in
    v) VERSION=$OPTARG;;
  esac
done

if [ -z $VERSION ]; then
  echo "Usage: $0 -v <version>"
  exit
fi

# prepare working dir
case "$0" in
  /* ) SCRIPT="$0" ;;
  ./* ) SCRIPT="$PWD/${0#./}" ;;
  */* ) SCRIPT="$PWD/$0" ;;
  * ) echo "Unkown Error"; exit 1 ;;
esac

SCRIPT_DIR=${SCRIPT%/*}

# prepare packages
PACKAGE_DIR=$SCRIPT_DIR/../packages
if [ -d $PACKAGE_DIR ]; then
  sudo rm -Rf $PACKAGE_DIR
fi 
mkdir $PACKAGE_DIR
PACKAGE_DIR=$(realpath $SCRIPT_DIR/../packages)
cd $PACKAGE_DIR

cp -R ../skeleton/selenium-xvfb .
sed -i "s/VERSION/$VERSION/" selenium-xvfb/DEBIAN/control

sudo chown -R root:root *
sudo chmod a+x $PACKAGE_DIR/selenium-xvfb/etc/init.d/selenium-vnc
sudo chmod a+x $PACKAGE_DIR/selenium-xvfb/etc/init.d/selenium-xvfb

# build the packages
sudo dpkg -b selenium-xvfb "selenium-xvfb-$VERSION-amd64.deb"
