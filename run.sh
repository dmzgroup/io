#!/bin/sh

. ../scripts/envsetup.sh

if [ "$1" = "" ] ; then
   export EXTRA_FILE=config/color/blue.xml ;
fi

$RUN_DEBUG$BIN_HOME/dmzAppQt -f config/runtime.xml config/resource.xml config/common.xml config/audio.xml config/input.xml config/net.xml config/render.xml config/simple.xml config/weapon.xml config/lua.xml $* $EXTRA_FILE
