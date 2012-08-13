#!/bin/sh

# buildraspi.sh
# Kernel, boot firmware, devices and hacks for Raspberry Pi
#
# Copyright 2012 David Spencer, Baildon, West Yorkshire, U.K.
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#------------------------------------------------------------------------------
#
# This script will run the following SlackBuilds:
#   raspi-boot
#   raspi-hacks
#   kernel_raspi
#   kernel-modules-raspi
#   installer (if DOINSTALLER=yes)
#   kernel-source-raspi (if DOSOURCE=yes)
#
# Before running this script, you must set up the following git repos:
#
#   git clone git://github.com/raspberrypi/linux.git \
#             kernel_raspi/linux
#   git clone git://github.com/raspberrypi/firmware.git \
#             raspi-boot/firmware
#
#------------------------------------------------------------------------------

BUILD=${BUILD:-1}
TAG=${TAG:-}
ARCH=${ARCH:-arm}

TMP=${TMP:-/tmp}
OUTPUT=${OUTPUT:-/tmp}

CWD=$(pwd)

set -e

if [ "${DOINSTALLER:-no}" = 'yes' ]; then
  INSTALLER='installer'
fi
if [ "${DOSOURCE:-no}" = 'yes' ]; then
  KNLSRC='kernel-source-raspi'
fi

for PKGNAM in \
  raspi-boot \
  raspi-hacks \
  kernel_raspi \
  kernel-modules-raspi \
  $INSTALLER \
  $KNLSRC \
; do

  echo "########################################"
  echo "#### $PKGNAM"
  echo "#### $(date)"
  echo "########################################"

  cd $CWD/$PKGNAM
  BUILD=$BUILD TAG=$TAG \
  TMP=$TMP OUTPUT=$OUTPUT \
    sh $PKGNAM.SlackBuild

done

exit 0
