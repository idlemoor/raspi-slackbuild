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
# This script will build the following packages:
#   raspi-boot
#   raspi-devs
#   raspi-hacks
#   kernel_raspi
#   kernel-modules-raspi
#
# Before running this script, kernel_raspi/linux and raspi-boot/firmware must contain these git repos:
#   git clone https://github.com/raspberrypi/linux.git kernel_raspi/linux
#   git clone https://github.com/raspberrypi/firmware.git raspi-boot/firmware
#
#------------------------------------------------------------------------------

BUILD=${BUILD:-1}
TAG=${TAG:-}
ARCH=${ARCH:-arm}

TMP=${TMP:-/tmp}
OUTPUT=${OUTPUT:-/tmp}

CWD=$(pwd)

set -e

for PKGNAM in raspi-boot raspi-devs raspi-hacks kernel_raspi ; do
# Note: kernel_raspi.SlackBuild will call kernel-modules-raspi.SlackBuild

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
