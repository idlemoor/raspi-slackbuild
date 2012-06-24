#!/bin/sh

# fakeclock.sh
# Script to save and restore system clock if there's no hardware clock
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
#
# NOTES:
#
# This script is a limited drop-in replacement of util-linux's hwclock, for use
# on systems that don't have a proper hardware clock.  It is intended to be
# called from Slackware's rc scripts by moving /sbin/hwclock to hwclock.orig
# and replacing hwclock with a symlink to this script; the Slackware rc scripts
# do not need to be modified.
#
# The only control argument recognised is --hctosys.  All other arguments
# are ignored.
#
# If --hctosys is present, the system clock is set from the last mount
# date/time of the root filesystem (if it's ext2/3/4), or the newest file in
# /var/log (if that exists), or the file /etc/fakeclock (if that exists).
#
# Otherwise, the system clock is saved by touching the file /etc/fakeclock.
#
# The script will only set the system clock when the system clock currently is
# before the year 1971.  This permits the safe use of this script if an RTC is
# present but unreliable (e.g. a failing battery).

action='save'
while [ "$#" != 0 ]
do
  case "$1"
  in
    "--hctosys") action='restore' ;;
    *) ;;
  esac
  shift
done

if [ "$action" = 'restore' ]; then

  if [ $(date '+%Y') -lt '1971' ]; then

    # We'll work in big-endian numeric strings (i.e. +%Y%m%d%H%M%S) so they
    # can be compared as integers.  First, set a catch-all default:
    mydate='197101010000'

    # Try the root filesystem.  This is a good option because it prevents
    # fsck complaining in the next bit of rc.S.
    rtype=$(mount | fgrep '/dev/root' | cut -f5 -d' ')
    if [ "$rtype" = 'ext4' -o "$rtype" = 'ext3' -o "$rtype" = 'ext2' ]; then
      fsdate=$(date --date="$(dumpe2fs -h /dev/root 2>/dev/null | fgrep 'Last mount time' | cut -c27-50)" '+%Y%m%d%H%M%S')
      [ "$fsdate" -gt "$mydate" ] && mydate="$fsdate"
    fi

    # Try /var/log, but won't get anything if it's on a separate fs.
    if [ -d /var/log ]; then
      newest=$(ls -t /var/log 2>/dev/null | head -1)
      if [ -n "$newest" ]; then
        vldate=$(TZ=0 stat -c %y /var/log/"$newest" | cut -c '1-4,6-7,9-10,12-13,15-16,18-19')
        [ "$vldate" -gt "$mydate" ] && mydate="$vldate"
      fi
    fi

    # If we were shutdown cleanly, this will exist:
    if [ -f /etc/fakeclock ]; then
      fkdate=$(TZ=0 stat -c %y /etc/fakeclock | cut -c '1-4,6-7,9-10,12-13,15-16,18-19')
      [ "$fkdate" -gt "$mydate" ] && mydate="$fkdate"
    fi

    echo 'fakeclock.sh: Setting fallback date/time.'
    date --utc "${mydate:4:8}${mydate:0:4}.${mydate:12:2}"

  fi

  # We still need the original hwclock to set the system timezone.
  /sbin/hwclock.orig --systz

else
  # save
  touch /etc/fakeclock
fi

exit 0
