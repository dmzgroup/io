#!/bin/sh

. ../scripts/envsetup.sh

if [ "$1" = "" ] ; then
   export EXTRA_FILE=config/color/blue.xml ;
fi

$BIN_HOME/dmzAppQt -f config/runtime.xml config/common.xml config/input.xml config/net.xml config/render.xml config/simple.xml config/weapon.xml config/event.xml config/lua.xml $* $EXTRA_FILE
