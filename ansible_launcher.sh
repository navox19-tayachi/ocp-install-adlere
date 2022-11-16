#!/bin/bash
####################################################
##
## These tools are the property of Adlere
## usage is restricted to the final customer only.
##
## Distribution for Consulting purposes is prohibited
## without authorization.
##
## © 2018 Adlere ALL RIGHTS RESERVED
##
####################################################

export INCDIR=$(dirname "$0")
export BASEDIR=.
export INVENTORY=$BASEDIR/ocp4_hosts
export RUSER=$USER
export RCONN=pkey
export SSHKEYDIR=$BASEDIR/rc
export LOCAL_BIN_PATH=~/ocp4bin
export PATH=$LOCAL_BIN_PATH:$PATH
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_LOCAL_TEMP=/tmp

source "$INCDIR/abin/__ShellLibrary__"

eval "$ANSIBLE_CMD" $@
