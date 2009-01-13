#!/bin/sh

. ../scripts/envsetup.sh

if [ "$1" = "" ] ; then
   export EXTRA_FILE=config/color/blue.xml ;
fi

$RUN_DEBUG$BIN_HOME/dmzAppQt -f config/runtime.xml config/common.xml config/input.xml config/net.xml config/render.xml config/simple.xml config/weapon.xml config/lua.xml config/resource.xml $* $EXTRA_FILE
